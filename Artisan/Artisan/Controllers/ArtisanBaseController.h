//
//  ArtisanBaseController.h
//  Artisan
//
//  Created by roger on 13-4-7.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import "DDMenuController.h"
#import "ArtisanStatusBarOverlay.h"

typedef void (^ArtisanBlock)(void);

typedef enum{
    ArtisanAnimationOptionHorizontal = 0,
    ArtisanAnimationOptionVertical
}ArtisanAnimationOption;

typedef enum{
    ArtisanPanDirectionNone,
    ArtisanPanDirectionLeft,
    ArtisanPanDirectionRight
} ArtisanPanDirection;

typedef enum{
    ArtisanPanCompletionNone,
    ArtisanPanCompletionRoot,
    ArtisanPanCompletionLeft,
    ArtisanPanCompletionRight
} ArtisanPanCompletion;

typedef enum {
    ArtisanPanStateNone,
    ArtisanPanStateShowingLeft,
    ArtisanPanStateShowingRight
} ArtisanPanState;

@interface ArtisanBaseController : UIViewController <UIGestureRecognizerDelegate>
{
    UIView *_container;
    UIView *_mask;
    ArtisanPanDirection _panDirection;
    CGPoint _panVelocity;
    CGFloat _panOriginX;
    CGFloat _panEndX;
    ArtisanPanState _state;
    BOOL _shouldBlockGesture;
    ArtisanBaseController *_parentController;
    BOOL _canShowLeft;
    BOOL _canShowRight;
}


@property (nonatomic, copy) ArtisanBlock coveredBlock;
@property (nonatomic, copy) ArtisanBlock childDismissBlock;
@property (nonatomic, assign) BOOL hasMask;
@property (nonatomic, assign) BOOL shouldBlockGesture;
@property (nonatomic, assign) ArtisanBaseController *parentController;
@property (nonatomic, assign) ArtisanBaseController *childController;

- (void)pushController:(ArtisanBaseController *)controller;

- (void)enablePanLeftGestureWithWillCoverBlock:(ArtisanBlock)willCoverBlock coveredBlock:(ArtisanBlock)coveredBlock andDismissBlock:(ArtisanBlock)dismissBlock;
- (void)enablePanRightGestureWithDismissBlock:(ArtisanBlock)block;
- (void)blockDDMenuControllerGesture:(BOOL)block;

- (void)presentViewController:(ArtisanBaseController *)controller option:(ArtisanAnimationOption)option completion:(ArtisanBlock)block;
- (void)dismissViewControllerWithOption:(ArtisanAnimationOption)option completion:(ArtisanBlock)block;



- (void)postMessage:(NSString *)msg;
- (void)postMessage:(NSString *)msg type:(ArtisanStatusBarOverlayType)type;
- (void)postMessage:(NSString *)msg type:(ArtisanStatusBarOverlayType)type dismissAfterDelay:(int)delay;

@end
