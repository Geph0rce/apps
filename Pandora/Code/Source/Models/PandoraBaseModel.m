//
//  PandoraBaseModel.m
//  Zen
//
//  Created by roger on 14-7-9.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "PandoraBaseModel.h"

@implementation PandoraBaseModel

- (NSString *)cookies
{
    return nil;
}

- (void)send:(NSString *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notification object:self];
}

- (void)send:(NSString *)notification userInfo:(NSDictionary *)userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notification object:self userInfo:userInfo];
}


@end
