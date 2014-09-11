//
//  ZenPlaylistController.m
//  Artisan
//
//  Created by roger on 14-9-11.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "ZenNavigationBar.h"
#import "ZenPlaylistModel.h"
#import "ZenSongCell.h"
#import "ZenPlaylistController.h"

#define kZenPlaylistCellId @"ZenPlaylistCellId"

@interface ZenPlaylistController ()
{
    ZenPlaylistModel *_model;
}
@end

@implementation ZenPlaylistController

- (id)init
{
    self = [super init];
    if (self) {
        _enableLoadMore = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _model = [[ZenPlaylistModel alloc] init];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(requestFinished:) name:kZenPlaylistRequestFinished object:_model];
    [defaultCenter addObserver:self selector:@selector(requestFailed:) name:kZenPlaylistRequestFailed object:_model];
    
    ZenNavigationBar *bar = [[ZenNavigationBar alloc] init];
    [bar addLeftItemWithStyle:ZenNavigationItemStyleBack target:self action:@selector(back:)];
    [bar setTitle:_name];
    [_container addSubview:bar];
    _table.frame = CGRectMake(0.0f, bar.height, CGRectGetWidth(_container.frame), CGRectGetHeight(_container.frame) - bar.height);
    
    [_table registerNib:[UINib nibWithNibName:@"ZenSongCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kZenPlaylistCellId];
    [self enablePanRightGestureWithDismissBlock:NULL];
    [self load];
}


- (void)back:(id)sender
{
    [self dismissViewControllerWithOption:ZenAnimationOptionHorizontal completion:NULL];
}

#pragma mark
#pragma mark override model load methods

- (void)modelReload
{
    [_model load:_pid];
}

#pragma mark
#pragma mark UITableViewDataSource and UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _model.list.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZenSongData *song = _model.list[indexPath.row];
    ZenSongCell *cell = [tableView dequeueReusableCellWithIdentifier:kZenPlaylistCellId];
    [cell load:song];
    return cell;
}

#pragma mark
#pragma mark Handel Notifications From Model

- (void)requestFinished:(NSNotification *)notification
{
    [_table reloadData];
    [self done];
}

- (void)requestFailed:(NSNotification *)notification
{
    [self done];
    [self failed:@"加载失败..."];
}


@end
