//
//  ZenPlayerController.m
//  Artisan
//
//  Created by roger on 14-9-11.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "Singleton.h"
#import "ZenCategory.h"
#import "ZenNavigationBar.h"
#import "ZenPlayerView.h"
#import "ZenPlayerCell.h"
#import "ZenPlayerController.h"

#define kZenPlayerCellId @"ZenPlayerCellId"
#define kZenPlayerHeight 160.0f

@interface ZenPlayerController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_table;
    ZenPlayerView *_player;
}

@property (nonatomic, strong) ZenPlayerView *player;

@end

@implementation ZenPlayerController

SINGLETON_FOR_CLASS(ZenPlayerController);

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ZenNavigationBar *bar = [[ZenNavigationBar alloc] init];
    [bar addLeftItemWithStyle:ZenNavigationItemStyleBack target:self action:@selector(back:)];
    [_container addSubview:bar];
    
    _table = [[UITableView alloc] initWithFrame:_container.bounds];
    _table.delegate = self;
    _table.dataSource = self;
    _table.scrollsToTop = YES;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_table setAllowsSelection:NO];
    [_container addSubview:_table];
    _table.frame = CGRectMake(0.0f, bar.height, CGRectGetWidth(_container.frame), CGRectGetHeight(_container.frame) - bar.height - kZenPlayerHeight);
    
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ZenPlayerView" owner:self options:NULL];
    if (array && array.count > 0) {
        self.player = array[0];
        CGRect frame = _player.frame;
        frame.origin.y = CGRectGetHeight(_container.frame) - kZenPlayerHeight;
        _player.frame = frame;
        [_container addSubview:_player];
    }
    
    [_table registerNib:[UINib nibWithNibName:@"ZenPlayerCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kZenPlayerCellId];
    [self enablePanRightGestureWithDismissBlock:NULL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ZenSongData *song = [_list safeObjectAtIndex:_index];
    if (song) {
        [_player load:song];
    }
    [_table reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back:(id)sender
{
    [self dismissViewControllerWithOption:ZenAnimationOptionHorizontal completion:NULL];
}
#pragma mark
#pragma mark UITableViewDataSource and UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _list.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZenSongData *song = _list[indexPath.row];
    ZenPlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:kZenPlayerCellId];
    [cell load:song];
    return cell;
}


@end
