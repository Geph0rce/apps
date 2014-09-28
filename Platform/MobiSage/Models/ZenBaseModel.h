//
//  ZenBaseModel.h
//  MobiSage
//
//  Created by roger on 14-8-25.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZenBaseModel : NSObject

- (void)send:(NSString *)notification;

- (void)send:(NSString *)notification userInfo:(NSDictionary *)info;

@end
