//
//  ArtisanPlayerItem.h
//  Artisan
//
//  Created by roger on 13-8-14.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArtisanSongsModel.h"

@interface ArtisanPlayerItem : UIView
{
    BOOL _selected;
}

@property (nonatomic, assign) BOOL selected;

- (void)load:(ArtisanSongsData *)data;

@end
