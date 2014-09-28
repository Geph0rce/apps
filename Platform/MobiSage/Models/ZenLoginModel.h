//
//  ZenLoginModel.h
//  MobiSage
//
//  Created by roger on 14-8-25.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "ZenBaseModel.h"

#define kZenLoginSuccess @"ZenLoginSuccess"
#define kZenLoginFailed @"ZenLoginFailed"

typedef enum {
    ZenLoginTypeAdsage,
    ZenLoginTypeLimei
}ZenLoginType;

@interface ZenLoginModel : ZenBaseModel

- (void)login:(NSString *)username password:(NSString *)password type:(ZenLoginType)type;

@end
