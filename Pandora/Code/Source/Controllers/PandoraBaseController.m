//
//  PandoraBaseController.m
//  Zen
//
//  Created by roger on 14-7-9.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "ZenToast.h"
#import "PandoraBaseController.h"

@interface PandoraBaseController ()

@end

@implementation PandoraBaseController


- (void)viewDidLoad
{
    [super viewDidLoad];
   
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark
#pragma mark ZenToast Stuff

- (void)success:(NSString *)msg
{
    [[ZenToast sharedInstance] postMessage:msg type:ZenToastTypeSuccess dismissAfterDelay:1.0f];
}

- (void)warning:(NSString *)msg
{
    [[ZenToast sharedInstance] postMessage:msg type:ZenToastTypeWarning dismissAfterDelay:1.0f];
}

- (void)failed:(NSString *)msg
{
    [[ZenToast sharedInstance] postMessage:msg type:ZenToastTypeError dismissAfterDelay:1.0f];
}



@end
