//
//  ZenHotSongsController.m
//  Artisan
//
//  Created by roger on 14-9-9.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "ZenHotSongsModel.h"
#import "ZenNavigationBar.h"
#import "ZenSongCell.h"
#import "ZenHotSongsController.h"

#define kZenSongCellId @"ZenSongCellId"

@interface ZenHotSongsController ()
{
    ZenHotSongsModel *_model;
}
@end

@implementation ZenHotSongsController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
    _model = [[ZenHotSongsModel alloc] init];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(requestFinished:) name:kZenHotSongsRequestFinished object:_model];
    [defaultCenter addObserver:self selector:@selector(requestFailed:) name:kZenHotSongsRequestFailed object:_model];
    
    ZenNavigationBar *bar = [[ZenNavigationBar alloc] init];
    [bar addLeftItemWithStyle:ZenNavigationItemStyleMenu target:self action:@selector(menu:)];
    [bar setTitle:@"热门单曲"];
    [_container addSubview:bar];
    _table.frame = CGRectMake(0.0f, bar.height, CGRectGetWidth(_container.frame), CGRectGetHeight(_container.frame) - bar.height);
    
    UINib *nib = [UINib nibWithNibName:@"ZenSongCell" bundle:[NSBundle mainBundle]];
    [_table registerNib:nib forCellReuseIdentifier:kZenSongCellId];
    [self load];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)menu:(id)sender
{
    DDMenuController *menuController = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
    [menuController showLeftController:YES];
}

#pragma mark
#pragma mark override model load methods

- (void)modelReload
{
    [_model refresh];
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
    ZenSongCell *cell = [tableView dequeueReusableCellWithIdentifier:kZenSongCellId];
    [cell load:song];
    return cell;
}

#pragma mark 
#pragma mark Handel Notifications From Model 

- (void)requestFinished:(NSNotification *)notification
{
    [self done];
    [_table reloadData];
}

- (void)requestFailed:(NSNotification *)notification
{
    [self done];
    [self failed:@"加载失败..."];
}

@end
