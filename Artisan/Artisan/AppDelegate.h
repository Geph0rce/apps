//
//  AppDelegate.h
//  Artisan
//
//  Created by roger on 13-8-2.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDMenuController;
@class ArtisanSongsController;
@class ArtisanMenuController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) ArtisanSongsController *songsController;
@property (nonatomic, retain) DDMenuController *menuController;
@property (nonatomic, retain) ArtisanMenuController *leftController;
@end
