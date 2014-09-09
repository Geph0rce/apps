//
//  ArtisanPlaylistModel.m
//  Artisan
//
//  Created by roger on 13-8-20.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import "ASIHTTPRequest.h"

#import "ArtisanPlaylistModel.h"

@implementation ArtisanPlaylistData
@synthesize pid = _pid;
@synthesize title = _title;

- (void)dealloc
{
    [_pid release], _pid = nil;
    [_title release], _title = nil;
    
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"id: %@\n title: %@\n", _pid, _title];
}

@end


#pragma mark -
#pragma mark ArtisanProfileData

@implementation ArtisanProfileData
@synthesize picture = _picture;
@synthesize name = _name;
@synthesize style = _style;
@synthesize follower = _follower;

- (void)dealloc
{
    [_picture release], _picture = nil;
    [_name release], _name = nil;
    [_style release], _style = nil;
    [_follower release], _follower = nil;
    
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"picture: %@\n name: %@\n style: %@\n follower: %@ \n", _picture, _name, _style, _follower];
}

@end


#pragma mark -
#pragma mark ArtisanPlaylistModel

@interface ArtisanPlaylistModel ()
{
    ASIHTTPRequest *_request;
}

@property (nonatomic, retain) ASIHTTPRequest *request;

@end

@implementation ArtisanPlaylistModel
@synthesize playlists = _playlists;
@synthesize profile = _profile;
@synthesize request = _request;

- (void)dealloc
{
    [_playlists release], _playlists = nil;
    [_profile release], _profile = nil;
    [_request clearDelegatesAndCancel];
    [_request release], _request = nil;
    [super dealloc];
}

- (id)init
{
    if (self = [super init]) {
        _playlists = [[NSMutableArray alloc] init];
        _profile = [[ArtisanProfileData alloc] init];
    }
    return self;
}

- (void)load:(NSURL *)url
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    self.request = request;
    _request.delegate = self;
    [_request startAsynchronous];
}


#pragma mark -
#pragma mark ASIHTTPRequest Delegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *response = [request.responseString filter];
    if (response) {
        NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
        if (dict) {
            _profile.picture = [dict stringForKey:@"picture"];
            _profile.name = [dict stringForKey:@"name"];
            _profile.style = [dict stringForKey:@"style"];
            _profile.follower = [NSString stringWithFormat:@"%d", [dict intForKey:@"follower"]];
            
            [_playlists removeAllObjects];
            NSArray *playlist = [dict objectForKey:@"playlist"];
            for (NSDictionary *item in playlist) {
                ArtisanPlaylistData *data = [[ArtisanPlaylistData alloc] init];
                data.pid = [item stringForKey:@"id"];
                data.title = [item stringForKey:@"title"];
                [_playlists addObject:data];
                [data release];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kArtisanLoadPlaylistsSuccess object:self];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
     [[NSNotificationCenter defaultCenter] postNotificationName:kArtisanLoadPlaylistsFailed object:self];
}

@end
