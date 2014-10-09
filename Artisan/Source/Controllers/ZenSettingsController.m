//
//  ZenSettingsController.m
//  Artisan
//
//  Created by roger on 14-10-9.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "ZenMacros.h"
#import "ZenConfig.h"
#import "ZenNavigationBar.h"
#import "ZenSettingsController.h"

#define kZenTimeLabelColor ZenColorFromRGB(0x1abc9c)

@interface ZenSettingsController ()
{
    ZenConfig *_config;
}
@end

@implementation ZenSettingsController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _config = [ZenConfig sharedInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTime) name:kZenConfigRefreshTimeNotification object:_config];
    
    ZenNavigationBar *bar = [[ZenNavigationBar alloc] init];
    [bar setTitle:@"设置"];
    [bar addLeftItemWithStyle:ZenNavigationItemStyleMenu target:self action:@selector(menu:)];
    [_container addSubview:bar];
    
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"ZenSettingsView" owner:self options:NULL];
    if (array && array.count > 0) {
        UIView *settingsView = array[0];
        [_container addSubview:settingsView];
        CGRect frame = settingsView.frame;
        frame.origin.y = bar.height;
        settingsView.frame = frame;
        
        _cellularPlayLabel.font = kZenFont15;
        [_cellularPlaySwitch setOn:_config.cellularPlay];
        
        _cellularOfflineLabel.font = kZenFont15;
        [_cellularOfflineSwitch setOn:_config.cellularOffline];
        
        _timerTitleLabel.font = kZenFont15;
        _timeLabel.textColor = kZenTimeLabelColor;
        [self refreshTime];
    }
}

- (void)refreshTime
{
    if (_config.time == 0) {
        _timeLabel.text = @"未开启";
    }
    else {
        int min = _config.time / 60;
        int sec = _config.time % 60;
        NSString *text = [NSString stringWithFormat:@"%02d:%02d", min, sec];
        _timeLabel.text = text;
    }
}

- (void)menu:(id)sender
{
    DDMenuController *menuController = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).menuController;
    [menuController showLeftController:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cellularPlayOnValueChange:(id)sender
{
    UISwitch *zenSwitch = (UISwitch *)sender;
    _config.cellularPlay = zenSwitch.isOn;
}

- (IBAction)cellularOfflineOnValueChange:(id)sender
{
    UISwitch *zenSwitch = (UISwitch *)sender;
    _config.cellularOffline = zenSwitch.isOn;
}

- (IBAction)openTimer:(id)sender
{
    
}

- (IBAction)statementClicked:(id)sender
{
    
}

@end
