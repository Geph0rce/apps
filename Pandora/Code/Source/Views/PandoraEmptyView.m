//
//  PandoraEmptyView.m
//  Zen
//
//  Created by roger on 14-7-10.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "ZenMacros.h"
#import "ZenCategory.h"
#import "PandoraEmptyView.h"

#define kPandoraEmptyViewFrame CGRectMake(0.0f, 0.0f, 200.0f, 136.0f)

@interface PandoraEmptyView ()
{
    UILabel *_title;
}
@end

@implementation PandoraEmptyView

- (id)init
{
    self = [super initWithFrame:kPandoraEmptyViewFrame];
    if (self) {
        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"empty_normal"]];
        [self addSubview:logo];
        [logo centerInHorizontal];
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(logo.frame) + 20.0f, 200.0f, 16.0f)];
        title.font = kZenFont15;
        title.backgroundColor = [UIColor clearColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.textColor = [UIColor whiteColor];
        _title = title;
        [self addSubview:title];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    [_title setText:title];
}

@end
