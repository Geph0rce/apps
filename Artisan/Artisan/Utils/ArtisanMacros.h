//
//  ArtisanMacros.h
//  Artisan
//
//  Created by roger on 13-8-5.
//  Copyright (c) 2013年 Artisan. All rights reserved.
//

// Fonts
#define kArtisanFont19 [UIFont fontWithName:@"FZLTHK--GBK1-0" size:19.0f]
#define kArtisanFont16 [UIFont fontWithName:@"FZLTHK--GBK1-0" size:16.0f]
#define kArtisanFont15 [UIFont fontWithName:@"FZLTHK--GBK1-0" size:15.0f]
#define kArtisanFont13 [UIFont fontWithName:@"FZLTHK--GBK1-0" size:13.0f]
#define kArtisanFont10 [UIFont fontWithName:@"FZLTHK--GBK1-0" size:10.0f]


// Color Stuff
#define CGColorConvert(value)  (value/255.0f)
#define ArtisanColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]
#define kArtisanBackgroundColor ArtisanColorFromRGB(0xECF0F1)
#define kArtisanMainColor ArtisanColorFromRGB(0x1abc9c)
#define kArtisanHighlight ArtisanColorFromRGB(0x16a085)