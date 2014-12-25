//
//  PandoraThiefModel.h
//  Zen
//
//  Created by roger on 14-7-17.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "PandoraBaseModel.h"

#define kPandoraOpenWebView @"PandoraOpenWebView"

@interface PandoraThiefModel : PandoraBaseModel

+ (PandoraThiefModel *)sharedInstance;

- (void)run;

- (BOOL)handleURL:(NSURL *)url;

- (void)thief:(NSString *)token;

@end