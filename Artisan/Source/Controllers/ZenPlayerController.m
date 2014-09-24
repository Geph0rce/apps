//
//  ZenPlayerController.m
//  Artisan
//
//  Created by roger on 14-9-11.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ZenOfflineModel.h"
#import "AudioStreamer.h"
#import "Singleton.h"
#import "ZenCategory.h"
#import "ZenNavigationBar.h"
#import "ZenPlayerView.h"
#import "ZenPlayerCell.h"
#import "ZenPlayerController.h"

#define kZenPlayerCellId @"ZenPlayerCellId"
#define kZenPlayerHeight 160.0f

@interface ZenPlayerController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_table;
    ZenPlayerView *_player;
    AudioStreamer *_streamer;
    UIBackgroundTaskIdentifier _taskId;
    NSTimer *_timer;
    NSString *_hash;
    AVAudioPlayer *_avAudioPlayer;
}

@property (nonatomic, strong) ZenPlayerView *player;
@property (nonatomic, strong) AudioStreamer *streamer;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSString *hash;
@property (nonatomic, strong) AVAudioPlayer *avAudioPlayer;
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
            NSURL *url = [NSURL URLWithString:song.src];
            if ([ZenOfflineModel songExists:song]) {
                url = [ZenOfflineModel urlForSong:song];
            }
            else {
//
//                [self changeToPlayStatus:ZenSongStatusPlay index:_index];
//                [self createStreamer:url];
//                [_streamer start];
//                [_player load:song];
            }
            self.avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
            //avAudioPlayer.delegate = self;
            [_avAudioPlayer prepareToPlay];
            [_avAudioPlayer play];
        }
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
    ZenSongStatus status = ZenSongStatusNone;
    if (_streamer.isPaused) {
        [_streamer start];
        status = ZenSongStatusPlay;
    }
    else
    {
        status = ZenSongStatusPause;
        [_streamer pause];
    }
    [self changeToPlayStatus:status index:_index];
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

- (void)updateStatus:(NSTimer *)timer
{
    int time = (int)(_streamer.duration - _streamer.progress);
    NSString *timeStr = nil;
    if (time == 0) {
        timeStr = @"loading...";
        [_player setTimeLabelText:timeStr];
    }
    else if ([_streamer isPlaying]){
        int min = time/60;
        int sec = time%60;
        timeStr = [NSString stringWithFormat:@"%d:%02d", min, sec];
        [_player setTimeLabelText:timeStr];
    }
    
}

- (void)playbackStateChanged:(NSNotification *)notification
{
    //NSLog(@"state changed: %d", _streamer.state);
    if ([_streamer isWaiting])
	{
		NSLog(@"waiting, %d", _streamer.state);
        [_player setTimeLabelText:@"loading..."];
	}
	else if ([_streamer isPlaying])
	{
        NSLog(@"playing.");
        [self changeToPlayStatus:ZenSongStatusPlay index:_index];
        ZenSongData *song = [_list safeObjectAtIndex:_index];
        if (song) {
            [_player load:song];
        }
    }
	else if ([_streamer isIdle])
	{
        NSLog(@"idle");
        [self next];
    }
}

- (void)destoryStreamer
{
	if (_streamer)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:ASStatusChangedNotification
                                                      object:_streamer];
        [_timer invalidate];
		self.timer = nil;
		
		[_streamer stop];
		self.streamer = nil;
	}
}


- (void)createStreamer:(NSURL *)src
{
	[self destoryStreamer];
    
	_streamer = [[AudioStreamer alloc] initWithURL:src];
	
	_timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                              target:self
                                            selector:@selector(updateStatus:)
                                            userInfo:nil
                                             repeats:YES];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackStateChanged:)
                                                 name:ASStatusChangedNotification
                                               object:_streamer];
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
