//
//  ArtisanSongsController.m
//  Artisan
//
//  Created by roger on 13-8-2.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import "EGORefreshTableHeaderView.h"
#import "ArtisanNavigationBar.h"
#import "ArtisanLoadingView.h"

#import "ArtisanPlayerController.h"

#import "ArtisanSongsModel.h"
#import "ArtisanSongsItem.h"
#import "ArtisanSongsController.h"

#define kArtisanSongsItemTag 1001

@interface ArtisanSongsController ()
{
    ArtisanSongsModel *_model;
    UITableView *_songs;
    EGORefreshTableHeaderView *_headerView;
    ArtisanLoadingView *_loading;
    BOOL _reloading;
}

@property (nonatomic, retain) ArtisanSongsModel *model;

- (void)reloadData;
- (void)doneReloadingData;

@end

@implementation ArtisanSongsController
@synthesize model = _model;
@synthesize mode = _mode;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_model release], _model = nil;
    _headerView = nil;
    _loading = nil;
    
    [super dealloc];
}

- (id)initWithMode:(ArtisanSongsListMode)mode
{
    if(self = [super init]) {
        _headerView = nil;
        _mode = mode;
    }
    
    return self;
}

- (id)init
{
    if(self = [super init]) {
        _headerView = nil;
        _mode = ArtisanSongsListModeFull;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    ArtisanSongsModel *model = [[ArtisanSongsModel alloc] init];
    self.model = model;
    [model release];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(songsDidFinishedLoad:) name:kArtisanLoadSongsSuccess object:_model];
    [defaultCenter addObserver:self selector:@selector(songsDidFailedLoad:) name:kArtisanLoadSongsFailed object:_model];
    
    ArtisanNavigationBar *bar = [[ArtisanNavigationBar alloc] init];
    if (_mode == ArtisanSongsListModeFull) {
        [bar addLeftItemWithStyle:ArtisanNavigationItemStyleMenu target:self action:@selector(menuClicked:)];
    }
    else {
        [bar addLeftItemWithStyle:ArtisanNavigationItemStyleBack target:self action:@selector(backClicked:)];
    }
    
    [_container addSubview:bar];
    CGFloat tableHeight = CGRectGetMaxY(bar.frame);
    [bar release];
    
    UITableView *songs = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, tableHeight, CGRectGetWidth(_container.frame), CGRectGetHeight(_container.frame) - tableHeight)];
    songs.dataSource = self;
    songs.delegate = self;
    songs.separatorStyle = UITableViewCellSeparatorStyleNone;
    _songs = songs;
    [_container addSubview:songs];
    [songs release];
    
    if (_mode == ArtisanSongsListModeFull) {
        EGORefreshTableHeaderView *header = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, - CGRectGetHeight(_songs.frame), CGRectGetWidth(_songs.frame), CGRectGetHeight(_songs.frame))];
        header.delegate = (id<EGORefreshTableHeaderDelegate>)self;
        _headerView = header;
        [_songs addSubview:header];
        [header release];
        
        _reloading = NO;
        [_headerView pullTheTrigle:_songs];
    }
    else {
        ArtisanLoadingView *loading = [[ArtisanLoadingView alloc] initWithFrame:CGRectMake(0.0f, -30.0f, 320.0f, 30.0f)];
        _loading = loading;
        [_container addSubview:_loading];
        [loading release];
        
        [self enablePanRightGestureWithDismissBlock:NULL];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark -
#pragma mark Utils

- (void)load:(NSURL *)url
{
    if (_loading && _mode == ArtisanSongsListModeSimple) {
        [_loading show];
        [_model load:url];
    }
}

- (void)menuClicked:(id)sender
{
    DDMenuController *menuController = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
    [menuController showLeftController:YES];
}

- (void)backClicked:(id)sender
{
    [self dismissViewControllerWithOption:ArtisanAnimationOptionHorizontal completion:NULL];
}

#pragma mark -
#pragma mark Handle Notifications & NavigationBar Events

- (void)songsDidFinishedLoad:(NSNotification *)notification
{
    if (_model.songs.count > 0) {
        [_songs reloadData];
    }
    if (_headerView && _mode == ArtisanSongsListModeFull) {
        [self doneReloadingData];
    }
    else if (_loading && _mode == ArtisanSongsListModeSimple) {
        [_loading hide];
    }
}

- (void)songsDidFailedLoad:(NSNotification *)notification
{
    if (_headerView && _mode == ArtisanSongsListModeFull) {
        [self doneReloadingData];
    }
    else if (_loading && _mode == ArtisanSongsListModeSimple) {
        [_loading hide];
    }
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadData
{
    _reloading = YES;
    [_model fetchSongs];
}

- (void)doneReloadingData
{
	_reloading = NO;
	[_headerView egoRefreshScrollViewDataSourceDidFinishedLoading:_songs];
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_headerView && _mode == ArtisanSongsListModeFull) {
        [_headerView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_headerView && _mode == ArtisanSongsListModeFull) {
        [_headerView egoRefreshScrollViewDidEndDragging:scrollView];
        
    }
}



#pragma mark -
#pragma egoRefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self reloadData];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _reloading;
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}


#pragma mark -
#pragma UITableViewDataSource & UITableViewDelegate Methods

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_model.songs count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (_mode == ArtisanSongsListModeFull? 70.0f : 44.0f);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ArtisanSongsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *backColor = [[UIView alloc] initWithFrame:cell.frame];
        backColor.backgroundColor = [UIColor colorWithRed:CGColorConvert(217.0f) green:CGColorConvert(217.0f) blue:CGColorConvert(216.0f) alpha:0.8f];
        cell.selectedBackgroundView = backColor;
        [backColor release];
        if (_mode == ArtisanSongsListModeFull) {
            ArtisanSongsItem *item = [[ArtisanSongsItem alloc] init];
            item.tag = kArtisanSongsItemTag;
            [cell.contentView addSubview:item];
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            CGRect frame = CGRectMake(10.0f, (cell.bounds.size.height - 16.0f)/2.0f, 280.0f, 16.0f);
            UILabel *title = [[UILabel alloc] initWithFrame:frame];
            title.tag = kArtisanSongsItemTag;
            title.font = kArtisanFont16;
            title.textColor = [UIColor blackColor];
            title.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:title];
            [title release];
        }
        
    }
    
    if (_mode == ArtisanSongsListModeFull) {
        ArtisanSongsItem *item = (ArtisanSongsItem *)[cell.contentView viewWithTag:kArtisanSongsItemTag];
        ArtisanSongsData *data = [_model.songs safeObjectAtIndex:indexPath.row];
        if (item && data) {
            [item load:data];
        }
       
    }
    else {
        UILabel *title = (UILabel *)[cell viewWithTag:kArtisanSongsItemTag];
        ArtisanSongsData *data = [_model.songs safeObjectAtIndex:indexPath.row];
        if (title && data) {
            title.text = data.name;
        }
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ArtisanPlayerController *controller = [ArtisanPlayerController sharedInstance];
    controller.view.frame = self.view.bounds;
    controller.model = _model;
    controller.index = indexPath.row;
    [self presentViewController:controller option:ArtisanAnimationOptionHorizontal completion:^{
        [controller blockDDMenuControllerGesture:YES];
        [controller load];
    }];
}

@end
