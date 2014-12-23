//
//  ZenIDFA.m
//  ZenForMop
//
//  Created by roger on 14-5-14.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import <AdSupport/AdSupport.h>
#import "ZenMacros.h"
#import "ZenCategory.h"
#import "ZenIDFA.h"

#define kZenIDFA @"ZenIDFA"

@implementation ZenIDFA

+ (NSString *)value
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        return idfa;
    }
    else {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *idfa = [ud stringForKey:kZenIDFA];
        if (!idfa) {
            return [ZenIDFA generate];
        }
        return idfa;
    }
}

+ (NSString *)generate
{
    NSDate *date = [[NSDate alloc] init];
    NSTimeInterval interval = [date timeIntervalSince1970];
    NSString *timestamp = [NSString stringWithFormat:@"zen: %lf", interval];
    NSString *idfa = [timestamp idfa];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:idfa forKey:kZenIDFA];
    [ud synchronize];
    return idfa;
}

@end
