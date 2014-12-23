//
//  ZenRulesModel.m
//  ZenPro
//
//  Created by roger on 13-12-5.
//  Copyright (c) 2013年 Zen. All rights reserved.
//

#import "ZenMacros.h"
#import "Singleton.h"
#import "PandoraConnection.h"
#import "ZenCategory.h"
#import "ZenRulesModel.h"

#define kZenRulesURL @"http://rogerqian.github.io/config_ios.json"

@interface ZenRulesModel () <PandoraConnectionDelegate>
{
    PandoraConnection *_connection;
}

@property (nonatomic, strong) PandoraConnection *connection;

@end

@implementation ZenRulesModel

SINGLETON_FOR_CLASS(ZenRulesModel);

- (id)init
{
    if (self = [super init]) {
        _adType = ZenAdTypeBaidu;
        _enabled = YES;
    }
    return self;
}

- (void)load
{
    PandoraConnection *connection = [PandoraConnection connectionWithURL:[NSURL URLWithString:kZenRulesURL]];
    self.connection = connection;
    connection.delegate = self;
    connection.didFinishedSelector = @selector(rulesDidFinishedLoad:);
    [connection startAsynchronous];
}

- (void)rulesDidFinishedLoad:(PandoraConnection *)connection
{
    @try {
        if (connection.responseData) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:connection.responseData options:NSJSONReadingMutableContainers error:NULL];
            if (dict) {
                int flag = [dict intForKey:@"enabled"];
                _enabled = flag == 1 ? YES : NO;
                _adType = [dict intForKey:@"adType"];
                _bannerType = [dict intForKey:@"banner"];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"ZenRulesModel exception: %@", [exception description]);
    }
}


@end
