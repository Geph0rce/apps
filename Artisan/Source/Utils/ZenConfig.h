//
//  ZenConfig.h
//  Zen
//
//  Created by roger qian on 13-3-13.
//  Copyright (c) 2013年 Zen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZenConfig : NSObject
{
    BOOL _textOnly;
    BOOL _night;
}

@property (nonatomic, assign) BOOL textOnly;
@property (nonatomic, assign) BOOL night;

+ (ZenConfig *)sharedInstance;

@end
