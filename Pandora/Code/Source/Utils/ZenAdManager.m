//
//  ZenAdManager.m
//  Zen
//
//  Created by roger on 13-11-11.
//  Copyright (c) 2013年 Zen. All rights reserved.
//

#import "MobClick.h"
#import "GADBannerView.h"
#import "GADInterstitial.h"
#import "MobiSageSDK.h"

#import "BaiduMobAdDelegateProtocol.h"
#import "BaiduMobAdInterstitial.h"

#import "Singleton.h"
#import "ZenMacros.h"
#import "ZenCrypt.h"
#import "ZenIDFA.h"
#import "ZenAdManager.h"
#import "ZenRulesModel.h"

#define kAdmobBannerUnitID @"ca-app-pub-8494263015060478/4359064347"
#define kAdmobInterstitialUnitId @"ca-app-pub-8494263015060478/4439789540"

#define kInMobiAppID @"f98c3e5132cf46c08590c656488af7fb"

#define kBaiduAppID  @"1004461f"

#define kMobiSagePublisherId @"UFFQgz/E3UpjaEEK1w=="
#define kMobiSageSlotID      @"Kyor+ES8pjEYEzpxrLjwFqcM"

#define kMobiSageOfferWallPublisherId @"8c1f4d4d6b5c4b8bb739545bf4853007"
#define kMobiSageURLScheme @"com.roger.zen"

#define kLimeiPosterId @"cc30d52acd1f46c3514a51f677081b59"

#define kZenShowInterstitialAdDuration 6
#define kMobiSageTimeInterval 30 * 60
#define kZenRightTime @"ZenRightTime"

#define kZenAdFreePrice 320
#define kZenAdFreeDuration 60 * 60 * 24 * 30
#define kZenAdFreeTime @"ZenAdFreeTime"

@interface ZenAdManager () <MobiSageSplashDelegate, MobiSageFloatWindowDelegate, GADBannerViewDelegate, GADInterstitialDelegate,BaiduMobAdInterstitialDelegate, BaiduMobAdViewDelegate>
{
    UIView *_banner;
    MobiSageSplash *_splashAd;
    MobiSageFloatWindow *_posterAd;
    GADInterstitial *_interstitial;
    BaiduMobAdInterstitial *_baiduInterstitial;
    int _count;
    int _balance;
    NSTimeInterval _timeIntival;
    ZenAdType _type;
    ZenBannerType _bannerType;
    BOOL _isAdsageReady;
    BOOL _isLimeiReady;
    BOOL _isBaiduReady;
    UIView *_admobBanner;
    UIView *_inmobBanner;
}

@property (nonatomic, strong) UIView *banner;
@property (nonatomic, strong) MobiSageSplash *splashAd;
@property (nonatomic, strong) MobiSageFloatWindow *posterAd;
@property (nonatomic, strong) GADInterstitial *interstitial;
@property (nonatomic, strong) BaiduMobAdInterstitial *baiduInterstitial;
@property (nonatomic, strong) UIView *admobBanner;
@property (nonatomic, strong) UIView *inmobBanner;

@end

@implementation ZenAdManager

SINGLETON_FOR_CLASS(ZenAdManager);

- (id)init
{
    if (self = [super init]) {
        _isAdsageReady = NO;
        _isLimeiReady = NO;
        _timeIntival = 0.0f;
        _balance = 0;
        [[MobiSageManager getInstance] setPublisherID:kMobiSagePublisherId];
        [[MobiSageManager getInstance] setEnableLocation:NO];
        NSString *str = [[NSUserDefaults standardUserDefaults] stringForKey:kZenRightTime];
        if (str) {
            str = [ZenCrypt decrypt:str];
            _timeIntival = [str doubleValue];
        }
        _type = ZenAdTypeAdsage;
        _bannerType = ZenBannerTypeAdmob;
    }
    
    return self;
}

+ (UIView *)banner
{
    return [[ZenAdManager sharedInstance] banner];
}

- (UIView *)banner
{
    @try {

        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window && window.rootViewController) {
            self.banner = [self bannerWithRootViewController:window.rootViewController];
            [self loadRequest:(GADBannerView *)_admobBanner];
        }
        return _banner;
    }
    @catch (NSException *exception) {
        NSLog(@"LeafAdManager banner exception: %@", [exception description]);
    }
    return nil;
}

+ (void)visible:(BOOL)flag
{
    UIView *banner = [ZenAdManager sharedInstance].banner;
    if (banner) {
        banner.hidden = !flag;
    }
}

