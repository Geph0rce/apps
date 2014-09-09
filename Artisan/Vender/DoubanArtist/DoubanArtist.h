//
//  DoubanArtist.h
//  Artisan
//
//  Created by roger on 13-8-2.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kDoubanArtistBaseURL @"http://music.douban.com/api/artist"

@interface DoubanArtist : NSObject

- (void)test;

+ (DoubanArtist *)sharedInstance;

- (NSString *)artists;
- (NSString *)songs;
- (NSString *)genre:(NSString *)gid;
- (NSString *)playlist:(NSString *)aid;
- (NSString *)songs:(NSString *)pid;

@end
