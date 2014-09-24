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
        [self loadOfflineList];
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

- (void)clear
{
    for (ZenSongData *song in _download) {
        if ([ZenOfflineModel songExists:song]) {
            [_download removeObject:song];
        }
    }
}

- (void)fetch
{
    [self clear];
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

- (void)loadOfflineList
{
    @try {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSArray *list = [ud objectForKey:kZenOfflineList];
        if (list) {
            for (NSDictionary *item in list) {
                ZenSongData *song = [[ZenSongData alloc] init];
                song.artist = item[@"artist"];
                song.name = item[@"name"];
                song.picture = item[@"picture"];
                song.hash = item[@"hash"];
                [_offline addObject:song];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"ZenOfflineModel loadOfflineList exception: %@", [exception description]);
    }

}

+ (NSURL *)urlForSong:(ZenSongData *)song
{
    NSString *path = [ZenOfflineModel sharedInstance].path;
    NSString *url = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", song.hash]];
    return [NSURL fileURLWithPath:url];
}

+ (BOOL)songExists:(ZenSongData *)song
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self pathForSong:song]];
}

+ (NSString *)pathForSong:(ZenSongData *)song
{
    NSString *path = [ZenOfflineModel sharedInstance].path;
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", song.hash]];
    return path;
}

- (NSDictionary *)dictionaryForSong:(ZenSongData *)song
{
    NSString *artist = song.artist == nil ? @"null" : song.artist;
    NSString *name = song.name == nil ? @"null" : song.name;
    NSString *picture = song.picture == nil ? @"null" : song.picture;
    NSString *hash = song.hash == nil ? @"null" : song.hash;
    
    return @{ @"artist" : artist, @"name" : name, @"picture" : picture, @"hash" : hash};
}

- (void)save:(ZenSongData *)song data:(NSData *)data
{
    @try {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        [fileManager createFileAtPath:[ZenOfflineModel pathForSong:song] contents:data attributes:nil];
        [_offline addObject:song];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSMutableArray *list = [NSMutableArray array];
        for (ZenSongData *song in _offline) {
            [list addObject:[self dictionaryForSong:song]];
        }
        [ud setObject:list forKey:kZenOfflineList];
        [ud synchronize];
    }
    @catch (NSException *exception) {
        NSLog(@"ZenOfflineModel save exception: %@", [exception description]);
    }
}

#pragma mark
#pragma mark ZenConnectionDelegate

- (void)requestDidFinished:(ZenConnection *)conn
{
    NSData *data = conn.responseData;
    if (data && _download.count > 0) {
        ZenSongData *song = _download[0];
        [self save:song data:data];
        [_download removeObjectAtIndex:0];
        [self send:kZenOfflineStateChange];
        [self fetch];
    }
}

- (void)requestDidFailed:(ZenConnection *)conn
{
    //NSLog(@"download failed");
    [self fetch];
}

@end
