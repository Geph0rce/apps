//
//  ZenPlayerController.m
//  Artisan
//
//  Created by roger on 14-9-11.
//  Copyright (c) 2014年 Zen. All rights reserved.
//


#import "ZenOfflineModel.h"
#import "DOUAudioStreamer.h"
#import "Singleton.h"
#import "ZenCategory.h"
#import "ZenNavigationBar.h"
#import "ZenPlayerView.h"
#import "ZenPlayerCell.h"
#import "ZenPlayerController.h"

#define kZenPlayerCellId @"ZenPlayerCellId"
#define kZenPlayerHeight 160.0f

static void *kStatusKVOKey = &kStatusKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;

@interface ZenPlayerController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_table;
    ZenPlayerView *_player;
    DOUAudioStreamer *_streamer;
    UIBackgroundTaskIdentifier _taskId;
    NSTimer *_timer;
    NSString *_hash;
}

@property (nonatomic, strong) ZenPlayerView *player;
@property (nonatomic, strong) DOUAudioStreamer *streamer;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSString *hash;

@end

@implementation ZenPlayerController

SINGLETON_FOR_CLASS(ZenPlayerController);

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ZenNavigationBar *bar = [[ZenNavigationBar alloc] init];
    [bar addLeftItemWithStyle:ZenNavigationItemStyleBack target:self action:@selector(back:)];
    [_container addSubview:bar];
    
    _table = [[UITableView alloc] initWithFrame:_container.bounds];
    _table.delegate = self;
    _table.dataSource = self;
    _table.scrollsToTop = YES;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_table setAllowsSelection:YES];
    [_container addSubview:_table];
    _table.frame = CGRectMake(0.0f, bar.height, CGRectGetWidth(_container.frame), CGRectGetHeight(_container.frame) - bar.height - kZenPlayerHeight);
    
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ZenPlayerView" owner:self options:NULL];
    if (array && array.count > 0) {
        self.player = array[0];
        CGRect frame = _player.frame;
        frame.origin.y = CGRectGetHeight(_container.frame) - kZenPlayerHeight;
        _player.frame = frame;
        [_container addSubview:_player];
        [_player addTarget:self action:@selector(playerControlClicked:)];
    }
    
    [_table registerNib:[UINib nibWithNibName:@"ZenPlayerCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kZenPlayerCellId];
    [self enablePanRightGestureWithDismissBlock:NULL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self load];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_timer) {
        [_timer invalidate];
        self.timer = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back:(id)sender
{
    [self dismissViewControllerWithOption:ZenAnimationOptionHorizontal completion:NULL];
}

#pragma mark
#pragma mark UITableViewDataSource and UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _list.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZenSongData *song = _list[indexPath.row];
    ZenPlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:kZenPlayerCellId];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell load:song];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _index = indexPath.row;
    [self load];
}

#pragma mark
#pragma mark Play Stuff

- (void)load
{
    ZenSongData *song = [_list safeObjectAtIndex:_index];
    if (song) {
        if (!_hash || ![song.hash isEqualToString:_hash]) {
            self.hash = song.hash;
            [self changeToPlayStatus:ZenSongStatusPlay index:_index];
            [_player load:song];
            [self resetStreamer];
        }
    }
}

- (void)cancelStreamer
{
    if (_streamer != nil) {
        [_streamer pause];
        [_streamer removeObserver:self forKeyPath:@"status"];
        [_streamer removeObserver:self forKeyPath:@"bufferingRatio"];
        _streamer = nil;
    }
}

