//
//  ArtisanPlayerController.m
//  Artisan
//
//  Created by roger on 13-8-5.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "AudioStreamer.h"
#import "UIImageView+WebCache.h"
#import "UIColor+MLPFlatColors.h"

#import "Singleton.h"
#import "ArtisanNavigationBar.h"
#import "ArtisanPlayerItem.h"
#import "ArtisanPlayerView.h"
#import "ArtisanPlayerController.h"

#define kArtisanPlayerViewHeight 160.0f
#define kArtisanPlayerItemTag 1001


@interface ArtisanPlayerController ()
{
    AudioStreamer *_streamer;
    NSTimer *_statusUpdateTimer;
    ArtisanPlayerView *_player;
    UITableView *_list;
    NSString *_curUrl;
    UIBackgroundTaskIdentifier _taskId;
}

@property (nonatomic, retain) NSString *curUrl;

- (void)createStreamer:(NSString *)urlStr;
- (void)newBackgoundTask;
@end

@implementation ArtisanPlayerController
@synthesize model = _model;
@synthesize index = _index;
@synthesize curUrl = _curUrl;

SINGLETON_FOR_CLASS(ArtisanPlayerController)

- (id)init
{
    if (self = [super init]) {
        self.curUrl = nil;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ArtisanNavigationBar *bar = [[ArtisanNavigationBar alloc] init];
    [bar addLeftItemWithStyle:ArtisanNavigationItemStyleBack target:self action:@selector(back:)];
    [_container addSubview:bar];
    
    CGRect frame = CGRectMake(0.0f, CGRectGetMaxY(bar.frame), 320.0f, CGRectGetHeight(_container.frame) - kArtisanPlayerViewHeight - CGRectGetHeight(bar.frame));
    [bar release];
    
    UITableView *list = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    _list = list;
    _list.dataSource = self;
    _list.delegate = self;
    _list.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_container addSubview:_list];
    [list release];
    
    frame = CGRectMake(0.0f, CGRectGetHeight(_container.frame) - kArtisanPlayerViewHeight, 320.0f, kArtisanPlayerViewHeight);
    ArtisanPlayerView *player = [[ArtisanPlayerView alloc] initWithFrame:frame];
    [_container addSubview:player];
    _player = player;
    _player.delegate = (id<ArtisanPlayerViewDelegate>)self;
    [player release];
    
    __block ArtisanPlayerController *controller = self;
    [self enablePanRightGestureWithDismissBlock:^{
        [controller blockDDMenuControllerGesture:NO];
    }];
    
}


#pragma mark -
#pragma mark Handle NavigationBar Event

- (void)back:(id)sender
{
    [self dismissViewControllerWithOption:ArtisanAnimationOptionHorizontal completion:^{
        [self blockDDMenuControllerGesture:NO];
    }];
}


#pragma mark -
#pragma mark UITableViewDataSource and UITableViewDelegate Methods

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _model.songs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ArtisanSongsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        ArtisanPlayerItem *item = [[ArtisanPlayerItem alloc] init];
        item.tag = kArtisanPlayerItemTag;
        [cell.contentView addSubview:item];
    }
    
    ArtisanPlayerItem *item = (ArtisanPlayerItem *)[cell.contentView viewWithTag:kArtisanPlayerItemTag];
    ArtisanSongsData *data = [_model.songs safeObjectAtIndex:indexPath.row];
    [item load:data];
    if (_index == indexPath.row) {
        item.selected = YES;
    }
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_index == indexPath.row) {
        return;
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_index inSection:0]];
    ArtisanPlayerItem *item = (ArtisanPlayerItem *)[cell viewWithTag:kArtisanPlayerItemTag];
    if (item) {
        item.selected = NO;
    }
    _index = indexPath.row;
    [self load];
}

#pragma mark -
#pragma mark loading animations

- (void)startAnimation
{
    [CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
	[CATransaction setValue:[NSNumber numberWithFloat:2.0] forKey:kCATransactionAnimationDuration];
    
	CABasicAnimation *animation;
	animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.fromValue = [NSNumber numberWithFloat:0.0];
	animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
	animation.delegate = self;
	//[_loading.layer addAnimation:animation forKey:@"rotationAnimation"];
    [CATransaction commit];
}

- (void)stopAnimation
{
    //[_loading.layer removeAllAnimations];
}


#pragma mark -
#pragma mark CAAnimationDelegate Methods

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)finished
{
    if (finished) {
        [self startAnimation];
    }
}


