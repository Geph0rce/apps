//
//  ArtisanArtistsController.m
//  Artisan
//
//  Created by roger on 13-8-19.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import "DoubanArtist.h"

#import "ArtisanLoadingView.h"
#import "ArtisanNavigationBar.h"

#import "ArtisanArtistsModel.h"
#import "ArtisanArtistsItem.h"
#import "ArtisanArtistsController.h"
#import "ArtisanPlaylistController.h"

#define kArtisanArtistsItemTag 1001

@interface ArtisanArtistsController ()
{
    ArtisanArtistsModel *_model;
    ArtisanLoadingView *_loading;
    UITableView *_artists;
    
}
@property (nonatomic, retain)  ArtisanArtistsModel *model;

@end

@implementation ArtisanArtistsController
@synthesize model = _model;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _artists = nil;
    [_model cancel];
    [_model release], _model = nil;
    [super dealloc];
}

- (id)init
{
    if (self = [super init]) {
        ArtisanArtistsModel *model = [[ArtisanArtistsModel alloc] init];
        self.model = model;
        [model release];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(artistsDidFinishLoad:) name:kArtisanLoadArtistsSuccess object:_model];
    [defaultCenter addObserver:self selector:@selector(artistsDidFailedLoad:) name:kArtisanLoadArtistsFailed object:_model];
    
    ArtisanNavigationBar *bar = [[ArtisanNavigationBar alloc] init];
    [bar addLeftItemWithStyle:ArtisanNavigationItemStyleBack target:self action:@selector(backClicked:)];
    [_container addSubview:bar];
    [bar release];
    
    ArtisanLoadingView *loading = [[ArtisanLoadingView alloc] initWithFrame:CGRectMake(0.0f, -30.0f, 320.0f, 30.0f)];
    _loading = loading;
    [_container addSubview:_loading];
    [loading release];
    
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 44.0f, 320.0f, CGRectGetHeight(_container.frame) - 44.0f) style:UITableViewStylePlain];
    _artists = table;
    _artists.backgroundColor = [UIColor clearColor];
    _artists.separatorStyle = UITableViewCellSeparatorStyleNone;
    _artists.dataSource = self;
    _artists.delegate = self;
    [_container addSubview:_artists];
    [table release];
    
    __block ArtisanArtistsController *controller = self;
    [self enablePanRightGestureWithDismissBlock:^{
        [controller blockDDMenuControllerGesture:NO];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 
#pragma mark Utils

- (void)backClicked:(id)sender
{
    [self dismissViewControllerWithOption:ArtisanAnimationOptionHorizontal completion:^{
        [self blockDDMenuControllerGesture:NO];
    }];
}

- (void)load:(NSURL *)url
{
    [_loading show];
    [_model load:url];
}

#pragma mark -
#pragma mark Notification Stuff

- (void)artistsDidFinishLoad:(NSNotification *)notification
{
    [_loading hide];
    [_artists reloadData];
}

- (void)artistsDidFailedLoad:(NSNotification *)notification
{
    [_loading hide];
}


#pragma mark -
#pragma mark UITableViewDataSource and UITableViewDelegate

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _model.artists.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ArtisanArtistCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        
        UIView *backColor = [[UIView alloc] initWithFrame:cell.frame];
        backColor.backgroundColor = [UIColor colorWithRed:CGColorConvert(217.0f) green:CGColorConvert(217.0f) blue:CGColorConvert(216.0f) alpha:0.8f];
        cell.selectedBackgroundView = backColor;
        [backColor release];
        
        ArtisanArtistsItem *item = [[ArtisanArtistsItem alloc] init];
        item.tag = kArtisanArtistsItemTag;
        [cell.contentView addSubview:item];
        [item release];
    }
    
    ArtisanArtistsItem *item = (ArtisanArtistsItem *)[cell viewWithTag:kArtisanArtistsItemTag];
    if (item) {
        ArtisanArtistData *data = [_model.artists safeObjectAtIndex:indexPath.row];
        if (data) {
            [item load:data];
        }
    }
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ArtisanArtistData *data = [_model.artists safeObjectAtIndex:indexPath.row];
    if (data) {
        DoubanArtist *artist = [DoubanArtist sharedInstance];
        NSURL *url = [NSURL URLWithString:[artist playlist:data.aid]];
        ArtisanPlaylistController *controller = [[ArtisanPlaylistController alloc] init];
        controller.view.frame = self.view.bounds;
        [self presentViewController:controller option:ArtisanAnimationOptionHorizontal completion:^{
            [controller load:url];
        }];
        [controller release];
    }
}

@end
