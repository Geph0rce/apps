//
//  PandoraBaseModel.h
//  Zen
//
//  Created by roger on 14-7-9.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PandoraBaseModel : NSObject

- (NSString *)cookies;

- (void)send:(NSString *)notification;

- (void)send:(NSString *)notification userInfo:(NSDictionary *)userInfo;

@end
