//
//  PandoraAccountsHeader.m
//  Zen
//
//  Created by roger on 14-7-10.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "ZenMacros.h"
#import "ZenCategory.h"
#import "PandoraColors.h"
#import "PandoraAccountsHeader.h"

#define kPandoraAccountsHeaderFrame (kZenDeviceiPad? CGRectMake(0.0f, 0.0f, 768.0f, 60.0f) : CGRectMake(0.0f, 0.0f, kZenScreenWidth, 60.0f))

@interface PandoraAccountsHeader ()
{
    UIButton *_addButton;
    UIImageView *_indicator;
    UILabel *_title;
}

@end

@implementation PandoraAccountsHeader

- (id)init
{
    self = [super initWithFrame:kPandoraAccountsHeaderFrame];
    if (self) {
        self.backgroundColor = kPandoraColorRealBlue;
        UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addBtn.frame = CGRectMake(20.0f, 0.0f, 32.0f, 32.0f);
        _addButton = addBtn;
        [addBtn setImage:[UIImage imageNamed:@"action_add"] forState:UIControlStateNormal];
        [self addSubview:addBtn];
        [_addButton centerInVertical];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_addButton.frame) + 10.0f, 0.0f, 200.0f, 16.0f)];
        title.font = kZenFont15;
        title.backgroundColor = [UIColor clearColor];
        title.textAlignment = NSTextAlignmentLeft;
        title.textColor = [UIColor whiteColor];
        _title = title;
        [self addSubview:title];
        [_title centerInVertical];
        
        UIImageView *indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_icon"]];
        _indicator = indicator;
        CGRect rect = indicator.frame;
        CGFloat x = CGRectGetWidth(kPandoraAccountsHeaderFrame) - CGRectGetWidth(indicator.frame) - 20.0f;
        rect.origin.x = x;
        indicator.frame = rect;
        [self addSubview:indicator];
        [indicator centerInVertical];
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action
{
    if (_addButton) {
        [_addButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setTitle:(NSString *)title
{
    [_title setText:title];
}

@end
