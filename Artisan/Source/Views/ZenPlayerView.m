//
//  ZenPlayerView.m
//  Artisan
//
//  Created by roger on 14-9-11.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "ZenMacros.h"
#import "ZenPlayerView.h"

#define kZenGreenBackgroundColor ZenColorFromRGB(0x1abc9c)

@implementation ZenPlayerView

- (void)awakeFromNib
{
    self.backgroundColor = kZenGreenBackgroundColor;
    _name.font = kZenFont15;
    _artist.font = kZenFont13;
    _timeLabel.font = kZenFont15;
    CALayer *layer = _picture.layer;
    layer.masksToBounds = YES;
    layer.cornerRadius = 25.0f;
}

- (void)load:(ZenSongData *)song
{
    _name.text = song.name;
    _artist.text = song.artist;
    [_picture setImageWithURL:[NSURL URLWithString:song.picture] placeholderImage:[UIImage imageNamed:@"cover_default"]];
}

@end
