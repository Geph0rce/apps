//
//  ArtisanNavigationBar.m
//  Artisan
//
//  Created by roger on 13-8-5.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//
#import "UIColor+MLPFlatColors.h"
#import "ArtisanNavigationBar.h"

#define kDefaultBarColor ArtisanColorFromRGB(0x1abc9c)
#define kHighiteBarColor  ArtisanColorFromRGB(0x16a085) 

@implementation ArtisanNavigationBar

- (id)init
{
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    
    if (self) {
        [self setBackgroundColor:kDefaultBarColor];
    }

    return self;
}

- (void)addHomeItemWithTarget:(id)target action:(SEL)action
{
    UIImage *menuImage =  [UIImage imageNamed:@"menu"];
    [_leftBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [_leftIcon setImage:menuImage];
}

- (void)addBackItemWithTarget:(id)target action:(SEL)action
{
    UIImage *backImage = [UIImage imageNamed:@"back"];
    [_leftBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [_leftIcon setImage:backImage];
}

- (void)addLeftItemWithStyle:(ArtisanNavigationItemStyle)style target:(id)target action:(SEL)action
{
    if (_leftBtn) {
        NSLog(@"leftBtn already exists.");
        return;
    }
    UIImageView *leftIcon = [[UIImageView alloc] initWithFrame:CGRectMake(11.0f, 8.0f, 30.0f, 30.0f)];
    _leftIcon = leftIcon;        
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn addSubview:_leftIcon];
    [leftIcon release];
    _leftBtn = leftBtn;
    [_leftBtn setBackgroundImage:[UIImage imageWithColor:kHighiteBarColor]forState:UIControlStateHighlighted];
   
    [leftBtn setFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_leftIcon.frame) + 22.0f, 44.0f)];
    [self addSubview:_leftBtn];
    switch (style) {
        case ArtisanNavigationItemStyleMenu:
            [self addHomeItemWithTarget:target action:action];
            break;
        case ArtisanNavigationItemStyleBack:
            [self addBackItemWithTarget:target action:action];
            break;
        default:
            break;
    }
}


- (void) addRightItemWithStyle:(ArtisanNavigationItemStyle)style target:(id)target action:(SEL)action
{
    [self addRightItemWithStyle:style middle:NO target:target action:action];
}


- (void)addRightItemWithStyle:(ArtisanNavigationItemStyle)style middle:(BOOL)middle target:(id)target action:(SEL)action
{
    if (_rightBtn) {
        NSLog(@"rightBtn already exists.");
        return;
    }
    
    UIImageView *rightIcon = [[UIImageView alloc] init];
    _rightIcon = rightIcon;        
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn addSubview:_rightIcon];
    [rightIcon release];
    _rightBtn = rightBtn;
    [_rightBtn setBackgroundImage:[UIImage imageWithColor:[UIColor flatDarkWhiteColor]] forState:UIControlStateHighlighted];
    
    CGFloat originX = 0.0f;
    CGFloat width = 0.0f;
    if (middle) {
        [_rightIcon setFrame:CGRectMake(11.0f, 6.0f, 30.0f, 30.0f)];
        width = CGRectGetWidth(_rightIcon.frame) + 12.0f;
        originX = CGRectGetWidth(self.frame) - width - 44.0f;
    }
    else
    {
        [_rightIcon setFrame:CGRectMake(6.0f, 8.0f, 30.0f, 30.0f)];
        width = CGRectGetWidth(_rightIcon.frame) + 22.0f;
        originX = CGRectGetWidth(self.frame) - width;
    }
    
    [rightBtn setFrame:CGRectMake(originX , 0.0f, width, 44.0f)];
    [self addSubview:_rightBtn];
    
    switch (style) {
        case ArtisanNavigationItemStyleSafari:
            [_rightBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
            [_rightIcon setImage:[UIImage imageNamed:@"safari"]];
            break;
        case ArtisanNavigationItemStyleShare:
            [_rightBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
            [_rightIcon setImage:[UIImage imageNamed:@"share"]];
            break;
        case ArtisanNavigationItemStyleRefresh:
            [_rightBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
            [_rightIcon setImage:[UIImage imageNamed:@"refresh"]];
            break;
        default:
            break;
    }
 
}

- (void)setTitle:(NSString *)title
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor flatBlackColor];
    CGSize size = [title sizeWithFont:kArtisanFont19 constrainedToSize:CGSizeMake(220.0f, 40.0f)];
    label.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
    label.text = title;
    label.center = CGPointMake(CGRectGetWidth(self.frame)/2.0f, CGRectGetHeight(self.frame)/2.0f);
    [self addSubview:label];
    [label release];
}

@end
