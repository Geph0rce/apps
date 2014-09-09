//
//  GCDHelper.h
//  Artisan
//
//  Created by roger on 13-8-2.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef void (^ArtisanGCDBlock)(void);

@interface GCDHelper : NSObject
+ (void)dispatchBlock:(ArtisanGCDBlock)block complete:(ArtisanGCDBlock)completion;
@end
