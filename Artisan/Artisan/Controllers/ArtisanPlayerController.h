//
//  ArtisanPlayerController.h
//  Artisan
//
//  Created by roger on 13-8-5.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import "ArtisanSongsModel.h"

@interface ArtisanPlayerController : ArtisanBaseController <UITableViewDataSource, UITableViewDelegate>
{
    ArtisanSongsModel *_model;
    int _index;
}

@property (nonatomic, retain) ArtisanSongsModel *model;
@property (nonatomic, assign) int index;


+ (ArtisanPlayerController *)sharedInstance;

- (void)load;

@end
