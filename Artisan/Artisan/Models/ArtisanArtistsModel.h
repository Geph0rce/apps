//
//  ArtisanArtistsModel.h
//  Artisan
//
//  Created by roger on 13-8-19.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kArtisanLoadArtistsSuccess @"ArtisanLoadArtistsSuccess"
#define kArtisanLoadArtistsFailed @"ArtisanLoadArtistsFailed"

@interface ArtisanArtistData : NSObject
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



@interface ArtisanArtistsModel : NSObject
{
    NSMutableArray *_artists;
}
@property (nonatomic, retain) NSMutableArray *artists;

- (void)cancel;
- (void)load:(NSURL *)url;

@end
