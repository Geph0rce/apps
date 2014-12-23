//
//  PandoraLoginModel.h
//  Zen
//
//  Created by roger on 14-7-9.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "PandoraBaseModel.h"
#import "PandoraUserManager.h"

#define kPandoraLoginSuccess    @"PandoraLoginSuccess"
#define kPandoraLoginFailed     @"PandoraLoginFailed"
#define kPandoraLoginNeedVerify @"PandoraLoginNeedVerify"

@interface PandoraLoginModel : PandoraBaseModel
{
    NSString *_verifyCodeURL;
}
@property (nonatomic, strong) NSString *verifyCodeURL;

- (void)refreshCookie;

- (void)login:(NSString *)name password:(NSString *)pwd verifyCode:(NSString *)verifyCode;

@end
