//
//  ArtisanCategory.h
//  Artisan
//
//  Created by roger on 13-8-2.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ArtisanHelper)

- (NSString *)urlDecode;

- (NSString *)urlEncode;

- (NSString *)safeFormat;

- (NSString *)stringByEncodeCharacterEntities;

- (NSString *)filter;

@end


@interface NSArray (ArtisanHelper)

- (id)safeObjectAtIndex:(NSUInteger)index;

@end


@interface NSDictionary (ArtisanHelper)

- (NSString *)stringForKey:(NSString *)key;
- (int)intForKey:(NSString *)key;

@end


@interface NSMutableString (ArtisanHelper)

- (void)safeAppendString:(NSString *)string;

@end

@interface UIImage (ArtisanHelper)

+ (UIImage *)imageWithColor:(UIColor *)color;
- (UIImage*)cropToSize:(CGSize)newSize;

@end