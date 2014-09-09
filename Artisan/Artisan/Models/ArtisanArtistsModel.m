//
//  ArtisanArtistsModel.m
//  Artisan
//
//  Created by roger on 13-8-19.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import "ASIHTTPRequest.h"
#import "ArtisanArtistsModel.h"

@implementation ArtisanArtistData
@synthesize picture = _picture;
@synthesize name = _name;
@synthesize follower = _follower;
@synthesize aid = _aid;

- (void)dealloc
{
    [_picture release], _picture = nil;
    [_name release], _name = nil;
    [_follower release], _follower = nil;
    [_aid release], _aid = nil;
    
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name: %@\n picture: %@\n follower: %@\n aid: %@", _name, _picture, _follower, _aid];
}

@end


@interface ArtisanArtistsModel ()
{
    ASIHTTPRequest *_request;
}
@property (nonatomic, retain) ASIHTTPRequest *request;
@end

@implementation ArtisanArtistsModel
@synthesize request = _request;

- (void)dealloc
{
    [_request clearDelegatesAndCancel];
    [_request release], _request = nil;
    [super dealloc];
}

- (id)init
{
    if (self = [super init]) {
        _artists = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)cancel
{
    [_request clearDelegatesAndCancel];
}

- (void)load:(NSURL *)url
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.delegate = self;
    request.didFinishSelector = @selector(didFinishLoad:);
    request.didFailSelector = @selector(didFailLoad:);
    self.request = request;
    [_request startAsynchronous];
}

#pragma mark -
#pragma mark ASIHTTPRequestDelegate

- (void)didFinishLoad:(ASIHTTPRequest *)reqeust
{
    if (reqeust.responseString) {
        NSString *json = [reqeust.responseString filter];
        if (json) {
            NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:NULL];
            if (dict) {
                NSArray *artists = [dict objectForKey:@"artists"];
                if (artists) {
                    [_artists removeAllObjects];
                    for (NSDictionary *artist in artists) {
                        ArtisanArtistData *data = [[ArtisanArtistData alloc] init];
                        data.picture = [artist stringForKey:@"picture"];
                        data.name = [artist stringForKey:@"name"];
                        data.follower = [NSString stringWithFormat:@"%d", [artist intForKey:@"follower"]];
                        data.aid = [artist stringForKey:@"id"];
                        [_artists addObject:data];
                        NSLog(@"%@", [data description]);
                        [data release];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:kArtisanLoadArtistsSuccess object:self];

                }
            }
        }
    }
}

- (void)didFailLoad:(ASIHTTPRequest *)request
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kArtisanLoadArtistsFailed object:self];
}

@end
