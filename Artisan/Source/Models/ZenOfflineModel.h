//
//  ZenOfflineModel.h
//  Artisan
//
//  Created by roger on 14-9-24.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "ZenSongData.h"
#import "ZenBaseModel.h"

#define kZenOfflineDownloading @"ZenOfflineDownloading"
#define kZenOfflineStateChange @"ZenOfflineStateChange"


@interface ZenOfflineModel : ZenBaseModel
{
    NSMutableArray *_offline;
    NSMutableArray *_download;
}

@property (nonatomic, strong) NSMutableArray *offline;
@property (nonatomic, strong) NSMutableArray *download;

+ (ZenOfflineModel *)sharedInstance;
- (void)offline:(NSMutableArray *)songs;
+ (NSURL *)urlForSong:(ZenSongData *)song;
+ (BOOL)songExists:(ZenSongData *)song;

@end