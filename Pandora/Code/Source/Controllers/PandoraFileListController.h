//
//  PandoraFileListController.h
//  Zen
//
//  Created by roger on 14-7-14.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "PandoraBaseController.h"

typedef enum {
    PandoraNavigationTypeMenu,
    PandoraNavigationTypeBack
} PandoraNavigationType;

@interface PandoraFileListController : PandoraBaseController
{
    NSString *_name;
    NSString *_path;
    NSString *_token;
    PandoraNavigationType _type;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, assign) PandoraNavigationType type;

@end
