//
//  ArtisanSongsModel.h
//  Artisan
//
//  Created by roger on 13-8-2.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kArtisanLoadSongsSuccess @"ArtisanLoadSongsSuccess"
#define kArtisanLoadSongsFailed @"ArtisanLoadSongsFailed"

@interface ArtisanSongsData : NSObject
{
    NSString *_artist;
    NSString *_name;
    NSString *_length;
    NSString *_picture;
    NSString *_src;
}

@property (nonatomic, retain) NSString *artist;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *length;
@property (nonatomic, retain) NSString *picture;
@property (nonatomic, retain) NSString *src;

@end

@interface ArtisanSongsModel : NSObject
{
    NSMutableArray *_songs;
}

@property (nonatomic, retain) NSMutableArray *songs;

- (void) fetchSongs;
- (void) load:(NSURL *)url;

@end
