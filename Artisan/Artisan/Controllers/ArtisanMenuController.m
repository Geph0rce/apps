//
//  ArtisanMenuController.m
//  Artisan
//
//  Created by roger qian on 13-1-25.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import "UIColor+MLPFlatColors.h"
#import "DDMenuController.h"

#import "ArtisanMenuItem.h"
#import "ArtisanMenuController.h"

#import "ArtisanSearchController.h"
#import "ArtisanSongsController.h"

#define kArtisanMenuItemSize CGSizeMake(240.0f, 60.0f)
#define kArtisanMenuItemBeginY 20.0f

#define kArtisanMenuMidGreen  [UIColor colorWithRed:CGColorConvert(89.0f) green:CGColorConvert(132.0f) blue:CGColorConvert(122.0f) alpha:1.0f]
#define kArtisanMenuMidDarkGreen  [UIColor colorWithRed:CGColorConvert(62.0f) green:CGColorConvert(89.0f) blue:CGColorConvert(83.0f) alpha:1.0f]

#define kArtisanMenuBlue [UIColor colorWithRed:CGColorConvert(0.0f) green:CGColorConvert(174.0f) blue:CGColorConvert(192.0f) alpha:1.0f]
#define kArtisanMenuDarkBlue [UIColor colorWithRed:CGColorConvert(0.0f) green:CGColorConvert(115.0f) blue:CGColorConvert(126.0f) alpha:1.0f]

#define kArtisanMenuPurple [UIColor colorWithRed:CGColorConvert(81.0f) green:CGColorConvert(56.0f) blue:CGColorConvert(88.0f) alpha:1.0f]
#define kArtisanMenuDarkPurple [UIColor colorWithRed:CGColorConvert(52.0f) green:CGColorConvert(36.0f) blue:CGColorConvert(55.0f) alpha:1.0f]


#define kArtisanMenuGreen [UIColor colorWithRed:CGColorConvert(111.0f) green:CGColorConvert(202.0f) blue:CGColorConvert(43.0f) alpha:1.0f]
#define kArtisanMenuDarkGreen [UIColor colorWithRed:CGColorConvert(74.0f) green:CGColorConvert(135.0f) blue:CGColorConvert(38.0f) alpha:1.0f]


@interface ArtisanMenuController ()
{
    @private
    DDMenuController *_menuController;
    ArtisanSongsController *_songsController;
    ArtisanSearchController *_searchController;
}

@property (nonatomic, retain) ArtisanSearchController *searchController;

@end

@implementation ArtisanMenuController

- (void)dealloc
{
    _menuController = nil;
    _songsController = nil;
    [_searchController release], _searchController = nil;
    
    [super dealloc];
}


- (void)menuItemClicked:(id)sender
{
    UIButton *menuItem = (UIButton *)sender;
    
    int type = menuItem.superview.tag;
    
    if (type == ArtisanMenuItemTypeHotSongs) {
        [_menuController setRootController:_songsController animated:YES];
    }
    else if (type == ArtisanMenuItemTypeHotArtists) {
    
    }
    else if (type == ArtisanMenuItemTypeSearch) {
        ArtisanSearchController *controller = [[ArtisanSearchController alloc] init];
        self.searchController = controller;
        [_menuController setRootController:controller animated:YES];
        [controller release];
    }
    else if (type == ArtisanMenuItemTypeSetteings) {
    
    }
    
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kArtisanBackgroundColor;
    
    CGFloat offsetY = kArtisanMenuItemBeginY;    
    NSArray *titleArray = [NSArray arrayWithObjects:@"热门单曲", @"热门音乐人", @"分类搜索", @"设置", nil];
    NSArray *imageArray = [NSArray arrayWithObjects:@"menu_latest", @"menu_saved", @"menu_search", @"menu_setting", nil];
    NSArray *colorArray = [NSArray arrayWithObjects:kArtisanMenuGreen, kArtisanMenuBlue, kArtisanMenuPurple, kArtisanMenuMidGreen, nil];
    NSArray *hlArray = [NSArray arrayWithObjects:kArtisanMenuDarkGreen, kArtisanMenuDarkBlue, kArtisanMenuDarkPurple, kArtisanMenuMidDarkGreen, nil];
    
    for (int i = 0; i < titleArray.count; i++) {
        ArtisanMenuItem *item = [[ArtisanMenuItem alloc] initWithFrame:CGRectMake(0.0f, offsetY, kArtisanMenuItemSize.width, kArtisanMenuItemSize.height)];
        item.tag = i;
        [item setImage:[UIImage imageNamed:[imageArray objectAtIndex:i]]];
        [item setTitle:[titleArray objectAtIndex:i]];
        [item setColor:[colorArray objectAtIndex:i] highlight:[hlArray objectAtIndex:i]];
        [item addTarget:self action:@selector(menuItemClicked:)];
        
        offsetY += CGRectGetHeight(item.frame) + 30.0f;
        [self.view addSubview:item];
        [item release];
    }
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _menuController = delegate.menuController;
    _songsController = delegate.songsController;
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