- (void)resetStreamer
{
    [self cancelStreamer];
    
    if (0 == [_list count])
    {
        NSLog(@"no track avaiable");
    }
    else
    {
        ZenSongData *song = [_list objectAtIndex:_index];
        _streamer = [DOUAudioStreamer streamerWithAudioFile:song];
        [_streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
        [_streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
        
        [_streamer play];
    }
}


- (void)changeToPlayStatus:(ZenSongStatus)status index:(NSUInteger)index
{
    if (!_list) {
        NSLog(@"invalid playlist.");
        return;
    }
    for (int i = 0; i < _list.count; i++) {
        ZenSongData *song = _list[i];
        song.status = ZenSongStatusNone;
        if (i == index) {
            song.status = status;
        }
    }
    [_table reloadData];
}


- (void)play
{
    ZenSongStatus songStatus = ZenSongStatusNone;
    DOUAudioStreamerStatus status = [_streamer status];
    if (status == DOUAudioStreamerPaused) {
        [_streamer play];
        songStatus = ZenSongStatusPlay;
    }
    else
    {
        songStatus = ZenSongStatusPause;
        [_streamer pause];
    }
    [self changeToPlayStatus:songStatus index:_index];
    ZenSongData *song = [_list safeObjectAtIndex:_index];
    if (song) {
        [_player load:song];
    }
}

- (void)prev
{
    _index--;
    if (_index >= _list.count) {
        _index = 0;
    }
    [_table reloadData];
    [self load];
}


- (void)next
{
    _index++;
    if (_index >= _list.count) {
        _index = 0;
    }
    [_table reloadData];
    [self load];
}

#pragma mark -
#pragma mark AudioStreamer Stuff

- (void)newBackgoundTask
{
    UIBackgroundTaskIdentifier newTaskId = UIBackgroundTaskInvalid;
    newTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    if (newTaskId != UIBackgroundTaskInvalid && _taskId != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask: _taskId];}
    _taskId = newTaskId;
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}


- (void)timerAction:(id)timer
{
    int time = (int)(_streamer.duration - _streamer.currentTime);
    
    if (time == 0) {
        [_player setTimeLabelText:@"loading"];
    }
    else {
        int min = time/60;
        int sec = time%60;
        NSString *timeStr = [NSString stringWithFormat:@"%d:%02d", min, sec];
        [_player setTimeLabelText:timeStr];
    }
}


- (void)updateStatus
{
    switch ([_streamer status]) {
        case DOUAudioStreamerPlaying:
            
            break;
            
        case DOUAudioStreamerPaused:
            
            break;
            
        case DOUAudioStreamerIdle:
            break;
            
        case DOUAudioStreamerFinished:
            //[_statusLabel setText:@"finished"];
            //[self _actionNext:nil];
            [self next];
            break;
            
        case DOUAudioStreamerBuffering:
            [_player setTimeLabelText:@"loading..."];
            break;
            
        case DOUAudioStreamerError:
            //[_statusLabel setText:@"error"];
            break;
    }
}

- (void)_updateBufferingStatus
{
    NSLog(@"%@", [NSString stringWithFormat:@"Received %.2f/%.2f MB (%.2f %%), Speed %.2f MB/s", (double)[_streamer receivedLength] / 1024 / 1024, (double)[_streamer expectedLength] / 1024 / 1024, [_streamer bufferingRatio] * 100.0, (double)[_streamer downloadSpeed] / 1024 / 1024]);
    
    if ([_streamer bufferingRatio] >= 1.0) {
        NSLog(@"sha256: %@", [_streamer sha256]);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kStatusKVOKey) {
        [self performSelector:@selector(updateStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kBufferingRatioKVOKey) {
        [self performSelector:@selector(_updateBufferingStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)createStreamer:(NSURL *)src
{
    [self newBackgoundTask];
}





#pragma mark -
#pragma mark ZenPlayerViewDelegate Methods

- (void)playerControlClicked:(id)sender
{
    UIView *view = (UIView *)sender;
    ZenPlayerControlType type = view.tag;
    if (type == ZenPlayerControlTypeNext) {
        [self next];
    }
    else if(type == ZenPlayerControlTypePrev) {
        [self prev];
    }
    else if(type == ZenPlayerControlTypePlay) {
        [self play];
    }
}


#pragma mark -
#pragma mark Remote Control

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self play];
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self prev];
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [self next];
                break;
            default:
                break;
        }
    }
}



@end
