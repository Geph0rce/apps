//
//  ArtisanArtistsController.h
//  Artisan
//
//  Created by roger on 13-8-19.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArtisanArtistsController : ArtisanBaseController <UITableViewDataSource, UITableViewDelegate>
- (void)load:(NSURL *)url;
@end
