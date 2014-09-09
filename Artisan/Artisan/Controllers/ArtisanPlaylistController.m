//
//  ArtisanPlaylistController.m
//  Artisan
//
//  Created by roger on 13-8-20.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//


#import "DoubanArtist.h"
#import "ArtisanNavigationBar.h"
#import "ArtisanLoadingView.h"

#import "ArtisanPlaylistModel.h"
#import "ArtisanProfile.h"
#import "ArtisanPlaylistController.h"

#import "ArtisanSongsController.h"

#define kArtisanPlaylistTitleTag 1001

@interface ArtisanPlaylistController ()
{
    ArtisanPlaylistModel *_model;
    ArtisanLoadingView *_loading;
    ArtisanProfile *_profile;
    UITableView *_playlist;
}
@end

@implementation ArtisanPlaylistController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_model release], _model = nil;
    _loading = nil;
    _profile = nil;
    _playlist = nil;
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _model = [[ArtisanPlaylistModel alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(playlistsDidFinishedLoad:) name:kArtisanLoadPlaylistsSuccess object:_model];
    [defaultCenter addObserver:self selector:@selector(playlistsDidFailedLoad:) name:kArtisanLoadPlaylistsFailed object:_model];
    
    ArtisanNavigationBar *bar = [[ArtisanNavigationBar alloc] init];
    [bar addLeftItemWithStyle:ArtisanNavigationItemStyleBack target:self action:@selector(backClicked:)];
    [_container addSubview:bar];
    [bar release];
    
    ArtisanLoadingView *loading = [[ArtisanLoadingView alloc] initWithFrame:CGRectMake(0.0f, -30.0f, 320.0f, 30.0f)];
    _loading = loading;
    [_container addSubview:_loading];
    [loading release];
    
    ArtisanProfile *profile = [[ArtisanProfile alloc] initWithFrame:CGRectMake(0.0f, 44.0f, 320.0f, 70.0f)];
    _profile = profile;
    [_container addSubview:_profile];
    [profile release];
    
    CGFloat height = CGRectGetMaxY(_profile.frame) + 5.0f;
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, height, 320.0f, CGRectGetHeight(_container.frame) - height)];
    _playlist = table;
    _playlist.dataSource = self;
    _playlist.delegate = self;
    _playlist.backgroundColor = [UIColor clearColor];
    _playlist.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_container addSubview:_playlist];
    [table release];
    
    [self enablePanRightGestureWithDismissBlock:NULL];
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
    [self dismissViewControllerWithOption:ArtisanAnimationOptionHorizontal completion:NULL];
}

- (void)load:(NSURL *)url
{
    [_loading show];
    [_model load:url];
}

- (void)refresh
{
    [_profile load:_model.profile];
    [_playlist reloadData];
}

#pragma mark -
#pragma mark Notification Stuff

- (void)playlistsDidFinishedLoad:(NSNotification *)notification
{
    [_loading hide];
    [self refresh];
}


- (void)playlistsDidFailedLoad:(NSNotification *)notification
{
    [self postMessage:@"加载失败" type:ArtisanStatusBarOverlayTypeWarning];
}

#pragma mark -
#pragma mark UITableViewDataSource and UITableViewDelegate

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_model.playlists count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ArtisanPlaylistCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UIView *backColor = [[UIView alloc] initWithFrame:cell.frame];
        backColor.backgroundColor = [UIColor colorWithRed:CGColorConvert(217.0f) green:CGColorConvert(217.0f) blue:CGColorConvert(216.0f) alpha:0.8f];
        cell.selectedBackgroundView = backColor;
        [backColor release];
        
        CGRect frame = CGRectMake(10.0f, (cell.bounds.size.height - 16.0f)/2.0f, 280.0f, 16.0f);
        UILabel *title = [[UILabel alloc] initWithFrame:frame];
        title.tag = kArtisanPlaylistTitleTag;
        title.font = kArtisanFont16;
        title.textColor = [UIColor blackColor];
        title.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:title];
        [title release];
        
        UIColor *border_bg = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_border"]];
        UIView *border = [[UIView alloc] initWithFrame:CGRectMake(15.0f, CGRectGetHeight(cell.bounds) - 1.0f, 290.0f, 1.0f)];
        border.backgroundColor = border_bg;
        [cell.contentView addSubview:border];
        [border release];
    }
    
    UILabel *title = (UILabel *)[cell viewWithTag:kArtisanPlaylistTitleTag];

    NSMutableArray *playlist = _model.playlists;
    ArtisanPlaylistData *data = [playlist safeObjectAtIndex:indexPath.row];
    if (data) {
        title.text = data.title;
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *playlist = _model.playlists;
    ArtisanPlaylistData *data = [playlist safeObjectAtIndex:indexPath.row];
    if (data) {
        DoubanArtist *artist = [DoubanArtist sharedInstance];
        NSURL *url = [NSURL URLWithString:[artist songs:data.pid]];
        ArtisanSongsController *controller = [[ArtisanSongsController alloc] initWithMode:ArtisanSongsListModeSimple];
        controller.view.frame = self.view.bounds;
        
        [self presentViewController:controller option:ArtisanAnimationOptionHorizontal completion:^{
            [controller load:url];
        }];
        [controller release];
    }
}

@end
