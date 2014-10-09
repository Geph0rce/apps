//
//  ZenConfig.m
//  Zen
//
//  Created by roger qian on 13-3-13.
//  Copyright (c) 2013年 Zen. All rights reserved.
//

#import "Singleton.h"
#import "ZenConfig.h"

#define kZenCellularPlayMode @"ZenCellularPlayMode"
#define kZenCellularOfflineMode @"ZenCellularOfflineMode"

@interface ZenConfig ()
{
    NSTimer *_timer;
}

@property (nonatomic, strong) NSTimer *timer;

- (void)loadConfig;

@end

@implementation ZenConfig

SINGLETON_FOR_CLASS(ZenConfig);

#pragma mark - 
#pragma mark - Zen Config Stuff

- (id)init
{
    self = [super init];
    if (self) {
        [self loadConfig];
        _time = 0;
    }
    
    return self;
}

- (void)openTimer:(NSUInteger)time
{
    // save time
    _time = time;
    
    // invaludate timer
    if (_timer) {
        [_timer invalidate];
        self.timer = nil;
    }

    if (time == 0) {
        // close timer
        return;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)setCellularPlay:(BOOL)cellularPlay
{
    _cellularPlay = cellularPlay;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:cellularPlay forKey:kZenCellularPlayMode];
    [ud synchronize];
}

- (void)setCellularOffline:(BOOL)cellularOffline
{
    _cellularOffline = cellularOffline;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:cellularOffline forKey:kZenCellularOfflineMode];
    [ud synchronize];
}

- (void)loadConfig
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    _cellularPlay = [ud boolForKey:kZenCellularPlayMode];
    _cellularOffline = [ud boolForKey:kZenCellularOfflineMode];
}

- (void)timerFired:(NSTimer *)timer
{
    if (_time > 0) {
        _time--;
        [[NSNotificationCenter defaultCenter] postNotificationName:kZenConfigRefreshTimeNotification object:self];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kZenConfigTimeToCloseNotification object:self];
    }
}

@end
