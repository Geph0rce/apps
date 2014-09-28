//
//  ZenBaseModel.m
//  MobiSage
//
//  Created by roger on 14-8-25.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "ZenBaseModel.h"

@implementation ZenBaseModel

- (void)send:(NSString *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notification object:self];
    });
    
}

- (void)send:(NSString *)notification userInfo:(NSDictionary *)info
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notification object:self userInfo:info];
    });
    
}

@end