- (void)switchAdType
{
    ZenAdType adType = [ZenRulesModel sharedInstance].adType;
    if (adType == ZenAdTypeAdsageAndLimei) {
        if (_type != ZenAdTypeAdsage) {
            _type = ZenAdTypeAdsage;
        }
        else {
            _type = ZenAdTypeLimei;
        }
    }
    else if (adType == ZenAdTypeBaiduAndAdsage) {
        if (_type != ZenAdTypeBaidu) {
            _type = ZenAdTypeBaidu;
        }
        else {
            _type = ZenAdTypeAdsage;
        }
    }
    else if (adType == ZenAdTypeBaiduAndLimei) {
        if (_type != ZenAdTypeBaidu) {
            _type = ZenAdTypeBaidu;
        }
        else {
            _type = ZenAdTypeLimei;
        }
    }
    else if (adType == ZenAdTypeAll) {
        if (_type == ZenAdTypeAdsage) {
            _type = ZenAdTypeBaidu;
        }
        else if (_type == ZenAdTypeBaidu) {
            _type = ZenAdTypeLimei;
        }
        else if (_type == ZenAdTypeLimei) {
            _type = ZenAdTypeAdsage;
        }
        else {
            _type = ZenAdTypeBaidu;
        }
    }
    else {
        _type = adType;
    }
}

- (UIView *)bannerWithRootViewController:(UIViewController *)controller
{
    if (!_admobBanner) {
        if (kZenDeviceiPad) {
            GADBannerView *banner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLeaderboard origin:CGPointMake(20.0f, 0.0f)];
            banner.delegate = self;
            banner.adUnitID = kAdmobBannerUnitID;
            self.admobBanner = banner;
        }
        else {
            GADBannerView *banner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
            banner.delegate = self;
            banner.adUnitID = kAdmobBannerUnitID;
            self.admobBanner = banner;
        }
    }
    
    ((GADBannerView *)_admobBanner).rootViewController = controller;
    return _admobBanner;
}

- (void)loadRequest:(GADBannerView *)banner
{
    GADRequest *request = [GADRequest request];
    [request setGender:kGADGenderMale];
    request.testDevices = @[ @"a0fd14696644daf56f57da2c82eab6b4" ];
    [banner loadRequest:request];
}

- (void)showSplashAd:(UIWindow *)window
{
    NSString *imgName = @"Default";
    if ([UIScreen mainScreen].bounds.size.height > 480.0f) {
        imgName = @"Default-568h";
    }
    if (kZenDeviceiPad) {
        imgName = @"Default-iPad";
    }
    
    GADInterstitial *splashInterstitial = [[GADInterstitial alloc] init];
    splashInterstitial.adUnitID = kAdmobInterstitialUnitId;
    splashInterstitial.delegate = self;
    GADRequest *request = [GADRequest request];
    request.gender = kGADGenderMale;
    [splashInterstitial loadRequest:request];
}

- (void)saveTime
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    now += kMobiSageTimeInterval;
    _timeIntival = now;
    NSString *str = [ZenCrypt encrypt:[NSString stringWithFormat:@"%lf", now]];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:str forKey:kZenRightTime];
    [ud synchronize];
}

- (BOOL)isRightTime
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now < _timeIntival && (_timeIntival - now) < kMobiSageTimeInterval) {
        return NO;
    }
    _timeIntival = 0;
    return YES;
}

- (void)showInterstitial:(UIView *)view
{
    if ([ZenRulesModel sharedInstance].enabled) {
        if (_type == ZenAdTypeAdsage) {
            [self showPosterAd];
        }
        else {
            [self showInterstitialBaidu];
        }
    }
}

- (void)showPosterAd
{
    if ([ZenRulesModel sharedInstance].enabled) {
        if (_isAdsageReady) {
            if (_count >= kZenShowInterstitialAdDuration && [self isRightTime]) {
                
                [_posterAd showAdvView];
                _isAdsageReady = NO;
                _count = 0;
                
                [self switchAdType];
            }
        }
        else {
            if (_count > kZenShowInterstitialAdDuration) {
                [self switchAdType];
                return;
            }
            self.posterAd = [[MobiSageFloatWindow alloc] initWithAdSize:Float_size_0
                                                               delegate:self
                                                              slotToken:kMobiSageSlotID];
        }
        _count++;
    }
}

