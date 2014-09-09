//
//  ArtisanURLConnection.h
//  
//
//  Created by roger on 13-07-23.
//  Copyright (c) 2013年 DynamiCode. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol ArtisanURLConnectionDelegate;

@interface ArtisanURLConnection : NSObject <NSURLConnectionDataDelegate>
{
    NSMutableData *_receivedData;
}
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, assign) NSObject <ArtisanURLConnectionDelegate> *delegate;

- (void)GET:(NSString *)urlStr;
- (void)POST:(NSString *)urlStr data:(NSData *)data;

- (void)cancel;

@end

@protocol ArtisanURLConnectionDelegate <NSObject>
@optional
- (void)didFinishLoadingData:(NSMutableData *)data;
- (void)didFailWithError:(NSError *)error;
- (void)connectionDidCancel;
@end