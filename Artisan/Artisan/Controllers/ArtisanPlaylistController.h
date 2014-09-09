//
//  ArtisanPlaylistController.h
//  Artisan
//
//  Created by roger on 13-8-20.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import "ArtisanBaseController.h"

@interface ArtisanPlaylistController : ArtisanBaseController <UITableViewDataSource, UITableViewDelegate>

- (void)load:(NSURL *)url;

@end
