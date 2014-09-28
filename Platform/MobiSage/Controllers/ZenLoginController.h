//
//  ZenLoginController.h
//  MobiSage
//
//  Created by roger on 14-8-25.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "ZenBaseController.h"
#import "ZenLoginModel.h"

@interface ZenLoginController : ZenBaseController
{
    ZenLoginType _type;
}

@property (nonatomic, assign) ZenLoginType type;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)login:(id)sender;

@end
