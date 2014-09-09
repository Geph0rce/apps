//
//  ArtisanNavigationBar.h
//  Artisan
//
//  Created by roger on 13-8-5.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    ArtisanNavigationItemStyleNone = 0,
    ArtisanNavigationItemStyleMenu,
    ArtisanNavigationItemStyleBack,
    ArtisanNavigationItemStyleRefresh,
    ArtisanNavigationItemStyleSafari,
    ArtisanNavigationItemStyleShare    
}ArtisanNavigationItemStyle;

@interface ArtisanNavigationBar : UIView
{
    UIImageView *_leftIcon;
    UIButton *_leftBtn;
    UIImageView *_rightIcon;
    UIButton *_rightBtn;
}

- (void) setTitle:(NSString *)title;

- (void) addLeftItemWithStyle:(ArtisanNavigationItemStyle)style target:(id)target action:(SEL)action;
- (void) addRightItemWithStyle:(ArtisanNavigationItemStyle)style target:(id)target action:(SEL)action;
- (void)addRightItemWithStyle:(ArtisanNavigationItemStyle)style middle:(BOOL)middle target:(id)target action:(SEL)action;

@end
