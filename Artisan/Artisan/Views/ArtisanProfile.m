//
//  ArtisanProfile.m
//  Artisan
//
//  Created by roger on 13-8-20.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import "UIColor+MLPFlatColors.h"
#import "UIImageView+WebCache.h"

#import "ArtisanProfile.h"

#define kArtisanPictureSize CGSizeMake(50.0f, 50.0f)
#define kArtistColor ArtisanColorFromRGB(0x666666)
#define kArtisanStatusSize CGSizeMake(33.0f, 32.0f)

@interface ArtisanProfile ()
{
    UIImageView *_picture;
    UILabel *_name;
    UILabel *_style;
    UILabel *_follower;
    UIView *_border;
}

@end

@implementation ArtisanProfile

- (void)dealloc
{
    _picture = nil;
    _name = nil;
    _style = nil;
    _follower = nil;
    _border = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *picture = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f , (CGRectGetHeight(self.frame) - kArtisanPictureSize.height) / 2.0f, kArtisanPictureSize.width, kArtisanPictureSize.height)];
        _picture = picture;
        [self addSubview:picture];
        [picture release];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_picture.frame) + 5.0f, CGRectGetMinY(_picture.frame) + 0.0f, 200.0f, 15.0f)];
        name.font = kArtisanFont15;
        name.backgroundColor = [UIColor clearColor];
        name.textAlignment = NSTextAlignmentLeft;
        name.textColor = [UIColor blackColor];
        _name = name;
        [self addSubview:name];
        [name release];
        
        UILabel *style = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_picture.frame) + 5.0f, CGRectGetMaxY(_name.frame) + 5.0f, 200.0f, 13.0f)];
        style.font = kArtisanFont13;
        style.textColor = [UIColor flatGrayColor];
        style.textAlignment = NSTextAlignmentLeft;
        style.backgroundColor = [UIColor clearColor];
        _style = style;
        [self addSubview:style];
        [style release];
        
        UILabel *follower = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_picture.frame) + 5.0f, CGRectGetMaxY(_style.frame) + 5.0f, 200.0f, 13.0f)];
        follower.font = kArtisanFont13;
        follower.textColor = [UIColor flatGrayColor];
        follower.textAlignment = NSTextAlignmentLeft;
        follower.backgroundColor = [UIColor clearColor];
        _follower = follower;
        [self addSubview:follower];
        [follower release];
        
        UIColor *border_bg = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_border"]];
        UIView *border = [[UIView alloc] initWithFrame:CGRectMake(15.0f, CGRectGetHeight(self.frame) - 1.0f, 290.0f, 1.0f)];
        border.backgroundColor = border_bg;
        border.hidden = YES;
        [self addSubview:border];
        _border = border;
        [border release];
    }
    
    return self;
}

- (void)load:(ArtisanProfileData *)data
{
    _name.text = data.name;
    _follower.text = [NSString stringWithFormat:@"%@人关注", data.follower];
    _style.text = data.style;
    [_picture setImageWithURL:[NSURL URLWithString:data.picture] placeholderImage:[UIImage imageNamed:@"cover_default"]];
    _border.hidden = NO;
}


@end