- (void)showAdMobInterstitial:(UIViewController *)controller;
{
    if (!_interstitial) {
        //_isReady = NO;
        GADInterstitial *interstitial = [[GADInterstitial alloc] init];
        self.interstitial = interstitial;
        _interstitial.delegate = self;
        _interstitial.adUnitID = kAdmobInterstitialUnitId;
        GADRequest *request = [GADRequest request];
        request.gender = kGADGenderMale;
        [_interstitial loadRequest:request];
    }
    if (_interstitial.isReady) {
        if (_count == 0 && [self isRightTime]) {
            [_interstitial presentFromRootViewController:controller];
            //_isReady = NO;
        }
    }
    _count++;
    if (_count == kZenShowInterstitialAdDuration) {
        _count = 0;
    }
}

#pragma mark -
#pragma mark MobiSageAdSplashDelegate Methods

/**
 *  AdSplash展示成功
 *  @param adSplash
 */
- (void)mobiSageSplashSuccessToShow:(MobiSageSplash*)adSplash
{}

/**
 *  AdSplash展示失败
 *  @param adSplash
 */
- (void)mobiSageSplashFaildToRequest:(MobiSageSplash*)adSplash
{
}

/**
 *  AdSplash被点击
 *  @param adSplash
 */
- (void)mobiSageSplashClick:(MobiSageSplash*)adSplash
{
    //[self saveTime];
}

/**
 *  AdSplash被关闭
 *  @param adSplash
 */
- (void)mobiSageSplashClose:(MobiSageSplash*)adSplash
{
}


#pragma mark -
#pragma mark  MobiSageAdPosterDelegate Methods

- (UIViewController *)viewControllerToPresent
{
   return [UIApplication sharedApplication].keyWindow.rootViewController;
}

/**
 *  AdPoster被点击
 *  @param adPoster
 */
- (void)mobiSageFloatClick:(MobiSageFloatWindow*)adFloat
{
    [self saveTime];
}

/**
 *  AdPoster被关闭
 *  @param adPoster
 */
- (void)mobiSageFloatClose:(MobiSageFloatWindow*)adFloat
{
}

/**
 *  AdPoster请求成功
 *  @param adPoster
 */
- (void)mobiSageFloatSuccessToRequest:(MobiSageFloatWindow*)adFloat
{
    _isAdsageReady = YES;
}

/**
 *  AdPoster请求失败
 *  @param adPoster
 */
- (void)mobiSageFloatFaildToRequest:(MobiSageFloatWindow*)adFloat
{
}

#pragma mark
#pragma mark GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    [UIApplication sharedApplication].statusBarHidden = NO;
}

#pragma mark
#pragma mark GADInterstitialDelegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    [UIApplication sharedApplication].statusBarHidden = NO;
}

#pragma mark Baidu Interstitial

- (void)showInterstitialBaidu
{
    if ([ZenRulesModel sharedInstance].enabled) {
        if (_isBaiduReady) {
            if ([self isRightTime] && _baiduInterstitial && _count >= kZenShowInterstitialAdDuration) {
                if (_baiduInterstitial.isReady) {
                    [_baiduInterstitial presentFromRootViewController:[self viewControllerToPresent]];
                }
                _count = 0;
                _isBaiduReady = NO;
                [self switchAdType];
            }
        }
        else {
            self.baiduInterstitial = [[BaiduMobAdInterstitial alloc] init];
            _baiduInterstitial.delegate = self;
            [_baiduInterstitial load];
        }
    }
    _count++;
}

#pragma mark
#pragma mark BaiduMob Delegate

- (NSString *)publisherId
{
    return  kBaiduAppID;
}

- (NSString*)appSpec
{
    return kBaiduAppID;
}

-(BOOL)enableLocation
{
    return NO;
}

/**
 *  广告预加载成功
 */
- (void)interstitialSuccessToLoadAd:(BaiduMobAdInterstitial *)interstitial
{
    _isBaiduReady = YES;
}

/**
 *  广告预加载失败
 */
- (void)interstitialFailToLoadAd:(BaiduMobAdInterstitial *)interstitial
{
    [self switchAdType];
}

/**
 *  广告即将展示
 */
- (void)interstitialWillPresentScreen:(BaiduMobAdInterstitial *)interstitial
{
}

/**
 *  广告展示成功
 */
- (void)interstitialSuccessPresentScreen:(BaiduMobAdInterstitial *)interstitial
{
}

/**
 *  广告展示失败
 */
- (void)interstitialFailPresentScreen:(BaiduMobAdInterstitial *)interstitial withError:(BaiduMobFailReason) reason
{
}

/**
 *  广告展示结束
 */
- (void)interstitialDidDismissScreen:(BaiduMobAdInterstitial *)interstitial
{
}

- (void)interstitialDidAdClicked:(BaiduMobAdInterstitial *)interstitial
{
    [self saveTime];
}


@end
