//
//  ArtisanStatusBarOverlay.m
//  Artisan
//
//  Created by roger on 13-5-16.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import "ArtisanStatusBarOverlay.h"
#import "UIColor+MLPFlatColors.h"
#import "Singleton.h"

#define kArtisanStatusBarOverlayBeforeAnimationFrame CGRectMake(0.0f, -20.0f, 320.0f, 20.0f)
#define kArtisanStatusBarOverlayAfterAnimationFrame CGRectMake(0.0f, 0.0f, 320.0f, 20.0f)
#define kArtisanStatusBarLabelFrame CGRectMake(20.0f, 0.0f, 300.0f, 20.0f)
#define kArtisanStatusEaseOutAnimationDuration 0.4f
#define kArtisanStatusEaseInAnimationDuration 0.3f

@interface ArtisanStatusBarOverlay ()
{
    UILabel *_label;
}
@end

@implementation ArtisanStatusBarOverlay

SINGLETON_FOR_CLASS(ArtisanStatusBarOverlay);

- (id)init
{
    CGRect frame = [[UIApplication sharedApplication] statusBarFrame];
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelStatusBar + 1.0f;
        self.backgroundColor = [UIColor flatBlueColor];
        self.frame = frame;
        UILabel *label = [[UILabel alloc] initWithFrame:kArtisanStatusBarLabelFrame];
        label.backgroundColor = [UIColor clearColor];
        label.font = kArtisanFont15;
        label.textColor = [UIColor flatWhiteColor];
        _label = label;
        [self addSubview:label];
        [label release];
    }
    return self;
}

- (void)pickColorForType:(ArtisanStatusBarOverlayType)type
{
    _label.textColor = [UIColor flatWhiteColor];
    
    if (type == ArtisanStatusBarOverlayTypeSuccess) {
        self.backgroundColor = [UIColor flatGreenColor];
    }
    
    else if(type == ArtisanStatusBarOverlayTypeError){
        self.backgroundColor = [UIColor flatRedColor];
    }
    else if(type == ArtisanStatusBarOverlayTypeWarning)
    {
        self.backgroundColor = [UIColor flatYellowColor];
        _label.textColor = [UIColor flatBlackColor];
    }
    else {
        self.backgroundColor = [UIColor flatBlueColor];
    }
}

- (void)postMessage:(NSString *)msg type:(ArtisanStatusBarOverlayType)type dismissAfterDelay:(int)delay
{
    if (!self.hidden) {
        NSLog(@"posting msg, try latter.");
        return;
    }
    
    [self pickColorForType:type];
    
    self.frame = kArtisanStatusBarOverlayBeforeAnimationFrame;
    self.hidden = NO;
    _label.text = msg;
    
    [UIView animateWithDuration:kArtisanStatusEaseOutAnimationDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.frame = kArtisanStatusBarOverlayAfterAnimationFrame;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:kArtisanStatusEaseInAnimationDuration
                                               delay:delay
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              self.frame = kArtisanStatusBarOverlayBeforeAnimationFrame;
                                          }
                                          completion:^(BOOL finished) {
                                              self.hidden = YES;
                                          }];
                     }];
}

@end
