//
//  PandoraLoginController.h
//  Pandora
//
//  Created by roger on 14/12/24.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "PandoraBaseController.h"

@interface PandoraLoginController : PandoraBaseController

@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
@property (weak, nonatomic) IBOutlet UIImageView *passIcon;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIImageView *verifyCodeImageView;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTextField;

@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIView *verifyCodeView;

@end
