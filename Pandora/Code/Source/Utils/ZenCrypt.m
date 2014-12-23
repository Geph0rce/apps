//
//  ZenCrypt.m
//  Zen
//
//  Created by roger on 13-11-15.
//  Copyright (c) 2013年 Zen. All rights reserved.
//

#import "ZenIDFA.h"
#import "ZenCategory.h"
#import "ZenCrypt.h"

#define kZenDefaultKey  @"Get busy living, or get busy die."
#define kZenDefaultIV   @"0102030405060708"


@implementation ZenCrypt

+ (NSString *)encrypt:(NSString *)plainText
{
    NSData *enData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSString *key = [[ZenIDFA value] md5];
    key = [key substringToIndex:16];
    NSData *en = [enData AES128EncryptWithKey:key iv:kZenDefaultIV];
    NSString *enStr = [en dataToPlainText];
    return enStr;
}

+ (NSString *)decrypt:(NSString *)encryptedText
{
    NSData *contentData = [encryptedText stringToHexData];
    NSString *key = [[ZenIDFA value] md5];
    key = [key substringToIndex:16];
    NSData *de = [contentData AES128DecryptWithKey:key iv:kZenDefaultIV];
    NSString *plainText = [[NSString alloc] initWithData:de encoding:NSUTF8StringEncoding];
    return plainText;
}

@end
