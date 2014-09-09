//
//  ArtisanSearchController.m
//  Artisan
//
//  Created by roger on 13-8-19.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import "DoubanArtist.h"
#import "ArtisanLoadingView.h"
#import "ArtisanNavigationBar.h"

#import "ArtisanSearchController.h"
#import "ArtisanArtistsController.h"

#define kArtisanCategoryLeftItemTag 1000
#define kArtisanCategroyRightItemTag 1001

@interface ArtisanSearchController ()
{
    ArtisanLoadingView *_loading;
    UITableView *_category;
    NSMutableArray *_items;
}

- (NSDictionary *)dictionaryWithName:(NSString *)name andGid:(NSString *)gid;

@end

@implementation ArtisanSearchController


- (void)dealloc
{
    _loading = nil;
    _category = nil;
    [_items release], _items = nil;
    [super dealloc];
}


- (id)init
{
    if (self = [super init]) {
        _items = [[NSMutableArray alloc] init];
        [_items addObject:[self dictionaryWithName:@"流行" andGid:@"6"]];
        [_items addObject:[self dictionaryWithName:@"摇滚" andGid:@"8"]];
        [_items addObject:[self dictionaryWithName:@"电子" andGid:@"3"]];
        [_items addObject:[self dictionaryWithName:@"民谣" andGid:@"4"]];
        [_items addObject:[self dictionaryWithName:@"爵士" andGid:@"5"]];
        [_items addObject:[self dictionaryWithName:@"轻音乐" andGid:@"2"]];
        [_items addObject:[self dictionaryWithName:@"古典" andGid:@"1"]];
        [_items addObject:[self dictionaryWithName:@"说唱" andGid:@"7"]];
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    ArtisanNavigationBar *bar = [[ArtisanNavigationBar alloc] init];
    [bar addLeftItemWithStyle:ArtisanNavigationItemStyleMenu target:self action:@selector(menuClicked:)];
    [_container addSubview:bar];
    [bar release];
    
    
    
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 80.0f, 320.0f, CGRectGetHeight(_container.frame) - 80.0f)];
    table.allowsSelection = NO;
    table.backgroundColor = [UIColor clearColor];
    table.dataSource = self;
    table.delegate = self;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    _category = table;
    
    [_container addSubview:_category];
    [table release];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark utils

- (NSDictionary *)dictionaryWithName:(NSString *)name andGid:(NSString *)gid
{
    return [NSDictionary dictionaryWithObjectsAndKeys:name, @"name", gid, @"gid", nil];
}

- (void)menuClicked:(id)sender
{
    DDMenuController *menuController = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
    [menuController showLeftController:YES];
}

- (void)itemClicked:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    UIView *contentView = [btn superview];
    UITableViewCell *cell = (UITableViewCell *)[contentView superview];
    
    NSIndexPath *indexPath = [_category indexPathForCell:cell];
    int tag = btn.tag;
    if (indexPath) {
        int index = indexPath.row * 2 + (tag % 1000);
        NSDictionary *dict = [_items safeObjectAtIndex:index];
        if (dict) {
            NSString *gid = [dict stringForKey:@"gid"];
            DoubanArtist *artist = [DoubanArtist sharedInstance];
            NSURL *url = [NSURL URLWithString:[artist genre:gid]];
            ArtisanArtistsController *controller = [[ArtisanArtistsController alloc] init];
            controller.view.frame = self.view.bounds;
            [self presentViewController:controller option:ArtisanAnimationOptionHorizontal completion:^{
                [controller blockDDMenuControllerGesture:YES];
                [controller load:url];
            }];
            [controller release];
        }
    }
}

#pragma mark -
#pragma mark UITableViewDataSource and UITableViewDelegate

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count/2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"categoryItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        
        UIButton *leftItem = [UIButton buttonWithType:UIButtonTypeCustom];
        leftItem.tag = kArtisanCategoryLeftItemTag;
        [leftItem addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
        [leftItem setBackgroundImage:[UIImage imageWithColor:kArtisanMainColor] forState:UIControlStateNormal];
        [leftItem setBackgroundImage:[UIImage imageWithColor:kArtisanHighlight] forState:UIControlStateHighlighted];
        leftItem.titleLabel.font = kArtisanFont16;
        leftItem.titleLabel.textColor = [UIColor whiteColor];
        leftItem.frame = CGRectMake(10.0f, 0.0f, 145.0f, 80.0f);
        [cell.contentView addSubview:leftItem];
        
        UIButton *rightItem = [UIButton buttonWithType:UIButtonTypeCustom];
        rightItem.tag = kArtisanCategroyRightItemTag;
        [rightItem addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
        [rightItem setBackgroundImage:[UIImage imageWithColor:kArtisanMainColor] forState:UIControlStateNormal];
        [rightItem setBackgroundImage:[UIImage imageWithColor:kArtisanHighlight] forState:UIControlStateHighlighted];
        rightItem.titleLabel.font = kArtisanFont16;
        rightItem.titleLabel.textColor = [UIColor whiteColor];
        rightItem.frame = CGRectMake(165.0f, 0.0f, 145.0f, 80.0f);
        [cell.contentView addSubview:rightItem];
    }
    
    NSDictionary *leftData = [_items safeObjectAtIndex:indexPath.row * 2];
    NSDictionary *rightData = [_items safeObjectAtIndex:(indexPath.row * 2 + 1)];
    UIButton *leftItem = (UIButton *)[cell viewWithTag:kArtisanCategoryLeftItemTag];
    UIButton *rightItem = (UIButton *)[cell viewWithTag:kArtisanCategroyRightItemTag];
    if (leftData) {
        NSString *name = [leftData stringForKey:@"name"];
        [leftItem setTitle:name forState:UIControlStateNormal];
    }
    
    if (rightData) {
        NSString *name = [rightData stringForKey:@"name"];
        [rightItem setTitle:name forState:UIControlStateNormal];
    }
    
    return cell;
}

@end
