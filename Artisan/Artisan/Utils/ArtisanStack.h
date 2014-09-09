//
//  ArtisanStack.h
//  Artisan
//
//  Created by roger on 13-8-5.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArtisanStack : NSObject

+ (ArtisanStack *)sharedInstance;

- (void)push:(UIViewController *)controller;
- (void)pop:(UIViewController *)controller;

@end
