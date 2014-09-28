//
//  ZenLoginController.m
//  MobiSage
//
//  Created by roger on 14-8-25.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "ZenCategory.h"
#import "ZenLoadingView.h"
#import "ZenLoginModel.h"
#import "ZenLoginController.h"
#import "ZenWebViewController.h"

@interface ZenLoginController ()
{
    ZenLoginModel *_model;
    ZenLoadingView *_loading;
}
@end

@implementation ZenLoginController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.title = @"Login";
    _model = [[ZenLoginModel alloc] init];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(loginSuccess:) name:kZenLoginSuccess object:_model];
    [defaultCenter addObserver:self selector:@selector(loginFailed:) name:kZenLoginFailed object:_model];
    
    _loading = [[ZenLoadingView alloc] init];
    [_loading setTitle:@"正在登录..."];
    [self.view addSubview:_loading];
    
    if (_type == ZenLoginTypeAdsage) {
        _passwordTextField.text = @"Apple1988";
    }
    else {
        _passwordTextField.text = @"sky0074";
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender
{
    NSString *username = _usernameTextField.text;
    NSString *password = _passwordTextField.text;
    
    if (!username || [username isEqualToString:@""]) {
        [self alert:@"请输入账号～"];
    }
    else if (!password || [password isEqualToString:@""]) {
        [self alert:@"请输入密码～"];
    }
    else {
        [_loading show];
        [_model login:username password:password type:_type];
    }
}

- (NSString *)today
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}

#pragma mark
#pragma mark ZenLoginModel Notification Handler

- (void)loginSuccess:(NSNotification *)notification
{
    [_loading hide];
    if (_type == ZenLoginTypeAdsage) {
        NSString *url = [NSString stringWithFormat:@"http://mobi.adsage.cn/ac/?adsage_ticket=%@", notification.userInfo[@"ticket"]];
        ZenWebViewController *controller = [[ZenWebViewController alloc] init];
        controller.url = [NSURL URLWithString:url];
        [self.navigationController pushViewController:controller animated:YES];
    }
    else {
        NSString *today = [self today];
        NSString *url = [NSString stringWithFormat:@"http://platform.limei.com/index.php?c=mediareportform&a=index&start_time=%@&end_time=%@", today, today];
        ZenWebViewController *controller = [[ZenWebViewController alloc] init];
        controller.url = [NSURL URLWithString:url];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)loginFailed:(NSNotification *)notification
{
    [_loading hide];
    [self alert:@"登录失败"];
}

@end
