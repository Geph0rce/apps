//
//  ZenRulesModel.h
//  ZenPro
//
//  Created by roger on 13-12-5.
//  Copyright (c) 2013年 Zen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ZenAdTypeAdmob,
    ZenAdTypeAdsage,
    ZenAdTypeLimei,
    ZenAdTypeBaidu,
    ZenAdTypeAdsageAndLimei,
    ZenAdTypeBaiduAndAdsage,
    ZenAdTypeBaiduAndLimei,
    ZenAdTypeAll
} ZenAdType;

typedef enum {
    ZenBannerTypeAdmob,
    ZenBannerTypeInMobi,
    ZenBannerTypeBoth
} ZenBannerType;

#define kZenRulesUpdated @"ZenRulesUpdated"

@interface ZenRulesModel : NSObject
{
    ZenAdType _adType;
    ZenBannerType _bannerType;
    BOOL _enabled;
}

@property (nonatomic, assign) ZenAdType adType;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) ZenBannerType bannerType;

+ (ZenRulesModel *)sharedInstance;
- (void)load;

@end
