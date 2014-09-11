//
//  ZenSongData.h
//  Artisan
//
//  Created by roger on 14-9-9.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ZenSongStatusNone,
    ZenSongStatusPlay,
    ZenSongStatusPause
} ZenSongStatus;

@interface ZenSongData : NSObject
{
    NSString *_artist;
    NSString *_name;
    NSString *_length;
    NSString *_picture;
    NSString *_src;
    ZenSongStatus _status;
}

@property (nonatomic, retain) NSString *artist;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *length;
@property (nonatomic, retain) NSString *picture;
@property (nonatomic, retain) NSString *src;
@property (nonatomic, assign) ZenSongStatus status;

@end
