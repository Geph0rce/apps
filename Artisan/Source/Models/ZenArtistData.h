//
//  ZenArtistData.h
//  Artisan
//
//  Created by roger on 14-9-10.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZenArtistData : NSObject
{
    NSString *_picture;
    NSString *_name;
    NSString *_follower;
    NSString *_aid;
}

@property (nonatomic, retain) NSString *picture;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *follower;
@property (nonatomic, retain) NSString *aid;

@end
