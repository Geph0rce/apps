//
//  ZenCrypt.h
//  Zen
//
//  Created by roger on 13-11-15.
//  Copyright (c) 2013年 Zen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZenCrypt : NSObject

+ (NSString *)encrypt:(NSString *)plainText;

+ (NSString *)decrypt:(NSString *)encryptedText;

@end
