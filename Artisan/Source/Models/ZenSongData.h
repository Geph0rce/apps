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
    NSString *_hash;
    ZenSongStatus _status;
}

@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *length;
@property (nonatomic, strong) NSString *picture;
@property (nonatomic, strong) NSString *src;
@property (nonatomic, strong) NSString *hash;
@property (nonatomic, assign) ZenSongStatus status;

- (NSDictionary *)dictionary;

@end
