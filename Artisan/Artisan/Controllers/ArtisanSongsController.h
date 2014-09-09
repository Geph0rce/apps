//
//  ArtisanSongsController.h
//  Artisan
//
//  Created by roger on 13-8-2.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ArtisanSongsListModeSimple = 0,
    ArtisanSongsListModeFull
} ArtisanSongsListMode;

@interface ArtisanSongsController : ArtisanBaseController <UITableViewDataSource, UITableViewDelegate>
{
    ArtisanSongsListMode _mode;
}

@property (nonatomic, assign) ArtisanSongsListMode mode;

- (id)initWithMode:(ArtisanSongsListMode)mode;

- (void)load:(NSURL *)url;

@end
