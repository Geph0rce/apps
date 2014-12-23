//
//  ZenConfig.m
//  Zen
//
//  Created by roger qian on 13-3-13.
//  Copyright (c) 2013年 Zen. All rights reserved.
//

#import "Singleton.h"
#import "ZenConfig.h"

#define kZenTextOnlyMode @"ZenTextOnlyMode"
#define kZenNightModeProperty @"ZenNightModeProperty"

@interface ZenConfig ()

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
    }
    
    return self;
}

- (void)setTextOnly:(BOOL)flag
{
    _textOnly = flag;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:flag forKey:kZenTextOnlyMode];
    [ud synchronize];
}

- (void)setNight:(BOOL)night
{
    _night = night;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:night forKey:kZenNightModeProperty];
    [ud synchronize];
}

- (void)loadConfig
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    _textOnly = [ud boolForKey:kZenTextOnlyMode];
    _night = [ud boolForKey:kZenNightModeProperty];
}

@end
