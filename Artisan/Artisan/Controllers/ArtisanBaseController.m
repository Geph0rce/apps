//
//  ArtisanBaseController.m
//  Artisan
//
//  Created by roger on 13-4-7.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//
#import "UIColor+MLPFlatColors.h"

#import "ArtisanBaseController.h"
//#import "ArtisanHelper.h"
#import "ArtisanStack.h"

#define kScaleFactor 0.02f
#define kAlphaFactor 0.1f
#define kArtisanEpisnon 0.5f
#define kArtisanOffsetX 30.0f

@interface ArtisanBaseController ()

@property (nonatomic, copy) ArtisanBlock dismissBlock;
@property (nonatomic, copy) ArtisanBlock willCoverBlock;


@end

@implementation ArtisanBaseController

@synthesize parentController = _parentController;
@synthesize childController = _childController;

@synthesize hasMask = _hasMask;
@synthesize shouldBlockGesture = _shouldBlockGesture;
@synthesize dismissBlock = _dismissBlock;
@synthesize willCoverBlock = _willCoverBlock;
@synthesize coveredBlock = _coveredBlock;
@synthesize childDismissBlock = _childDismissBlock;


- (void)dealloc
{
    NSLog(@"ArtisanBaseController dealloc!");
    [_dismissBlock release], _dismissBlock = nil;
    [_willCoverBlock release], _willCoverBlock = nil;
    [_coveredBlock release], _coveredBlock = nil;
    [_childDismissBlock release], _childDismissBlock = nil;
    _parentController = nil;
    _childController = nil;
    [super dealloc];
}

- (id)init
{
    if (self = [super init]) {
        _shouldBlockGesture = NO;
        _canShowLeft = NO;
        _canShowRight = NO;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];

    UIView *container = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:container];
    _container = container;
    _container.backgroundColor = kArtisanBackgroundColor;
    [container release];
    
    UIView *mask = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:mask];
    mask.alpha = 0.1f;
    mask.hidden = YES;
    _mask = mask;
    _mask.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f];
    [mask release];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _parentController.shouldBlockGesture = NO;
}

- (void)blockDDMenuControllerGesture:(BOOL)block
{
    DDMenuController *menuController = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
    menuController.shouldBlockGesture = block;
}

- (void)pushController:(ArtisanBaseController *)controller
{
    [[ArtisanStack sharedInstance] push:controller];
    controller.parentController = self;
    self.childController = controller;
    [self.view addSubview:controller.view];
    [controller.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
    [controller addObserver:self forKeyPath:@"hasMask" options:NSKeyValueObservingOptionNew context:NULL];
}

#pragma mark -
#pragma mark - KVO Stuff

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"]) {
        UIView *contentView = (UIView *)object;
        CGFloat originX = contentView.frame.origin.x;
        CGFloat originY = contentView.frame.origin.y;
        
        CGFloat factor = 0;
        if (originX < kArtisanEpisnon) {
            factor =  1 - originY/CGRectGetHeight(contentView.frame);
        }
        else if(originY < kArtisanEpisnon){
            factor =  1 - originX/CGRectGetWidth(contentView.frame);
        }
       
        CGFloat scale = 1.0f - (kScaleFactor * factor);
        CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
        _container.transform = transform;
        _mask.alpha = kAlphaFactor + factor;
    }
    else if([keyPath isEqualToString:@"hasMask"]){
        ArtisanBaseController *vc = (ArtisanBaseController *)object;
        _mask.hidden = !vc.hasMask;
    }
}

#pragma mark -
#pragma mark - Pan Gesture Stuff

- (void)enablePanRightGestureWithDismissBlock:(ArtisanBlock)block
{
    if (!_canShowRight) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        pan.delegate = self;
        [self.view addGestureRecognizer:pan];
        [pan release];
    }
    _canShowLeft = YES;
    self.dismissBlock = block;
}

