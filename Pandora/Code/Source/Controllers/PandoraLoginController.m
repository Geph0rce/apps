//
//  PandoraLoginController.m
//  Zen
//
//  Created by roger on 14-7-9.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "UIImageView+WebCache.h"

#import "ZenMacros.h"
#import "ZenConfig.h"
#import "ZenCategory.h"
#import "ZenNavigationBar.h"
#import "ZenLoadingView.h"
#import "PandoraLoginModel.h"
#import "PandoraLoginController.h"


#define kZenBtnColorNormal ZenColorFromRGB(0x0b6aff)
#define kZenBtnColorHighlight ZenColorFromRGB(0xe67e22)

#define kZenLoginElementsFrame (kZenDeviceiPad? CGRectMake(0.0f, 176.0f, 320, 110.0f) : CGRectMake(0.0f, 70.0f, kZenScreenWidth, 110.0f))
#define kZenForgetBtnOffsetX (kZenDeviceiPad? 480.0f : 240.0f)
#define kZenLoginBtnOffsetX (kZenDeviceiPad? 240.0f : 11.0f)

@interface PandoraLoginController () <UIGestureRecognizerDelegate>
{
    UITextField *_userNameTextField;
    UITextField *_passwordTextField;
    UITextField *_verifyCodeTextField;
    UIImageView *_verifyCode;
    PandoraLoginModel *_model;
    ZenLoadingView *_loading;
}
@end

