//
//  ArtisanStack.m
//  Artisan
//
//  Created by roger on 13-8-5.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import "ArtisanStack.h"
#import "Singleton.h"

@interface ArtisanStack ()
{
    NSMutableArray *_stack;
}

@end


@implementation ArtisanStack

SINGLETON_FOR_CLASS(ArtisanStack);


- (id)init
{
    if (self = [super init]) {
        _stack = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)push:(UIViewController *)controller
{
    [_stack addObject:controller];
}

- (void)pop:(UIViewController *)controller
{
    int index = [_stack indexOfObject:controller];
    NSLog(@"index: %d ", index);
    if (controller) {
        [_stack removeObject:controller];
    }
}

@end