- (void)enablePanLeftGestureWithWillCoverBlock:(ArtisanBlock)willCoverBlock coveredBlock:(ArtisanBlock)coveredBlock andDismissBlock:(ArtisanBlock)dismissBlock
{
    if (!_canShowLeft) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        pan.delegate = self;
        [self.view addGestureRecognizer:pan];
        [pan release];
    }

    _canShowRight = YES;
    self.willCoverBlock = willCoverBlock;
    self.coveredBlock = coveredBlock;
    self.childDismissBlock = dismissBlock;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return (!_shouldBlockGesture);
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        _panOriginX = self.view.frame.origin.x;
        _panVelocity = CGPointMake(0.0f, 0.0f);
        
        if([gesture velocityInView:self.view.superview].x > 0) {
            _panDirection = ArtisanPanDirectionRight;
        }
        else {
            _panDirection = ArtisanPanDirectionLeft;
            if (_canShowRight && _willCoverBlock) {
                _willCoverBlock();
            }
        }
        
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint velocity = [gesture velocityInView:self.view.superview];
        if((velocity.x*_panVelocity.x + velocity.y*_panVelocity.y) < 0) {
            _panDirection = (_panDirection == ArtisanPanDirectionRight) ? ArtisanPanDirectionLeft : ArtisanPanDirectionRight;
        }
        
        _panVelocity = velocity;
        CGPoint translation = [gesture translationInView:self.view.superview];
        CGRect frame = self.view.frame;
        frame.origin.x = _panOriginX + translation.x;

        if(frame.origin.x > 0 && _canShowLeft)
        {
            if (_state == ArtisanPanStateNone && _panDirection == ArtisanPanDirectionRight) {
                _state = ArtisanPanStateShowingLeft;
            }
            if (_state == ArtisanPanStateShowingLeft) {
                self.view.frame = frame;
                _panEndX = frame.origin.x;
            }
        }
        else if(_canShowRight)
        {
            if (_state == ArtisanPanStateNone && _panDirection == ArtisanPanDirectionLeft) {
                _state = ArtisanPanStateShowingRight;
            }
            if (_state == ArtisanPanStateShowingRight) {
                if (_childController) {
                    CGRect childFrame = _childController.view.frame;
                    childFrame.origin.x = 320.0f + translation.x;
                    if (childFrame.origin.x < 0) {
                        childFrame.origin.x = 0.0f;
                    }
                    _childController.view.frame = childFrame;
                }
            }

        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        ArtisanPanCompletion  completion =  ArtisanPanCompletionNone;
        
        if(_canShowLeft && _state == ArtisanPanStateShowingLeft && (_panEndX < kArtisanOffsetX || _panDirection == ArtisanPanDirectionLeft))
        {
            completion = ArtisanPanCompletionRoot;
        }
        else if (_canShowLeft && _state == ArtisanPanStateShowingLeft && _panDirection == ArtisanPanDirectionRight) {
            completion = ArtisanPanCompletionLeft;
        }
       
        else if(_canShowRight && _state == ArtisanPanStateShowingRight && _panDirection == ArtisanPanDirectionLeft)
        {
            completion = ArtisanPanCompletionRight;
        }
        else if(_canShowRight && _state == ArtisanPanStateShowingRight && _panDirection == ArtisanPanDirectionRight)
        {
            completion = ArtisanPanCompletionNone;
        }
    
        
        if (completion == ArtisanPanCompletionLeft) {
            [self viewWillDisappear:YES];
            __block CGRect frame = self.view.frame;
            [UIView animateWithDuration:0.3f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 frame.origin.x = CGRectGetWidth(self.view.frame);
                                 self.view.frame = frame;
                             }
                             completion:^(BOOL finished) {
                                 if (_dismissBlock) {
                                     _dismissBlock();
                                 }
                                 self.hasMask = NO;
                                 self.parentController.childController = nil;
                                 [self removeObserver:self.parentController forKeyPath:@"hasMask"];
                                 [self.view removeObserver:self.parentController forKeyPath:@"frame"];
                                 [self.view removeFromSuperview];
                                 [self viewDidDisappear:YES];
                                 [[ArtisanStack sharedInstance] pop:self];
                                 
                             }];

        }
        else if(completion == ArtisanPanCompletionRoot){
            if (self.view.frame.origin.x > 0) {
                __block CGRect frame = self.view.frame;
                [UIView animateWithDuration:0.3f
                                      delay:0.0f
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     frame.origin.x = 0.0f;
                                     self.view.frame = frame;
                                 }
                                 completion:^(BOOL finished) {
                                     _state = ArtisanPanStateNone;
                                 }];
            }
        }

        else if(completion == ArtisanPanCompletionRight){
            if (_childController) {
                __block CGRect frame = _childController.view.frame;
                [UIView animateWithDuration:0.3f
                                      delay:0.0f
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     frame.origin.x = 0.0f;
                                     _childController.view.frame = frame;
                                 }
                                 completion:^(BOOL finished) {
                                     if (_coveredBlock) {
                                         _coveredBlock();
                                     }
                                     _state = ArtisanPanStateNone;
                                 }];

            }
        }
        else if(_canShowRight && completion == ArtisanPanCompletionNone){
            if (_childController) {
                __block CGRect frame = _childController.view.frame;
                [UIView animateWithDuration:0.3f
                                      delay:0.0f
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     frame.origin.x = CGRectGetWidth(self.view.frame);
                                     _childController.view.frame = frame;
                                 }
                                 completion:^(BOOL finished) {
                                     if (_childDismissBlock) {
                                         _childDismissBlock();
                                     }
                                     _childController.hasMask = NO;
                                     [_childController removeObserver:self forKeyPath:@"hasMask"];
                                     [_childController.view removeObserver:self forKeyPath:@"frame"];
                                     [_childController.view removeFromSuperview];
                                     [_childController viewDidDisappear:YES];
                                     [[ArtisanStack sharedInstance] pop:_childController];
                                     _childController = nil;
                                     _state = ArtisanPanStateNone;
                                 }];
                
            }
        }

        
    }
}



