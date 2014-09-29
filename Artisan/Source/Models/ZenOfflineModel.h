//
//  ZenOfflineModel.h
//  Artisan
//
//  Created by roger on 14-9-24.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "ZenOfflineArtistData.h"
#import "ZenSongData.h"
#import "ZenBaseModel.h"

#define kZenOfflineDownloading @"ZenOfflineDownloading"
#define kZenOfflineStateChange @"ZenOfflineStateChange"


@interface ZenOfflineModel : ZenBaseModel
{
    NSMutableArray *_offline;
    NSMutableArray *_download;
    NSMutableArray *_artists;
}

@property (nonatomic, strong) NSMutableArray *offline;
@property (nonatomic, strong) NSMutableArray *download;
@property (nonatomic, strong) NSMutableArray *artists;

+ (ZenOfflineModel *)sharedInstance;
+ (NSURL *)urlForSong:(ZenSongData *)song;

/**
 *  check if song exists at local store
 *
 *  @param song ZenSongData instance
 *
 *  @return YES - if exists
 */
+ (BOOL)songExists:(ZenSongData *)song;

/**
 *  check if song exists at _offline or _download queue
 *
 *  @param song ZenSongData instance
 *
 *  @return YES - if exists
 */
- (BOOL)exists:(ZenSongData *)song;
- (void)offline:(NSArray *)songs;
- (void)removeOfflineObjectAtIndex:(NSUInteger)index;
- (void)removeDownloadingObjectAtIndex:(NSUInteger)index;

@end
