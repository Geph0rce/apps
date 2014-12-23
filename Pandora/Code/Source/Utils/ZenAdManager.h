//
//  ZenAdManager.h
//  Zen
//
//  Created by roger on 13-11-11.
//  Copyright (c) 2013年 Zen. All rights reserved.
//


#import <Foundation/Foundation.h>

#define kZenAdManagerAdFree         @"ZenAdManagerAdFree"
#define kZenAdManagerAdFreeFailed   @"ZenAdManagerAdFreeFailed"

@protocol ZenAdManagerDelegate <NSObject>

@optional
- (void)makeKeyAndVisible;
- (void)posterAdDidShow;

@end

@interface ZenAdManager : NSObject

+ (ZenAdManager *)sharedInstance;

+ (UIView *)banner;

+ (void)visible:(BOOL)flag;

- (void)showInterstitial:(UIView *)view;

- (void)showSplashAd:(UIWindow *)window;

- (void)showPosterAd;

@end