#pragma mark -
#pragma mark - ViewController Presentation

- (void)presentViewController:(ArtisanBaseController *)controller option:(ArtisanAnimationOption)option completion:(ArtisanBlock)block
{
    if (!controller || _childController) {
        NSLog(@"controller is nil.");
        return;
    }
    [[ArtisanStack sharedInstance] push:controller];
    self.childController = controller;
    controller.parentController = self;
    [controller.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
    [controller addObserver:self forKeyPath:@"hasMask" options:NSKeyValueObservingOptionNew context:NULL];
    [controller viewWillAppear:YES];
    
    if (option == ArtisanAnimationOptionHorizontal) {
        CGRect rect = controller.view.frame;
        rect.origin.x = CGRectGetWidth(self.view.bounds);
        controller.view.frame = rect;
        [self.view addSubview:controller.view];
        controller.hasMask = YES;
        
        __block CGRect frame = controller.view.frame;
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             frame.origin.x = 0.0f;
                             controller.view.frame = frame;
                         }
                         completion:^(BOOL finished) {
                             if (block) {
                                 block();
                             }
                             [controller viewDidAppear:YES];
                         }];
    }
    else if (option == ArtisanAnimationOptionVertical) {
        CGRect rect = controller.view.frame;
        rect.origin.y = CGRectGetHeight(self.view.bounds);
        controller.view.frame = rect;
        [self.view addSubview:controller.view];
        controller.hasMask = YES;
        
        __block CGRect frame = controller.view.frame;
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             frame.origin.y = 0.0f;
                             controller.view.frame = frame;
                         }
                         completion:^(BOOL finished) {
                             if (block) {
                                 block();
                             }
                             [controller viewDidAppear:YES];
                         }];
    }

}

- (void)dismissViewControllerWithOption:(ArtisanAnimationOption)option completion:(ArtisanBlock)block
{
    __block CGRect frame = self.view.frame;
    [self viewWillDisappear:YES];
    if (option == ArtisanAnimationOptionHorizontal) {
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             frame.origin.x = CGRectGetWidth(self.view.frame);
                             self.view.frame = frame;
                         }
                         completion:^(BOOL finished) {
                             if (block) {
                                block(); 
                             }
                             self.hasMask = NO;
                             self.parentController.childController = nil;
                             [self removeObserver:self.parentController forKeyPath:@"hasMask"];
                             [self.view removeObserver:self.parentController forKeyPath:@"frame"];
                             [self.view removeFromSuperview];
                             [self viewDidDisappear:YES];
                             [[ArtisanStack sharedInstance] pop:self];
                         }];
    }
    else if (option == ArtisanAnimationOptionVertical) {
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             frame.origin.y = CGRectGetHeight(self.view.frame);
                             self.view.frame = frame;
                         }
                         completion:^(BOOL finished) {
                             if (block) {
                                 block();
                             }
                             self.hasMask = NO;
                             self.parentController.childController = nil;
                             [self removeObserver:self.parentController forKeyPath:@"hasMask"];
                             [self.view removeObserver:self.parentController forKeyPath:@"frame"];
                             [self.view removeFromSuperview];
                             [self viewDidDisappear:YES];
                             [[ArtisanStack sharedInstance] pop:self];
                         }];
    }
}



#pragma mark -
#pragma mark - ArtisanStatusBarOverlay

- (void)postMessage:(NSString *)msg
{
    ArtisanStatusBarOverlay *overlay = [ArtisanStatusBarOverlay sharedInstance];
    [overlay postMessage:msg type:ArtisanStatusBarOverlayTypeInfo dismissAfterDelay:1.0f];

}

- (void)postMessage:(NSString *)msg type:(ArtisanStatusBarOverlayType)type
{
    ArtisanStatusBarOverlay *overlay = [ArtisanStatusBarOverlay sharedInstance];
    [overlay postMessage:msg type:type dismissAfterDelay:1.0f];
}

- (void)postMessage:(NSString *)msg type:(ArtisanStatusBarOverlayType)type  dismissAfterDelay:(int)delay
{
    ArtisanStatusBarOverlay *overlay = [ArtisanStatusBarOverlay sharedInstance];
    [overlay postMessage:msg type:type dismissAfterDelay:delay];
}

@end
