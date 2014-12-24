//
//  PandoraLoginController.m
//  Pandora
//
//  Created by roger on 14/12/24.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "ZenMacros.h"
#import "ZenCategory.h"
#import "PandoraLoginModel.h"
#import "ZenNavigationBar.h"
#import "ZenLoadingView.h"
#import "PandoraLoginController.h"

@interface PandoraLoginController ()
{
    PandoraLoginModel *_model;
    ZenLoadingView *_loading;
    BOOL _isNeedVerifyCode;
    
    UIButton *_loginBtn;
    UIButton *_closeKeyboardBtn;
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
    [defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(loginFinished:) name:kPandoraLoginSuccess object:_model];
    [defaultCenter addObserver:self selector:@selector(loginFailed:) name:kPandoraLoginFailed object:_model];
    [defaultCenter addObserver:self selector:@selector(refreshCode:) name:kPandoraLoginNeedVerify object:_model];
    
    _loading = [[ZenLoadingView alloc] init];
    _loading.type = ZenLoadingViewTypeUnderNavigationBar;
    [_loading setTitle:@"正在登录..."];
    [self.view addSubview:_loading];
    
    ZenNavigationBar *bar = [[ZenNavigationBar alloc] init];
    [bar addLeftItemWithStyle:ZenNavigationItemStyleBack target:self action:@selector(back:)];
    [bar setTitle:@"登录"];
    [self.view addSubview:bar];
    [_userIcon setImage:[[UIImage imageNamed:@"login_icon_usr"] tintImageWithColor:kZenMainStyleColor]];
    [_passIcon setImage:[[UIImage imageNamed:@"login_icon_pass"] tintImageWithColor:kZenMainStyleColor]];
    
    _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginBtn.frame = CGRectMake(0.0f, 0.0f, 236.0f, 35.0f);
    [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginBtn setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [_loginBtn setBackgroundImage:[UIImage imageWithColor:kZenMainStyleColor] forState:UIControlStateNormal];
    [_loginBtn addTarget:self action:@selector(onLoginClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginBtn];
    [_loginBtn centerInHorizontal];
    
    UIButton *closeKeyboardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeKeyboardBtn = closeKeyboardBtn;
    UIImage *closeKeyboardImage = [UIImage imageNamed:@"close_keyboard"];
    [_closeKeyboardBtn setImage:[closeKeyboardImage tintImageWithColor:kZenMainStyleColor] forState:UIControlStateNormal];
    _closeKeyboardBtn.frame = CGRectMake(CGRectGetWidth(self.view.frame) - closeKeyboardImage.size.width - 10.0f, 0.0f, closeKeyboardImage.size.width, closeKeyboardImage.size.height);
    _closeKeyboardBtn.hidden = YES;
    [_closeKeyboardBtn addTarget:self action:@selector(onCloseKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeKeyboardBtn];
    
    _verifyCodeView.hidden = YES;
    _isNeedVerifyCode = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self adjustLoginBtnFrame];
    [_userNameTextField becomeFirstResponder];
}

- (void)adjustLoginBtnFrame
{
    CGRect frame = _loginBtn.frame;
    if (_isNeedVerifyCode) {
        CGFloat offsetY = CGRectGetMaxY(_verifyCodeView.frame) + 8.0f;
        frame.origin.y = offsetY;
    }
    else {
        CGFloat offsetY = CGRectGetMaxY(_passwordView.frame) + 8.0f;
        frame.origin.y = offsetY;
    }
    _loginBtn.frame = frame;
}

- (void)resign
{
    if ([_userNameTextField isFirstResponder]) {
        [_userNameTextField resignFirstResponder];
    }
    else if ([_passwordTextField isFirstResponder]) {
        [_passwordTextField resignFirstResponder];
    }
    else if ([_verifyCodeTextField isFirstResponder]) {
        [_verifyCodeTextField resignFirstResponder];
    }
}

- (UITextField *)firstResponderTextField
{
    if ([_userNameTextField isFirstResponder]) {
        return _userNameTextField;
    }
    else if ([_passwordTextField isFirstResponder]) {
        return _passwordTextField;
    }
    else if ([_verifyCodeTextField isFirstResponder]) {
        return _verifyCodeTextField;
    }
    return nil;
}

- (void)adjustFrameWithKeyboardHeight:(CGFloat)keyboardHeight
{
    // change closeKeyboardBtn frame
    CGFloat closeBtnOffsetY = CGRectGetMaxY(_closeKeyboardBtn.frame) - (CGRectGetHeight(self.view.frame) - keyboardHeight);
    if (closeBtnOffsetY > 0 || closeBtnOffsetY < -5.0f) {
        CGRect closeBtnFrame = _closeKeyboardBtn.frame;
        closeBtnFrame.origin.y -= closeBtnOffsetY;
        _closeKeyboardBtn.frame = closeBtnFrame;
    }
    _closeKeyboardBtn.hidden = NO;
}

#pragma mark
#pragma mark Actions

- (void)onCloseKeyboard:(id)sender
{
    [self resign];
}

- (void)onLoginClick:(id)sender
{
    NSString *userName = _userNameTextField.text;
    NSString *password = _passwordTextField.text;
    NSString *verifyCode = _verifyCodeTextField.text;
    
    if ([userName isEqualToString:@""]) {
        [self warning:@"请输入用户名"];
    }
    else if ([password isEqualToString:@""]) {
        [self warning:@"请输入密码"];
    }
    else if (_isNeedVerifyCode && [verifyCode isEqualToString:@""]) {
        [self warning:@"请输入验证码"];
    }
    else {
        [_loading show];
        if (!_isNeedVerifyCode) {
            [_model login:userName password:password verifyCode:@""];
        }
        else {
            [_model login:userName password:password verifyCode:verifyCode];
        }
    }
}


- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)loginFinished:(NSNotification *)notification
{
    [_loading hide];
    [self success:@"登录成功！"];
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
    _verifyCodeView.hidden = NO;
    _isNeedVerifyCode = YES;
    [self adjustLoginBtnFrame];
    
    [_verifyCodeImageView setImageWithURL:[NSURL URLWithString:_model.verifyCodeURL]];
    NSDictionary *info = notification.userInfo;
    if (info) {
        NSString *msg = [info stringForKey:@"msg"];
        if (msg && ![msg isEqualToString:@""]) {
            [self failed:msg];
            return;
        }
    }
    [self failed:@"请输入正确的验证码!"];
}


#pragma mark
#pragma mark UIKeyBoardNotitifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSValue* aValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    CGFloat keyboardHeight = keyboardSize.height;
    [self adjustFrameWithKeyboardHeight:keyboardHeight];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    _closeKeyboardBtn.hidden = YES;
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSValue* aValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    CGFloat keyboardHeight = keyboardSize.height;
    [self adjustFrameWithKeyboardHeight:keyboardHeight];
}

@end
