//
//  ArtisanPlayerView.h
//  Artisan
//
//  Created by roger on 13-8-6.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ArtisanPlayerStatusPlay = 0,
    ArtisanPlayerStatusPause,
    ArtisanPlayerStatusStop
}ArtisanPlayerStatus;

typedef enum {
    ArtisanPlayerControlTypeBack = 0,
    ArtisanPlayerControlTypePrev,
    ArtisanPlayerControlTypePlay,
    ArtisanPlayerControlTypeNext
}ArtisanPlayerControlType;

@protocol ArtisanPlayerViewDelegate <NSObject>

- (void)playerControlClicked:(ArtisanPlayerControlType)type;

@end

@interface ArtisanPlayerView : UIView
{
    ArtisanPlayerStatus _status;
    NSObject<ArtisanPlayerViewDelegate> *_delegate;
    BOOL _isRecycle;
}

@property (nonatomic, assign) ArtisanPlayerStatus status;
@property (nonatomic, assign)  NSObject<ArtisanPlayerViewDelegate> *delegate;
@property (nonatomic, assign) BOOL isRecycle;

- (void)setTime:(NSString *)time;
- (void)setStatus:(ArtisanPlayerStatus)status;
- (void)setAlbumWithURL:(NSString *)url;
- (void)setName:(NSString *)name;
- (void)setArtist:(NSString *)artist;
@end
