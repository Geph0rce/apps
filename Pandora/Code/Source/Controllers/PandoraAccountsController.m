//
//  PandoraAccountsController.m
//  Zen
//
//  Created by roger on 14-7-10.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "AppDelegate.h"
#import "ZenMacros.h"
#import "ZenCategory.h"
#import "ZenNavigationBar.h"
#import "ZenLoadingView.h"

#import "PandoraFileListController.h"
#import "PandoraLoginController.h"
#import "PandoraUserManager.h"
#import "PandoraEmptyView.h"
#import "PandoraAccountsHeader.h"
#import "PandoraAccountsController.h"

@interface PandoraAccountsController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    PandoraUserManager *_model;
    ZenLoadingView *_loading;
    UITableView *_accounts;
    PandoraEmptyView *_empty;
    ZenNavigationBar *_bar;
}
@end

@implementation PandoraAccountsController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _model = [PandoraUserManager sharedInstance];
    
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [background setImage:[UIImage imageNamed:@"pandora_bg"]];
    [self.view addSubview:background];
    
    ZenNavigationBar *bar = [[ZenNavigationBar alloc] init];
    _bar = bar;
    //[bar addLeftItemWithStyle:ZenNavigationItemStyleMenu target:self action:@selector(menu:)];
    //[bar addRightButtonWithTarget:self action:@selector(edit:)];
    //[bar setRightButtonTitle:@"编辑"];
    [bar setTitle:@"潘多拉"];
    
    CGFloat barHeight = bar.height;
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, barHeight, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - barHeight)];
    _accounts = table;
    table.delegate = self;
    table.dataSource = self;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [table setAllowsSelection:YES];
    [table setBackgroundColor:kZenBackgroundColor];
    [self.view addSubview:table];
    
    ZenLoadingView *loading = [[ZenLoadingView alloc] init];
    loading.type = ZenLoadingViewTypeUnderNavigationBar;
    [loading setTitle:@"正在加载..."];
    _loading = loading;
    
    [self.view addSubview:loading];
    [self.view addSubview:bar];
    
    PandoraEmptyView *empty = [[PandoraEmptyView alloc] init];
    _empty = empty;
    [empty setTitle:@"还未添加百度云账号～"];
    [self.view addSubview:empty];
    _empty.hidden = YES;
    [empty centerInGravity];
    if (_model.users.count <= 0) {
        empty.hidden = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_accounts reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)edit:(id)sender
{
    if (_accounts.isEditing) {
        [_bar setRightButtonTitle:@"编辑"];
        [_accounts setEditing:NO animated:YES];
    }
    else {
        [_bar setRightButtonTitle:@"完成"];
        [_accounts setEditing:YES animated:YES];
    }
    
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addAccount:(id)sender
{
    PandoraLoginController *controller = [[PandoraLoginController alloc] init];
    controller.view.frame = self.view.bounds;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark
#pragma mark UITableViewDelegate UITableViewDataSource Methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _model.users.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 45.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addAccount:)];
    UILabel *addUser = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), 45.0f)];
    addUser.userInteractionEnabled = YES;
    addUser.backgroundColor = kZenBackgroundColor;
    addUser.font = kZenFont15;
    addUser.textColor = kZenMainFontColor;
    addUser.textAlignment = NSTextAlignmentCenter;
    addUser.text = @"添加百度云账户";
    [addUser addGestureRecognizer:tap];
    return addUser;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *accountCellID = @"AccountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:accountCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:accountCellID];
        UIView *backColor = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView = backColor;
        cell.textLabel.font = kZenFont15;
    }
    cell.backgroundColor = kZenBackgroundColor;
    cell.selectedBackgroundView.backgroundColor = kZenHighlightColor;
    cell.textLabel.textColor = kZenMainFontColor;
    PandoraUser *user = _model.users[indexPath.row];
    cell.textLabel.text = user.name;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PandoraUser *user = _model.users[indexPath.row];
    PandoraFileListController *controller = [[PandoraFileListController alloc] init];
    controller.type = PandoraNavigationTypeBack;
    controller.name = user.name;
    controller.path = @"/";
    controller.token = user.token;
    controller.view.frame = self.view.bounds;
    [self.navigationController pushViewController:controller animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [_model remove:indexPath.row];
        [_accounts deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                       withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
