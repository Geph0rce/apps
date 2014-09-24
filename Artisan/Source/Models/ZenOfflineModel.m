//
//  ZenOfflineModel.m
//  Artisan
//
//  Created by roger on 14-9-24.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "Singleton.h"
#import "ZenCategory.h"
#import "ZenConnection.h"
#import "ZenOfflineModel.h"

#define kZenOfflineList @"ZenOffLineList"

@interface ZenOfflineModel () <ZenConnectionDelegate>
{
    ZenConnection *_connection;
    NSString *_path;
}

@property (nonatomic, strong) ZenConnection *connection;
@property (nonatomic, strong) NSString *path;

@end

@implementation ZenOfflineModel

SINGLETON_FOR_CLASS(ZenOfflineModel)

- (id)init
{
    self = [super init];
    if (self) {
        _offline = [[NSMutableArray alloc] init];
        _download = [[NSMutableArray alloc] init];
        [self initPath];
    }
    return self;
}

- (BOOL)contains:(ZenSongData *)song
{
    for (ZenSongData *item in _download) {
        if ([item.hash isEqualToString:song.hash]) {
            return YES;
        }
    }
    return NO;
}

- (void)addToDownloadQueue:(NSMutableArray *)songs
{
    if (songs && [songs isKindOfClass:[NSArray class]]) {
        
        for (ZenSongData *song in songs) {
            if (![self contains:song]) {
                [_download addObject:song];
            }
        }
    }
}

- (void)fetch
{
    if (_download.count > 0) {
        ZenSongData *song = _download[0];
        ZenConnection *conn = [ZenConnection connectionWithURL:[NSURL URLWithString:song.src]];
        conn.delegate = self;
        self.connection = conn;
        [conn startAsynchronous];
    }
    else {
        [self send:kZenOfflineStateChange];
    }
}

- (void)offline:(NSMutableArray *)songs
{
    @try {
        if (_download.count > 0) {
            [self send:kZenOfflineDownloading];
            return;
        }
        [_download addObjectsFromArray:songs];
        [self fetch];
    }
    @catch (NSException *exception) {
        NSLog(@"ZenOfflineModel offline exception: %@", [exception description]);
    }
}

- (void)initPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    self.path = [paths[0] stringByAppendingPathComponent:@"offline"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:_path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:_path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
}

- (NSURL *)urlForSong:(ZenSongData *)song
{
    NSString *url = [_path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", song.hash]];
    return [NSURL fileURLWithPath:url];
}

- (NSString *)pathForSong:(ZenSongData *)song
{
    NSString *path = [_path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", song.hash]];
    return path;
}

- (void)save:(ZenSongData *)song data:(NSData *)data
{
    @try {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        [fileManager createFileAtPath:[self pathForSong:song] contents:data attributes:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"ZenOfflineModel save exception: %@", [exception description]);
    }
}

#pragma mark
#pragma mark ZenConnectionDelegate

- (void)requestDidFinished:(ZenConnection *)conn
{
    NSData *song = conn.responseData;
    if (song && _download.count > 0) {

        [self save:_download[0] data:song];
        [_download removeObjectAtIndex:0];
        [self fetch];
    }
}

- (void)requestDidFailed:(ZenConnection *)conn
{
    NSLog(@"download failed");
}

@end
