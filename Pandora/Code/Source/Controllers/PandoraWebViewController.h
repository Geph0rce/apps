//
//  PandoraWebViewController.h
//  Zen
//
//  Created by roger on 14-7-24.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "PandoraBaseController.h"

@interface PandoraWebViewController : PandoraBaseController <UIActionSheetDelegate, UIWebViewDelegate>
{
    NSString *_token;
    UIWebView *_mainWebView;
    UIButton *_goBackBtn;
    UIButton *_goForwardBtn;
}

@property (nonatomic, strong) NSString *token;

- (void)loadURL:(NSURL *)url;
- (void)loadContent:(NSString *)content;
@end
