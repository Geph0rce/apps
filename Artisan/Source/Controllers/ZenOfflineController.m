//
//  ZenOfflineController.m
//  Artisan
//
//  Created by roger on 14-9-24.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "ZenNavigationBar.h"
#import "ZenSongCell.h"
#import "ZenOfflineModel.h"
#import "ZenOfflineController.h"
#import "ZenPlayerController.h"

#define kZenOfflineCellId @"ZenOfflineCell"

@interface ZenOfflineController () <UITableViewDataSource, UITableViewDelegate>
{
    ZenOfflineModel *_model;
    UITableView *_table;
}
@end

@implementation ZenOfflineController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    _model = [ZenOfflineModel sharedInstance];
    [defaultCenter addObserver:self selector:@selector(offlineStateChanged:) name:kZenOfflineStateChange object:_model];
    
    ZenNavigationBar *bar = [[ZenNavigationBar alloc] init];
    [bar addLeftItemWithStyle:ZenNavigationItemStyleMenu target:self action:@selector(menu:)];
    [bar setTitle:@"离线"];
    [_container addSubview:bar];
    
    UITableView *table = [[UITableView alloc] initWithFrame:_container.bounds];
    _table = table;
    _table.delegate = self;
    _table.dataSource = self;
    _table.scrollsToTop = YES;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_table setAllowsSelection:YES];
    [_container addSubview:table];
    _table.frame = CGRectMake(0.0f, bar.height, CGRectGetWidth(_container.frame), CGRectGetHeight(_container.frame) - bar.height);
    
    [_table registerNib:[UINib nibWithNibName:@"ZenSongCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kZenOfflineCellId];
    [self enablePanRightGestureWithDismissBlock:NULL];
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
#pragma mark UITableViewDataSource and UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _model.offline.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZenSongData *song = _model.offline[indexPath.row];
    ZenSongCell *cell = [tableView dequeueReusableCellWithIdentifier:kZenOfflineCellId];
    [cell load:song];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        ZenPlayerController *controller = [ZenPlayerController sharedInstance];
        controller.list = [[NSMutableArray alloc] initWithArray:_model.offline];
        controller.index = indexPath.row;
        controller.view.frame = _container.bounds;
        [self presentViewController:controller option:ZenAnimationOptionHorizontal completion:NULL];
    }
    @catch (NSException *exception) {
        NSLog(@"exception: %@", [exception description]);
    }
}


#pragma mark
#pragma mark Handle Notifications from ZenOfflineModel

- (void)offlineStateChanged:(NSNotification *)notification
{
    [_table reloadData];
}

@end
