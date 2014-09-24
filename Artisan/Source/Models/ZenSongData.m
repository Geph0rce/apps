//
//  ZenSongData.m
//  Artisan
//
//  Created by roger on 14-9-9.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "ZenSongData.h"

@implementation ZenSongData
NSString *_artist;
NSString *_name;
NSString *_length;
NSString *_picture;
NSString *_src;
NSString *_hash;

- (NSDictionary *)dictionary
{
    NSString *artist = _artist == nil ? @"null" : _artist;
    NSString *name = _name == nil ? @"null" : _name;
    NSString *picture = _picture == nil ? @"null" : _picture;
    NSString *hash = _hash == nil ? @"null" : _hash;
    return @{ @"artist" : artist, @"name" : name, @"picture" : picture, @"hash" : hash };
}

@end
