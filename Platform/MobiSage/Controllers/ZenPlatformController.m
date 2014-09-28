//
//  ZenPlatformController.m
//  MobiSage
//
//  Created by roger on 14-9-28.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "ZenPlatformController.h"
#import "ZenLoginController.h"

@interface ZenPlatformController ()

@end

@implementation ZenPlatformController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Platform";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (IBAction)adsage:(id)sender
{
    ZenLoginController *controller = [[ZenLoginController alloc] init];
    controller.type = ZenLoginTypeAdsage;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)limei:(id)sender
{
    ZenLoginController *controller = [[ZenLoginController alloc] init];
    controller.type = ZenLoginTypeLimei;
    [self.navigationController pushViewController:controller animated:YES];
}
@end
