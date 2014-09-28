//
//  ZenWebViewController
//  Zen
//
//  Created by roger qian on 12-12-3.
//  Copyright (c) 2012年 Zen. All rights reserved.
//

#import "ZenBaseController.h"

@interface ZenWebViewController : ZenBaseController <UIActionSheetDelegate, UIWebViewDelegate>
{
    NSURL *_url;
}

@property (nonatomic, strong) NSURL *url;

- (void)loadURL:(NSURL *)url;
- (void)loadContent:(NSString *)content;

@end