@implementation PandoraLoginController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _model = [[PandoraLoginModel alloc] init];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(loginFinished:) name:kPandoraLoginSuccess object:_model];
    [defaultCenter addObserver:self selector:@selector(loginFailed:) name:kPandoraLoginFailed object:_model];
    [defaultCenter addObserver:self selector:@selector(refreshCode:) name:kPandoraLoginNeedVerify object:_model];
    
    UIView *elements = [[UIView alloc] initWithFrame:kZenLoginElementsFrame];
    elements.backgroundColor = kZenBackgroundColor;
    [self.view addSubview:elements];
    [elements centerInHorizontal];
    
    UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 10.0f, 60.0f, 16.0f)];
    userNameLabel.font = kZenFont16;
    userNameLabel.backgroundColor = [UIColor clearColor];
    userNameLabel.textColor = kZenMainFontColor;
    userNameLabel.textAlignment = NSTextAlignmentLeft;
    userNameLabel.text = @"用户名";
    [elements addSubview:userNameLabel];
    
    
    UITextField *userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(userNameLabel.frame) + 20.0f, CGRectGetMinY(userNameLabel.frame), 220.0f, 20.0f)];
    _userNameTextField = userNameTextField;
    userNameTextField.font = kZenFont14;
    userNameTextField.textColor = kZenMainFontColor;
    userNameTextField.backgroundColor = [UIColor clearColor];
    userNameTextField.borderStyle = UITextBorderStyleNone;
    userNameTextField.placeholder = @"请输入用户名";
    userNameTextField.keyboardType = UIKeyboardTypeDefault;
    userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [elements addSubview:userNameTextField];
    
    UILabel *passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 45.0f, 60.0f, 16.0f)];
    passwordLabel.font = kZenFont16;
    passwordLabel.backgroundColor = [UIColor clearColor];
    passwordLabel.textColor = kZenMainFontColor;
    passwordLabel.textAlignment = NSTextAlignmentLeft;
    passwordLabel.text = @"密码";
    [elements addSubview:passwordLabel];
    
    UITextField *passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(passwordLabel.frame) + 20.0f, CGRectGetMinY(passwordLabel.frame), 220.0f, 20.0f)];
    _passwordTextField = passwordTextField;
    passwordTextField.secureTextEntry = YES;
    passwordTextField.font = kZenFont14;
    passwordTextField.textColor = kZenMainFontColor;
    passwordTextField.backgroundColor = [UIColor clearColor];
    passwordTextField.borderStyle = UITextBorderStyleNone;
    passwordTextField.placeholder = @"请输入密码";
    passwordTextField.keyboardType = UIKeyboardTypeDefault;
    passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [elements addSubview:passwordTextField];
    
    CGFloat offsetY = CGRectGetMaxY(passwordTextField.frame) + 10.0f;
    
    UITextField *verifyCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0f, offsetY, 120.0f, 20.0f)];
    _verifyCodeTextField = verifyCodeTextField;
    verifyCodeTextField.hidden = YES;
    verifyCodeTextField.font = kZenFont14;
    verifyCodeTextField.textColor = kZenMainFontColor;
    verifyCodeTextField.backgroundColor = [UIColor clearColor];
    verifyCodeTextField.borderStyle = UITextBorderStyleNone;
    verifyCodeTextField.placeholder = @"请输入验证码";
    verifyCodeTextField.keyboardType = UIKeyboardTypeDefault;
    verifyCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [elements addSubview:verifyCodeTextField];
    
    UIImageView *verifyCode = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(verifyCodeTextField.frame) + 10.0f, offsetY, 60.0f, 20.0f)];
    verifyCode.hidden = YES;
    _verifyCode = verifyCode;
    [elements addSubview:verifyCode];

    offsetY = CGRectGetMaxY(elements.frame);
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(kZenLoginBtnOffsetX, offsetY + 15.0f, 160.0f, 43.0f);
    [loginBtn setBackgroundImage:[UIImage imageNamed:@"btn_login"] forState:UIControlStateNormal];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    loginBtn.titleLabel.font = kZenFont16;
    loginBtn.titleLabel.textColor = [UIColor whiteColor];
    [loginBtn addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    [loginBtn centerInHorizontal];
    
    _loading = [[ZenLoadingView alloc] init];
    _loading.type = ZenLoadingViewTypeUnderNavigationBar;
    [_loading setTitle:@"正在登录..."];
    [self.view addSubview:_loading];
    
    ZenNavigationBar *bar = [[ZenNavigationBar alloc] init];
    [bar addLeftItemWithStyle:ZenNavigationItemStyleBack target:self action:@selector(back:)];
    [bar setTitle:@"登录"];
    [self.view addSubview:bar];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    _userNameTextField.text = @"心里有根刺1997";
    _passwordTextField.text = @"spurs1997";
    
    [_model refreshCookie];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_userNameTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark -
#pragma mark Events and Notifications Handler

- (void)resign
{
    [_userNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

- (void)tap:(UITapGestureRecognizer *)recognizer
{
    [self resign];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]){
        return NO;
    }
    return YES;
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)login:(id)sender
{
    [_loading show];
    if (_verifyCodeTextField.hidden) {
        [_model login:_userNameTextField.text password:_passwordTextField.text verifyCode:@""];
    }
    else {
        [_model login:_userNameTextField.text password:_passwordTextField.text verifyCode:_verifyCodeTextField.text];
    }
}


- (void)loginFinished:(NSNotification *)notification
{
    [_loading hide];
    [self success:@"登录成功！"];
    [self resign];
    [self.navigationController popViewControllerAnimated:YES];
    //[_model test];
}

- (void)loginFailed:(NSNotification *)notification
{
    [_loading hide];
    [self failed:@"登录失败！"];
}

- (void)refreshCode:(NSNotification *)notification
{
    [_loading hide];
    _verifyCodeTextField.hidden = NO;
    _verifyCode.hidden = NO;
    [_verifyCode setImageWithURL:[NSURL URLWithString:_model.verifyCodeURL]];
    NSDictionary *info = notification.userInfo;
    if (info) {
        NSString *msg = [info stringForKey:@"msg"];
        if (msg && ![msg isEqualToString:@""]) {
            [self failed:msg];
            return;
        }
    }
    [self failed:@"请输入验证码!"];
}

@end
