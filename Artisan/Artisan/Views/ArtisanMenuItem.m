//
//  ArtisanMenuItem.m
//  Artisan
//
//  Created by roger qian on 13-3-29.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import "ArtisanMenuItem.h"

#define kArtisanMenuMarginX 16.0f
#define kArtisanMenuLeftBtnWidth 58.0f
#define kArtisanMenuLeftBtnHeight 58.0f
#define kArtisanMenuPaddingLeft 1.0f
#define kArtisanMenuRightBtnWidth 130.0f
#define kArtisanMenuRightBtnHeight 58.0f

@implementation ArtisanMenuItem

- (void)dealloc
{
    [super dealloc];
}


- (void)setImage:(UIImage *)image
{
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftBtn = leftBtn;
    _leftBtn.frame = CGRectMake(0.0f, 0.0f, kArtisanMenuLeftBtnWidth, kArtisanMenuLeftBtnHeight);
        
    UIImageView *logo = [[UIImageView alloc] initWithImage:image];
    logo.center = CGPointMake(CGRectGetMidX(_leftBtn.frame), CGRectGetMidY(_leftBtn.frame));
    [_leftBtn addSubview:logo];
    
    CGPoint center = CGPointMake(CGRectGetWidth(leftBtn.frame)/2.0f, CGRectGetHeight(leftBtn.frame)/2.0f);
    logo.center = center;
    [self addSubview:leftBtn];
    [logo release];
}

- (void)setTitle:(NSString *)text
{
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn = rightBtn;
    _rightBtn.frame = CGRectMake(kArtisanMenuLeftBtnWidth + kArtisanMenuPaddingLeft, 0.0f, kArtisanMenuRightBtnWidth, kArtisanMenuRightBtnHeight);
    UILabel *title = [[UILabel alloc] init];
    [title setFont:kArtisanFont19];
    CGSize size = [text sizeWithFont:kArtisanFont19 constrainedToSize:CGSizeMake(kArtisanMenuRightBtnWidth - 20.0f, kArtisanMenuRightBtnHeight)];
    title.textColor = [UIColor whiteColor];
    title.text = text;
    title.backgroundColor = [UIColor clearColor];
    [title setFrame:CGRectMake(kArtisanMenuMarginX, 0.0f, size.width, size.height)];
    CGPoint center = title.center;
    center.y = kArtisanMenuLeftBtnHeight/2.0f;
    [_rightBtn addSubview:title];
    title.center = center;
    [title release];
    [self addSubview:_rightBtn];
}

- (void)setColor:(UIColor *)color highlight:(UIColor *)hl
{
    [_leftBtn setBackgroundImage:[UIImage imageWithColor:color] forState:UIControlStateNormal];
    [_leftBtn setBackgroundImage:[UIImage imageWithColor:hl] forState:UIControlStateHighlighted];
    
    [_rightBtn setBackgroundImage:[UIImage imageWithColor:color] forState:UIControlStateNormal];
    [_rightBtn setBackgroundImage:[UIImage imageWithColor:hl] forState:UIControlStateHighlighted];

}

- (void)addTarget:(id)target action:(SEL)action
{
    [_leftBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [_rightBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

}

@end
