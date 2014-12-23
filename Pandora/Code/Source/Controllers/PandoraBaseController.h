//
//  PandoraBaseController.h
//  Zen
//
//  Created by roger on 14-7-9.
//  Copyright (c) 2014年 Zen. All rights reserved.
//



@interface PandoraBaseController : UIViewController

- (void)success:(NSString *)msg;

- (void)warning:(NSString *)msg;

- (void)failed:(NSString *)msg;

@end
