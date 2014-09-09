//
//  ZenSongCell.m
//  Artisan
//
//  Created by roger on 14-9-9.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "ZenMacros.h"
#import "ZenSongCell.h"

@implementation ZenSongCell

- (void)awakeFromNib
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - 1.0f)];
    view.backgroundColor = kZenHighlightDaytime;
    self.selectedBackgroundView = view;
    
    UIView *backView = [[UIView alloc] init];
    UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_border"]];
    backView.frame = _border.frame;
    backView.backgroundColor = color;
    [self addSubview:backView];
}


- (void)load:(ZenSongData *)song
{
    _name.text = song.name;
    _artist.text = song.artist;
    [_picture setImageWithURL:[NSURL URLWithString:song.picture] placeholderImage:[UIImage imageNamed:@"cover_default"]];
    
}

@end
