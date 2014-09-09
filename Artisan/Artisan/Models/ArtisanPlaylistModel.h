//
//  ArtisanPlaylistModel.h
//  Artisan
//
//  Created by roger on 13-8-20.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kArtisanLoadPlaylistsSuccess @"ArtisanLoadPlaylistsSuccess"
#define kArtisanLoadPlaylistsFailed @"ArtisanLoadPlaylistsFailed"

@interface ArtisanPlaylistData : NSObject
{
    NSString *_pid;
    NSString *_title;
}

@property (nonatomic, retain) NSString *pid;
@property (nonatomic, retain) NSString *title;

@end

@interface ArtisanProfileData : NSObject
{
    NSString *_picture;
    NSString *_name;
    NSString *_style;
    NSString *_follower;
}

@property (nonatomic, retain) NSString *picture;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *style;
@property (nonatomic, retain) NSString *follower;

@end

@interface ArtisanPlaylistModel : NSObject
{
    ArtisanProfileData *_profile;
    NSMutableArray *_playlists;
}

@property (nonatomic, retain) ArtisanProfileData *profile;
@property (nonatomic, retain) NSMutableArray *playlists;

- (void)load:(NSURL *)url;

@end
