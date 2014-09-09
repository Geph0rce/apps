//
//  ArtisanArtistsItem.m
//  Artisan
//
//  Created by roger on 13-8-19.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "UIColor+MLPFlatColors.h"
#import "ArtisanArtistsItem.h"

#define kArtisanArtistsItemFrame CGRectMake(0.0f, 0.0f, 320.0f, 70.0f)
#define kArtisanPictureSize CGSizeMake(50.0f, 50.0f)
#define kArtistColor ArtisanColorFromRGB(0x666666)
#define kArtisanStatusSize CGSizeMake(33.0f, 32.0f)


@interface ArtisanArtistsItem ()
{
    UIImageView *_picture;
    UILabel *_name;
    UILabel *_follower;
}
@end

@implementation ArtisanArtistsItem


- (void)dealloc
{
    _picture = nil;
    _name = nil;
    _follower = nil;
    
    [super dealloc];
}

- (id)init
{
    self = [super initWithFrame:kArtisanArtistsItemFrame];
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
        
        UILabel *follower = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_picture.frame) + 5.0f, CGRectGetMaxY(_name.frame) + 10.0f, 200.0f, 13.0f)];
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
        [self addSubview:border];
        [border release];
    }
    
    return self;
}

- (void)load:(ArtisanArtistData *)data
{
    _name.text = data.name;
    _follower.text = [NSString stringWithFormat:@"%@人关注", data.follower];
    
    [_picture setImageWithURL:[NSURL URLWithString:data.picture] placeholderImage:[UIImage imageNamed:@"cover_default"]];
}

@end
