//
//  ArtisanPlayerItem.m
//  Artisan
//
//  Created by roger on 13-8-14.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import "UIColor+MLPFlatColors.h"
#import "UIImageView+WebCache.h"
#import "ArtisanPlayerItem.h"

#define kArtisanPlayerItemFrame CGRectMake(0.0f, 0.0f, 320.0f, 70.0f)
#define kArtisanPictureSize CGSizeMake(50.0f, 50.0f)
#define kArtistColor ArtisanColorFromRGB(0x666666)


@interface ArtisanPlayerItem ()
{
    UIImageView *_picture;
    UILabel *_name;
    UILabel *_artist;
    UIImageView *_play;
    UIView *_hint;
}
@end

@implementation ArtisanPlayerItem


- (void)dealloc
{
    _picture = nil;
    _name = nil;
    _artist = nil;
    _play = nil;
    
    [super dealloc];
}

- (id)init
{
    self = [super initWithFrame:kArtisanPlayerItemFrame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *picture = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f , (CGRectGetHeight(self.frame) - kArtisanPictureSize.height) / 2.0f, kArtisanPictureSize.width, kArtisanPictureSize.height)];
        _picture = picture;
        [self addSubview:picture];
        [picture release];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_picture.frame) + 5.0f, CGRectGetMinY(_picture.frame) + 10.0f, 200.0f, 15.0f)];
        name.font = kArtisanFont15;
        name.backgroundColor = [UIColor clearColor];
        name.textAlignment = NSTextAlignmentLeft;
        name.textColor = [UIColor blackColor];
        _name = name;
        [self addSubview:name];
        [name release];
        
        UILabel *artist = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_picture.frame) + 5.0f, CGRectGetMaxY(_name.frame) + 5.0f, 200.0f, 13.0f)];
        artist.font = kArtisanFont13;
        artist.textColor = [UIColor flatGrayColor];
        artist.textAlignment = NSTextAlignmentLeft;
        _artist = artist;
        [self addSubview:artist];
        [artist release];
        
        UIView *hint = [[UIView alloc] initWithFrame:CGRectMake(2.0f, 10.0f, 6.0f, 50.0f)];
        _hint = hint;
        _hint.backgroundColor = kArtisanMainColor;
        _hint.hidden = YES;
        [self addSubview:_hint];
        [hint release];
        
        UIColor *border_bg = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_border"]];
        UIView *border = [[UIView alloc] initWithFrame:CGRectMake(15.0f, CGRectGetHeight(self.frame) - 1.0f, 290.0f, 1.0f)];
        border.backgroundColor = border_bg;
        [self addSubview:border];
        [border release];
        
    }
    return self;
}

- (void)load:(ArtisanSongsData *)data
{
    if (!data) {
        NSLog(@"data is nil");
        return;
    }
    
    _name.text = data.name;
    _artist.text = data.artist;
    [_picture setImageWithURL:[NSURL URLWithString:data.picture] placeholderImage:[UIImage imageNamed:@"cover_default"]];
    _hint.hidden = YES;
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (_selected) {
        _hint.hidden = NO;
    }
    else
    {
        _hint.hidden = YES;
    }
}

@end
