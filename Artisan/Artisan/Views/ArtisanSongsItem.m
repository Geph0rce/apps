//
//  ArtisanSongsItem.m
//  Artisan
//
//  Created by roger on 13-8-2.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import "UIColor+MLPFlatColors.h"
#import "UIImageView+WebCache.h"
#import "ArtisanSongsItem.h"

#define kArtisanSongsItemFrame CGRectMake(0.0f, 0.0f, 320.0f, 70.0f)
#define kArtisanPictureSize CGSizeMake(50.0f, 50.0f)
#define kArtistColor ArtisanColorFromRGB(0x666666) 
#define kArtisanStatusSize CGSizeMake(33.0f, 32.0f)


@interface ArtisanSongsItem ()
{
    UIImageView *_picture;
    UILabel *_name;
    UILabel *_artist;
    UIImageView *_play;
    UIImageView *_status;
}
@end

@implementation ArtisanSongsItem

- (void)dealloc
{
    _picture = nil;
    _name = nil;
    _artist = nil;
    _play = nil;
    _status = nil;
    [super dealloc];
}

- (id)init
{
    self = [super initWithFrame:kArtisanSongsItemFrame];
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
        artist.backgroundColor = [UIColor clearColor];
        artist.textAlignment = NSTextAlignmentLeft;
        _artist = artist;
        [self addSubview:artist];
        [artist release];
        
        UIColor *border_bg = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_border"]];
        UIView *border = [[UIView alloc] initWithFrame:CGRectMake(15.0f, CGRectGetHeight(self.frame) - 1.0f, 290.0f, 1.0f)];
        border.backgroundColor = border_bg;
        [self addSubview:border];
        [border release];
        
        UIImageView *status = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - kArtisanStatusSize.width - 10.0f) , (CGRectGetHeight(self.frame) - kArtisanStatusSize.height) / 2.0f, kArtisanStatusSize.width, kArtisanStatusSize.height)];
        _status = status;
        [self addSubview:status];
        [status release];
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
    _status.hidden = YES;
}

- (void)setStatus:(ArtisanSongsItemStutus)status
{
    _status.hidden = NO;
    if (status == ArtisanSongsItemStutusPlay) {
        _status.image = [UIImage imageNamed:@"status_play"];
    }
    else if(status == ArtisanSongsItemStutusPause) {
        _status.image = [UIImage imageNamed:@"status_pause"];
    }
    else {
        _status.hidden = YES;
    }
}

@end
