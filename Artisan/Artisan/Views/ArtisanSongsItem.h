//
//  ArtisanSongsItem.h
//  Artisan
//
//  Created by roger on 13-8-2.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArtisanSongsModel.h"

typedef enum {
    ArtisanSongsItemStutusNone = 0,
    ArtisanSongsItemStutusPlay,
    ArtisanSongsItemStutusPause
}ArtisanSongsItemStutus;

@interface ArtisanSongsItem : UIView

- (void)load:(ArtisanSongsData *)data;
- (void)setStatus:(ArtisanSongsItemStutus)status;
@end
