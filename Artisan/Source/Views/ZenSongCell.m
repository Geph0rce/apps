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
    self.backgroundColor = [UIColor clearColor];
    UIView *view = [[UIView alloc] initWithFrame:self.bounds];
    view.backgroundColor = kZenHighlightDaytime;
    self.selectedBackgroundView = view;
    _border.backgroundColor = kZenBorderColor;
    _name.font = kZenFont15;
    _artist.font = kZenFont13;
}


- (void)load:(ZenSongData *)song
{
    _name.text = song.name;
    _artist.text = song.artist;
    [_picture setImageWithURL:[NSURL URLWithString:song.picture] placeholderImage:[UIImage imageNamed:@"cover_default"]];
    
}

@end
