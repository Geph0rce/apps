//
//  ArtisanSongsModel.m
//  Artisan
//
//  Created by roger on 13-8-2.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import "ASIHTTPRequest.h"

#import "DoubanArtist.h"
#import "ArtisanSongsModel.h"

#pragma mark -
#pragma mark ArtisanSongsData

@implementation ArtisanSongsData
@synthesize artist = _artist;
@synthesize name = _name;
@synthesize length = _length;
@synthesize picture = _picture;
@synthesize src = _src;


- (void)dealloc
{
    [_artist release], _artist = nil;
    [_name release], _name = nil;
    [_length release], _length = nil;
    [_picture release], _picture = nil;
    [_src release], _src = nil;
    
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"artist: %@\n name: %@\n length: %@\n picture: %@\n src: %@", _artist, _name, _length, _picture, _src];
}

@end

#pragma mark -
#pragma mark - ArtisanSongsModel

@implementation ArtisanSongsModel
@synthesize songs = _songs;

- (void)dealloc
{
    [_songs release], _songs = nil;
    [super dealloc];
}

- (id)init
{
    if (self = [super init]) {
        _songs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *)filter:(NSString *)str
{
    NSRange r = [str rangeOfString:@"\\{.+\\}" options:NSRegularExpressionSearch];
    if (r.location != NSNotFound) {
        NSString *result = [str substringWithRange:r];
        return  result;
    }
    return nil;
}

- (void)fetchSongs
{
    DoubanArtist *artist = [DoubanArtist sharedInstance];
    NSURL *url = [NSURL URLWithString:[artist songs]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.delegate = self;
    request.didFinishSelector = @selector(didFinishLoad:);
    request.didFailSelector = @selector(didFailLoad:);
    [request startAsynchronous];
}

- (void) load:(NSURL *)url
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    request.delegate = self;
    request.didFinishSelector = @selector(didFinishLoad:);
    request.didFailSelector = @selector(didFailLoad:);
    [request startAsynchronous];
}

#pragma mark -
#pragma mark ASIHTTPRequest Delegate Methods

- (void)didFinishLoad:(ASIHTTPRequest *)request
{
    NSString *response = request.responseString;
    response = [self filter:response];
    //NSLog(@"response: %@", response);
    NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
    if (dict) {
        NSArray *songs = [dict objectForKey:@"songs"];
        if (songs) {
            [_songs removeAllObjects];
            for (NSDictionary *song in songs) {
                ArtisanSongsData *data = [[ArtisanSongsData alloc] init];
                data.artist = [song stringForKey:@"artist"];
                data.name = [song stringForKey:@"name"];
                data.length = [song stringForKey:@"length"];
                data.picture = [song stringForKey:@"picture"];
                data.src = [song stringForKey:@"src"];
                NSLog(@"count: %d, %@", _songs.count, [data description]);
                [_songs addObject:data];
                [data release];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kArtisanLoadSongsSuccess object:self];
        }
    }
    
}


- (void)didFailLoad:(ASIHTTPRequest *)request
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kArtisanLoadSongsFailed object:self];
}

@end
