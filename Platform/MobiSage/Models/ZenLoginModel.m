//
//  ZenLoginModel.m
//  MobiSage
//
//  Created by roger on 14-8-25.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "ZenCategory.h"
#import "ZenConnection.h"
#import "ZenLoginModel.h"

#define kMobiSageURL @"http://mobi.adsage.cn/Account/Login"
#define kLimeiURL @"http://platform.limei.com/index.php?c=site&a=login"

@interface ZenLoginModel () <ZenConnectionDelegate>
{
    ZenConnection *_connection;
    ZenLoginType _type;
}

@property (nonatomic, strong) ZenConnection *connection;

@end

@implementation ZenLoginModel

//ef9506577bb603946bc9a8b1332387c4
- (NSData *)body:(NSString *)username password:(NSString *)password type:(ZenLoginType)type
{
    NSString *body = nil;
    
    if (type == ZenLoginTypeAdsage) {
        
        body = [NSString stringWithFormat:@"UserName=%@&Password=%@&RememberMe=true", username, [password md5]];
    }
    else {
        body = [[NSString stringWithFormat:@"login2=1&login[email]=%@&login[password]=%@", username, password] urlEncode];
    }
    return [body dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)login:(NSString *)username password:(NSString *)password type:(ZenLoginType)type
{
    _type = type;
    NSString *url = (type == ZenLoginTypeAdsage)? kMobiSageURL : kLimeiURL;
    ZenConnection *connection = [ZenConnection connectionWithURL:[NSURL URLWithString:url]];
    self.connection = connection;
    connection.delegate = self;
    connection.httpMethod = @"POST";
    connection.shouldHandleCookies = YES;
    connection.httpBody = [self body:username password:password type:type];
    [connection addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=UTF-8"];
    connection.didFailedSelector = @selector(loginFailed:);
    connection.didFinishedSelector = @selector(loginResponse:);
    [connection startAsynchronous];
}

- (void)loginResponse:(ZenConnection *)connection
{
    @try {
        if (_type == ZenLoginTypeLimei) {
            [self send:kZenLoginSuccess];
            return;
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:connection.responseData options:NSJSONReadingAllowFragments error:NULL];
        NSString *value = dict[@"Value"];
        if (value) {
            [self send:kZenLoginSuccess userInfo:@{ @"ticket" : value }];
            return;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"loginResponse exception: %@", [exception description]);
    }
    
    [self send:kZenLoginFailed];
    
}

- (void)loginFailed:(ZenConnection *)connection
{
    NSLog(@"loginFailed: network error");
    [self send:kZenLoginFailed];
}

@end
