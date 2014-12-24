//
//  PandoraFileListModel.m
//  Zen
//
//  Created by roger on 14-7-14.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "ZenCategory.h"
#import "PandoraConnection.h"
#import "PandoraFileListModel.h"

@implementation PandoraFile

@end

#define kPandoraFileListURL @"http://pan.baidu.com/api/list?order=time&desc=1&web=1&dir=%@"

@interface PandoraFileListModel () <PandoraConnectionDelegate>
{
    PandoraConnection *_connection;
}

@property (nonatomic, strong) PandoraConnection *connection;

@end

@implementation PandoraFileListModel

- (id)init
{
    self = [super init];
    if (self) {
        _files = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (NSString *)themeWithFile:(PandoraFile *)file
{
    if (file.thumb) {
        // if contains thumb
        return file.thumb;
    }
    if (file.isdir) {
        // directiory
        return @"file_filefolder_icon";
    }
    else if (file.category == PandoraFileTypeAudio) {
        return @"file_audiofile_icon";
    }
    else if (file.category == PandoraFileTypeVideo) {
        return @"file_videofile_icon";
    }
    else {
        return @"icon_unknow";
    }
}

- (NSString *)size:(long long)size
{
    NSString *suffix = @"B";
    double result = 0.0f;
    if (size > 1024) {
        suffix = @"KB";
        result = size * 1.0f / 1024.0f; // KB
        if (result > 1024.0f) {
            suffix = @"MB";
            result = result / 1024.0f; // MB
            if (result > 1024.0f) {
                suffix = @"GB";
                result = result / 1024.0f; // GB
            }
        }
    }
    return [NSString stringWithFormat:@"%.1f %@", result, suffix];
}

- (void)load:(NSString *)dir
{
    if (!_token || [_token isEqualToString:@""]) {
        // token is invalid
        NSLog(@"PandoraFileListModel load: token is invalid.");
        [self send:kPandoraFileListLoadFailed];
        return;
    }
    
    if (!dir || [dir isEqualToString:@""]) {
        // dir is invalid
        NSLog(@"PandoraFileListModel load: dir is invalid.");
        [self send:kPandoraFileListLoadFailed];
        return;
    }
    
    NSString *url = [NSString stringWithFormat:kPandoraFileListURL, [dir urlEncode]];
    PandoraConnection *conn = [PandoraConnection connectionWithURL:[NSURL URLWithString:url]];
    self.connection = conn;
    conn.delegate = self;
    conn.shouldHandleCookies = NO;
    [conn addRequestHeader:@"Cookie" value:_token];
    [conn startAsynchronous];
}

#pragma mark
#pragma mark PandoraConnectionDelegate Methods

- (void)requestDidFinished:(PandoraConnection *)connection
{
    @try {
        NSLog(@"response: %@", connection.responseString);
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:connection.responseData options:NSJSONReadingAllowFragments error:NULL];
        if (response) {
            int error = [response intForKey:@"errno"];
            if (error != 0) {
                // shit happens
                [self send:kPandoraFileListLoadFailed];
                return;
            }
            
            [_files removeAllObjects];
            NSArray *list = response[@"list"];
            for (NSDictionary *file in list) {
                PandoraFile *item = [[PandoraFile alloc] init];
                item.fsId = [file stringForKey:@"fs_id"];
                item.path = [file stringForKey:@"path"];
                item.name = [file stringForKey:@"server_filename"];
                item.category = [file intForKey:@"category"];
                item.isdir = [file intForKey:@"isdir"] == 0? NO : YES;
                long long size = [file longLongForKey:@"size"];
                item.size = [self size:size];
                NSDictionary *thumbs = [file objectForKey:@"thumbs"];
                if ([thumbs has:@"url2"]) {
                    item.thumb = thumbs[@"url2"];
                }
                [_files addObject:item];
            }
            [self send:kPandoraFileListLoadFinished];
            return;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"PandoraFileListModel load exception: %@", [exception description]);
    }
    [self send:kPandoraFileListLoadFailed];
}

- (void)requestDidFailed:(PandoraConnection *)connection
{
    NSLog(@"PandoraFileListModel: network error");
    [self send:kPandoraFileListLoadFailed];
}

@end
