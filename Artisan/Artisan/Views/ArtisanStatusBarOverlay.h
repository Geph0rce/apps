//
//  ArtisanStatusBarOverlay.h
//  Artisan
//
//  Created by roger on 13-5-16.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum{
    ArtisanStatusBarOverlayTypeInfo,
    ArtisanStatusBarOverlayTypeSuccess,
    ArtisanStatusBarOverlayTypeWarning,
    ArtisanStatusBarOverlayTypeError
} ArtisanStatusBarOverlayType;

@interface ArtisanStatusBarOverlay : UIWindow

+ (ArtisanStatusBarOverlay *)sharedInstance;
- (void)postMessage:(NSString *)msg type:(ArtisanStatusBarOverlayType)type  dismissAfterDelay:(int)delay;
@end
