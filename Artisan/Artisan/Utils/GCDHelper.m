//
//  GCDHelper.m
//  Artisan
//
//  Created by roger on 13-8-2.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//


#import "GCDHelper.h"

@implementation GCDHelper

+ (void)dispatchBlock:(ArtisanGCDBlock)block complete:(ArtisanGCDBlock)completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            block();
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            }
        }
    });
}

@end
