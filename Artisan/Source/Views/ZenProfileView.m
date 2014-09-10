//
//  ZenProfileView.m
//  Artisan
//
//  Created by roger on 14-9-10.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "ZenMacros.h"
#import "ZenProfileView.h"

@implementation ZenProfileView

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    _border.backgroundColor = kZenBorderColor;
}

- (void)load:(ZenArtistData *)artist
{
    [_picture setImageWithURL:[NSURL URLWithString:artist.picture] placeholderImage:[UIImage imageNamed:@"cover_default"]];
    _name.text = artist.name;
    _follower.text = [NSString stringWithFormat:@"%@人关注", artist.follower];
    _style.text = artist.style;
}

@end
