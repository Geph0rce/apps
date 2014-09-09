//
//  ArtisanMenuItem.h
//  Artisan
//
//  Created by roger qian on 13-3-29.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArtisanMenuItem : UIView
{
    @private
    UIButton *_leftBtn;
    UIButton *_rightBtn;
}

- (void)setImage:(UIImage *)image;
- (void)setTitle:(NSString *)text;
- (void)setColor:(UIColor *)color highlight:(UIColor *)hl;
- (void)addTarget:(id)target action:(SEL)action;
@end
