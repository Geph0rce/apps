//
//  PandoraFileListController.m
//  Zen
//
//  Created by roger on 14-7-14.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "AppDelegate.h"
#import "EGORefreshTableHeaderView.h"
#import "EGOLoadMoreTableFooterView.h"

#import "ZenMacros.h"
#import "ZenCategory.h"
#import "ZenNavigationBar.h"
#import "PandoraFileListModel.h"
#import "PandoraFileCell.h"
#import "PandoraFileListController.h"

#import "PandoraWebViewController.h"


@interface PandoraFileListController () <UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate>
{
    PandoraFileListModel *_model;
    EGORefreshTableHeaderView *_headerView;
    UITableView *_files;
    BOOL _reloading;
}
@end

@implementation PandoraFileListController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _model = [[PandoraFileListModel alloc] init];
    _model.token = _token;
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(requestFinished:) name:kPandoraFileListLoadFinished object:_model];
    [defaultCenter addObserver:self selector:@selector(requestFailed:) name:kPandoraFileListLoadFailed object:_model];
    
    
    ZenNavigationBar *bar = [[ZenNavigationBar alloc] init];
    if (_type == PandoraNavigationTypeBack) {
        [bar addLeftItemWithStyle:ZenNavigationItemStyleBack target:self action:@selector(back:)];
    }
    
    [bar setTitle:_name];
    [self.view addSubview:bar];
    CGFloat barHeight = bar.height;
    
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, barHeight, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - barHeight)];
    _files = table;
    _files.delegate = self;
    _files.dataSource = self;
    _files.scrollsToTop = YES;
    _files.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_files setAllowsSelection:YES];
    [_files setBackgroundColor:kZenBackgroundColor];
    [self.view addSubview:table];
    
    EGORefreshTableHeaderView *header = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, - CGRectGetHeight(_files.frame), CGRectGetWidth(_files.frame), CGRectGetHeight(_files.frame))];
    header.delegate = self;
    _headerView = header;
    [_files addSubview:header];
    
    [_headerView pullTheTrigle:_files];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_headerView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_headerView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return YES;
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadData
{
	[_model load:_path];
    _reloading = YES;
}

- (void)doneReloadingData
{
    
    _reloading = NO;
	[_headerView egoRefreshScrollViewDataSourceDidFinishedLoading:_files];
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

#pragma mark -
#pragma EGOLoadMoreTableFooterDelegate Methods

- (BOOL)egoLoadMoreTableFooterDidTriggerLoadMore:(EGOLoadMoreTableFooterView *)view
{
    
    return YES;
}

- (BOOL)egoLoadMoreTableFooterDataSourceIsLoading:(EGOLoadMoreTableFooterView *)view
{
    return YES;
}

#pragma mark -
#pragma mark UITableViewDataSource and UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _model.files.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *PandoraCellId = @"PandoraFileCell";
    PandoraFileCell *cell = [tableView dequeueReusableCellWithIdentifier:PandoraCellId];
    if (!cell) {
        cell = [[PandoraFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PandoraCellId];
        UIView *backColor = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView = backColor;
    }
    
    cell.backgroundColor = kZenBackgroundColor;
    cell.selectedBackgroundView.backgroundColor = kZenHighlightColor;
    
    
    PandoraFile *file = [_model.files safeObjectAtIndex:indexPath.row];
    if (file) {
        [cell load:file];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PandoraFile *file = _model.files[indexPath.row];
    if (file.isdir) {
        PandoraFileListController *controller = [[PandoraFileListController alloc] init];
        controller.type = PandoraNavigationTypeBack;
        controller.name = file.name;
        controller.path = file.path;
        controller.token = _token;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if (file.category == PandoraFileTypeVideo){
        
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://pcs.baidu.com/rest/2.0/pcs/file?method=streaming&type=M3U8_640_480&app_id=250528&path=%@", [file.path urlEncode]]];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://pan.baidu.com/play/video#video/path=%@&t=-1", [file.path urlEncode]]];
        PandoraWebViewController *controller = [[PandoraWebViewController alloc] init];
        controller.token = _token;
        controller.view.frame = self.view.bounds;
        [self.navigationController presentViewController:controller animated:YES completion:^{
            [controller loadURL:url];
        }];
        
    }
    else {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://pan.baidu.com/wap/view?fsid=%@", file.fsId]];
        PandoraWebViewController *controller = [[PandoraWebViewController alloc] init];
        controller.token = _token;
        controller.view.frame = self.view.bounds;
        [self.navigationController presentViewController:controller animated:YES completion:^{
            [controller loadURL:url];
        }];
    }
}

#pragma mark
#pragma mark PandoraFileListModel Notification Handler

- (void)requestFinished:(NSNotification *)notification
{
    [self doneReloadingData];
    [_files reloadData];
}

- (void)requestFailed:(NSNotification *)notification
{
    [self doneReloadingData];
    [self failed:@"加载失败..."];
}

@end
