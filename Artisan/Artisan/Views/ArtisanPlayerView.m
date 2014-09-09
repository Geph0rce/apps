//
//  ArtisanPlayerView.m
//  Artisan
//
//  Created by roger on 13-8-6.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "ArtisanPlayerView.h"

#define kArtisanPlayerControlOriginY  80
#define kArtisanPlayerPaddingLeft 16.0f
#define kArtisanPlayerPaddingTop 16.0f
#define kArtisanPlayerPaddingRight 16.0f
#define kArtisanPlayerPadding 20.0f

@interface ArtisanPlayerView ()
{
    UIButton *_back;
    UIButton *_play;
    UIButton *_next;
    UIButton *_prev;
    
    UILabel *_name;
    UILabel *_artist;
    UILabel *_time;
    UIImageView *_album;
}
@end


@implementation ArtisanPlayerView
@synthesize status = _status;
@synthesize delegate = _delegate;

- (void)dealloc
{
    _delegate = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = kArtisanMainColor;
        
        UILabel *name = [[UILabel alloc] init];
        _name = name;
        _name.frame = CGRectMake(kArtisanPlayerPaddingLeft, kArtisanPlayerPaddingTop, 220.0f, 16.0f);
        _name.font = kArtisanFont16;
        _name.backgroundColor = [UIColor clearColor];
        _name.textAlignment = NSTextAlignmentLeft;
        _name.textColor = [UIColor whiteColor];
        [self addSubview:_name];
        [name release];

        UILabel *artist = [[UILabel alloc] init];
        _artist = artist;
        _artist.frame = CGRectMake(kArtisanPlayerPaddingLeft, CGRectGetMaxY(_name.frame) + 5.0f, 220.0f, 13.0f);
        _artist.font = kArtisanFont13;
        _artist.backgroundColor = [UIColor clearColor];
        _artist.textAlignment = NSTextAlignmentLeft;
        _artist.textColor = [UIColor whiteColor];
        [self addSubview:_artist];
        [artist release];
        
        UILabel *time = [[UILabel alloc] init];
        _time = time;
        _time.frame = CGRectMake(240.0f, kArtisanPlayerPaddingTop, 80.0f, 16.0f);
        _time.font = kArtisanFont16;
        _time.backgroundColor = [UIColor clearColor];
        _time.textAlignment = NSTextAlignmentCenter;
        _time.textColor = [UIColor whiteColor];
        [self addSubview:time];
        [time release];
        
        CGFloat offsetX = kArtisanPlayerPaddingLeft;
        
        UIImageView *album = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, kArtisanPlayerControlOriginY - 8.0, 50.0f, 50.0f)];
        _album = album;
        [self addSubview:_album];
        [album release];
        
        offsetX = CGRectGetMaxX(_album.frame) + kArtisanPlayerPadding;
        
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setImage:[UIImage imageNamed:@"player_back"] forState:UIControlStateNormal];
        [back setImage:[UIImage imageNamed:@"player_back2"] forState:UIControlStateHighlighted];
        [back addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
        _back = back;
        back.frame = CGRectMake(offsetX, kArtisanPlayerControlOriginY, 34.0f, 34.0f);
        [self addSubview:_back];
        _back.tag = ArtisanPlayerControlTypeBack;
        
        offsetX = CGRectGetMaxX(_back.frame) + kArtisanPlayerPadding;
        
        UIButton *prev = [UIButton buttonWithType:UIButtonTypeCustom];
        [prev setImage:[UIImage imageNamed:@"prev"] forState:UIControlStateNormal];
        [prev setImage:[UIImage imageNamed:@"prev2"] forState:UIControlStateHighlighted];
        [prev addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
        _prev = prev;
        prev.frame = CGRectMake(offsetX, kArtisanPlayerControlOriginY, 34.0f, 34.0f);
        [self addSubview:_prev];
        _prev.tag = ArtisanPlayerControlTypePrev;
        
        offsetX = CGRectGetMaxX(_prev.frame) + kArtisanPlayerPadding;
        
        UIButton *play = [UIButton buttonWithType:UIButtonTypeCustom];
        [play setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [play setImage:[UIImage imageNamed:@"play2"] forState:UIControlStateHighlighted];
        [play addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
        _play = play;
        play.frame = CGRectMake(offsetX, kArtisanPlayerControlOriginY - 4.0f, 42.0f, 42.0f);
        [self addSubview:_play];
        _play.tag = ArtisanPlayerControlTypePlay;
        offsetX = CGRectGetMaxX(_play.frame) + kArtisanPlayerPadding;
        
        UIButton *next = [UIButton buttonWithType:UIButtonTypeCustom];
        [next setImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
        [next setImage:[UIImage imageNamed:@"next2"] forState:UIControlStateHighlighted];
        [next addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
        _next = next;
        next.frame = CGRectMake(offsetX, kArtisanPlayerControlOriginY, 34.0f, 34.0f);
        [self addSubview:_next];
        _next.tag = ArtisanPlayerControlTypeNext;
        //offsetX = CGRectGetMaxX(_next.frame) + kArtisanPlayerPadding;
        _isRecycle = NO;
    }
    return self;
}

- (void)setAlbumWithURL:(NSString *)url
{
    [_album setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"cover_default"]];
}

- (void)setName:(NSString *)name
{
    _name.text = name;
}

- (void)setArtist:(NSString *)artist
{
    _artist.text = artist;
}

- (void)setTime:(NSString *)time
{
    _time.text = time;
}

- (void)setStatus:(ArtisanPlayerStatus)status
{
    _status = status;
    if (_status == ArtisanPlayerStatusPlay) {
        [_play setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [_play setImage:[UIImage imageNamed:@"pause2"] forState:UIControlStateHighlighted];
    }
    else
    {
        [_play setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_play setImage:[UIImage imageNamed:@"play2"] forState:UIControlStateHighlighted];
    }
}

- (void)clicked:(id)sender
{
    UIView *view = (UIView *)sender;
    if (view == _back) {
        _isRecycle = !_isRecycle;
        [_back setImage:[UIImage imageNamed:(_isRecycle? @"player_back2" : @"player_back")] forState:UIControlStateNormal];
    }
    if ([_delegate respondsToSelector:@selector(playerControlClicked:)]) {
        [_delegate playerControlClicked:view.tag];
    }
}

@end
