//
//  ArtisanLoadingView.m
//  Artisan
//
//  Created by roger on 13-8-19.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import "ArtisanLoadingView.h"

#define kArtisanLoadingViewColor     [UIColor colorWithRed:CGColorConvert(217.0f) green:CGColorConvert(217.0f) blue:CGColorConvert(216.0f) alpha:0.8f]

@interface ArtisanLoadingView ()
{
    UIActivityIndicatorView *_indicator;
}
@end


@implementation ArtisanLoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kArtisanLoadingViewColor;
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicator setFrame:CGRectMake(20.0f, 5.0f, 20.0f, 20.0f)];
        [self addSubview:indicator];
        _indicator = indicator;
        [indicator release];
        
       
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.font = kArtisanFont13;
        label.frame = CGRectMake(0.0f, 0.0f, 240.0f, 13.0f);
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"正在加载...";
        label.center = CGPointMake(CGRectGetWidth(frame)/2.0f, CGRectGetHeight(frame)/2.0f);
        [self addSubview:label];
        [label release];
    }
    return self;
}


#pragma mark -
#pragma mark Show and Hide animation

- (void)show
{
    self.hidden = NO;
    CGPoint center = self.center;
    center.y = CGRectGetHeight(self.frame)/2.0f;
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.center = center;
                         [_indicator startAnimating];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
}


- (void)hide
{
    CGPoint center = self.center;
    center.y = -CGRectGetHeight(self.frame)/2.0f;
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [_indicator stopAnimating];
                         self.center = center;
                     }
                     completion:^(BOOL finished) {
                         self.hidden = YES;
                     }];
    
}


@end