#pragma mark -
#pragma mark logic of player

- (void)setInfo:(ArtisanSongsData *)data
{
    [_player setAlbumWithURL:data.picture];
    [_player setName:data.name];
    [_player setArtist:data.artist];
}

- (void)load
{
    if (!_curUrl) {
        NSArray *songs = _model.songs;
        ArtisanSongsData *data = [songs safeObjectAtIndex:_index];
        if (data) {
            [self createStreamer:data.src];
            [_streamer start];
            self.curUrl = data.src;
            [self setInfo:data];
        }
    }
    else
    {
        NSArray *songs = _model.songs;
        ArtisanSongsData *data = [songs safeObjectAtIndex:_index];
        if (data) {
            if (![_curUrl isEqualToString:data.src]) {
                [self createStreamer:data.src];
                [_streamer start];
                self.curUrl = data.src;
                [self setInfo:data];
            }
        }
    }
    [_list reloadData];
}

- (void)play
{
    if (_streamer.isPaused) {
        [_streamer start];
        [_player setStatus:ArtisanPlayerStatusPlay];
    }
    else
    {
        [_streamer pause];
        [_player setStatus:ArtisanPlayerStatusPause];
    }
    [_list reloadData];
}

- (void)prev
{
    _index--;
    if (_index < 0 || _index >= _model.songs.count) {
        _index = 0;
    }
    [_list reloadData];
    NSArray *songs = _model.songs;
    ArtisanSongsData *data = [songs safeObjectAtIndex:_index];
    if(data){
        self.curUrl = data.src;
        [self createStreamer:_curUrl];
        [_streamer start];
        [self setInfo:data];
    }
}


- (void)next
{
    _index++;
    if (_index < 0 || _index >= _model.songs.count) {
        _index = 0;
    }
    [_list reloadData];
    NSArray *songs = _model.songs;
    ArtisanSongsData *data = [songs safeObjectAtIndex:_index];
    if(data){
        self.curUrl = data.src;
        [self createStreamer:_curUrl];
        [_streamer start];
        [self setInfo:data];
    }
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
    }
    else {
        int min = time/60;
        int sec = time%60;
        timeStr = [NSString stringWithFormat:@"%d:%02d", min, sec];
    }
       
    [_player setTime:timeStr];
}

- (void)playbackStateChanged:(NSNotification *)notification
{
    //NSLog(@"state changed: %d", _streamer.state);
    if ([_streamer isWaiting])
	{
		NSLog(@"waiting, %d", _streamer.state);
        [_player setTime:@"loading..."];
	}
	else if ([_streamer isPlaying])
	{
        NSLog(@"playing.");
        _player.status = ArtisanPlayerStatusPlay;
    }
	else if ([_streamer isIdle])
	{
        NSLog(@"idle");
        if (_player.isRecycle) {
            NSArray *songs = _model.songs;
            ArtisanSongsData *data = [songs safeObjectAtIndex:_index];
            if(data){
                self.curUrl = data.src;
                [self createStreamer:_curUrl];
                [_streamer start];
                [self setInfo:data];
            }
        }
        else {
            [self next];
        }
       
    }
}

- (void)destroyStreamer
{
	if (_streamer)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:ASStatusChangedNotification
                                                      object:_streamer];
        [_statusUpdateTimer invalidate];
		_statusUpdateTimer = nil;
		
		[_streamer stop];
		[_streamer release];
		_streamer = nil;
	}
}


- (void)createStreamer:(NSString *)urlStr
{
	[self destroyStreamer];
	        
	NSURL *url = [NSURL URLWithString:urlStr];
	_streamer = [[AudioStreamer alloc] initWithURL:url];
	
	_statusUpdateTimer =    [NSTimer scheduledTimerWithTimeInterval:1.0f
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
#pragma mark ArtisanPlayerViewDelegate Methods

- (void)playerControlClicked:(ArtisanPlayerControlType)type
{
    if(type == ArtisanPlayerControlTypeBack)
    {
    }
    else if (type == ArtisanPlayerControlTypeNext) {
        [self next];
    }
    else if(type == ArtisanPlayerControlTypePrev) {
        [self prev];
    }
    else if(type == ArtisanPlayerControlTypePlay) {
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
