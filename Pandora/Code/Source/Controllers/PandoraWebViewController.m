//
//  PandoraWebViewController.m
//  Zen
//
//  Created by roger on 14-7-24.
//  Copyright (c) 2014年 Zen. All rights reserved.
//


#import "ZenMacros.h"
#import "ZenCategory.h"
#import "ZenConfig.h"
#import "ZenLoadingView.h"
#import "PandoraWebViewController.h"

#define kZenWebViewControllerBarColor ZenColorFromRGB(0x2a5b83)
#define kOpenInSafari 0
#define kCopyLink 1
#define kOpenInTaobao 2

#define kZenToolBarWidth    (kZenDeviceiPad? 768.0f : kZenScreenWidth)
#define kZenMoreBtnOffsetX  (kZenDeviceiPad? 674.0f : kZenScreenWidth - 84.0f)
#define kZenCloseBtnOffsetX (kZenDeviceiPad? 716.0f : kZenScreenWidth - 42.0f)

@interface PandoraWebViewController ()
{
    NSURL *_url;
    ZenLoadingView *_loading;
}

@property (nonatomic, strong) NSURL *url;
@end

@implementation PandoraWebViewController
@synthesize url = _url;

- (void)dealloc
{
    [self clearCookies];
}



- (void)updateToolBar
{
    _goBackBtn.enabled = [_mainWebView canGoBack];
    _goForwardBtn.enabled = [_mainWebView canGoForward];
}


- (void)loadURL:(NSURL *)url
{
    [_loading show];
    self.url = url;
    [_mainWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)loadContent:(NSString *)content
{
    [_loading show];
    [_mainWebView loadHTMLString:content baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath] isDirectory:YES]];
}

#pragma mark - ToolBar Events

- (void)goBackClick
{
    [_mainWebView goBack];
}

- (void)goForwardClick
{
    [_mainWebView goForward];
}

- (void)moreClick
{
    if (_url && [_url.absoluteString contains:@"taobao"]) {
        UIActionSheet *pageSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"在Safari中打开", @"复制链接", @"在淘宝中打开", nil];
        
        [pageSheet showInView:self.view];
    }
    else {
        UIActionSheet *pageSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"在Safari中打开", @"复制链接", nil];
        
        [pageSheet showInView:self.view];
    }
    
}

- (void)closeClick
{
    [_mainWebView stopLoading];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat offsetY = 0.0f;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        offsetY = 20.0f;
    }
    
    // goBack button
    _goBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_goBackBtn setImage:[UIImage imageNamed:@"ZenWebViewController.bundle/browser_toolbar_return"] forState:UIControlStateNormal];
    [_goBackBtn addTarget:self action:@selector(goBackClick) forControlEvents:UIControlEventTouchUpInside];
    [_goBackBtn setFrame:CGRectMake(10.0f, 6.0f + offsetY, 32.0f, 32.0f)];
    [_goBackBtn setContentEdgeInsets:UIEdgeInsetsMake(-4.0f, -4.0f, -4.0f, -4.0f)];
    [_goBackBtn setEnabled:NO];
    
    // goForward button
    _goForwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_goForwardBtn setImage:[UIImage imageNamed:@"ZenWebViewController.bundle/browser_toolbar_next"] forState:UIControlStateNormal];
    [_goForwardBtn addTarget:self action:@selector(goForwardClick) forControlEvents:UIControlEventTouchUpInside];
    [_goForwardBtn setFrame:CGRectMake(56.0f, 6.0f + offsetY, 32.0f, 32.0f)];
    [_goForwardBtn setContentEdgeInsets:UIEdgeInsetsMake(-4.0f, -4.0f, -4.0f, -4.0f)];
    [_goForwardBtn setEnabled:NO];
    
    // more button
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreBtn setImage:[UIImage imageNamed:@"ZenWebViewController.bundle/browser_toolbar_more"] forState:UIControlStateNormal];
    [moreBtn setFrame:CGRectMake(kZenMoreBtnOffsetX, 6.0f + offsetY, 32.0f, 32.0f)];
    [moreBtn setContentEdgeInsets:UIEdgeInsetsMake(-4.0f, -4.0f, -4.0f, -4.0f)];
    [moreBtn addTarget:self action:@selector(moreClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setFrame:CGRectMake(kZenCloseBtnOffsetX, 6.0f + offsetY, 32.0f, 32.0f)];
    [closeBtn setImage:[UIImage imageNamed:@"ZenWebViewController.bundle/browser_toolbar_setno"] forState:UIControlStateNormal];
    [closeBtn setContentEdgeInsets:UIEdgeInsetsMake(-4.0f, -4.0f, -4.0f, -4.0f)];
    [closeBtn addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    
    _mainWebView = [[UIWebView alloc] init];
    [_mainWebView setFrame:CGRectMake(0.0f, 44.0f + offsetY, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 44.0f - offsetY)];
    _mainWebView.scalesPageToFit = YES;
    _mainWebView.dataDetectorTypes = UIDataDetectorTypeNone;
    _mainWebView.delegate = self;
    [self.view addSubview:_mainWebView];
    
    _loading = [[ZenLoadingView alloc] init];
    _loading.type = ZenLoadingViewTypeUnderNavigationBar;
    [self.view addSubview:_loading];
    
    // toolBar
    UIView *toolBar = [[UIView alloc] init];
    toolBar.backgroundColor = kZenWebViewControllerBarColor;
    [toolBar setFrame:CGRectMake(0.0f, 0.0f, kZenToolBarWidth, 44.0f + offsetY)];
    [toolBar setUserInteractionEnabled:YES];
    
    [toolBar addSubview:_goBackBtn];
    [toolBar addSubview:_goForwardBtn];
    [toolBar addSubview:moreBtn];
    [toolBar addSubview:closeBtn];
    [self.view addSubview:toolBar];
    
    [self addCookie];
}



- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (kOpenInSafari == buttonIndex) {
        [[UIApplication sharedApplication] openURL:self.url];
    }
    else if (kCopyLink == buttonIndex) {
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        pasteBoard.string = self.url.absoluteString;
    }
    else if(kOpenInTaobao == buttonIndex && _url) {
        NSString *tmp = _url.absoluteString;
        tmp = [tmp stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        NSString *url = [@"taobao://" stringByAppendingString:tmp];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}


- (void)addCookie
{
    @try {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
        
        if (_token) {
            NSArray *array = [_token componentsSeparatedByString:@";"];
            for (NSString *str in array) {
                NSRange range = [str rangeOfString:@"="];
                if (range.location != NSNotFound) {
                    NSString *key = [str substringToIndex:range.location];
                    NSString *value = [str substringFromIndex:range.location + 1];
                    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
                    [cookieProperties setObject:key forKey:NSHTTPCookieName];
                    [cookieProperties setObject:value forKey:NSHTTPCookieValue];
                    [cookieProperties setObject:@".baidu.com" forKey:NSHTTPCookieDomain];
                    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
                    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
                    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
                    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                }
            }
        }
    }
    @catch (NSException *exception) {
        
    }
}

- (void)clearCookies
{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieStorage.cookies) {
        if (cookie.domain && [cookie.domain contains:@".baidu.com"]) {
            [cookieStorage deleteCookie:cookie];
        }
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_loading show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_loading hide];
    self.url = webView.request.URL;
    [self updateToolBar];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_loading hide];
    [self updateToolBar];
}


@end
