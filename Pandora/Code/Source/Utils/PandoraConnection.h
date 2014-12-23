//
//  PandoraConnection.h
//  Zen
//
//  Created by roger on 13-07-23.
//  Copyright (c) 2013年 Zen. All rights reserved.
//

@protocol PandoraConnectionDelegate;

@interface PandoraConnection : NSObject <NSURLConnectionDataDelegate>
{
    SEL _didFinishedSelector;
    SEL _didFailedSelector;
    __weak NSObject <PandoraConnectionDelegate>  *_delegate;
    NSString *_httpMethod;
    NSData *_httpBody;
    NSMutableDictionary *_requestHeaders;
    NSDictionary *_responseHeaders;
    NSMutableData *_responseData;
    NSString *_responseString;
    NSError *_error;
    BOOL _shouldHandleCookies;
    int _tag;
    NSString *_cookie;
}

@property (nonatomic, assign) SEL didFinishedSelector;
@property (nonatomic, assign) SEL didFailedSelector;
@property (nonatomic, weak) NSObject <PandoraConnectionDelegate> *delegate;

@property (nonatomic, strong) NSString *httpMethod;
@property (nonatomic, strong) NSData *httpBody;
@property (nonatomic, strong) NSMutableDictionary *requestHeaders;
@property (nonatomic, strong) NSDictionary *responseHeaders;
@property (nonatomic, assign) int tag;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSString *responseString;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) BOOL shouldHandleCookies;
@property (nonatomic, strong) NSString *cookie;

/**
 *	init method
 *
 *	@param	url	- request url
 *
 *	@return	PandoraConnection Instance
 */
+ (PandoraConnection *)connectionWithURL:(NSURL *)url;

- (void)addRequestHeader:(NSString *)header value:(NSString *)value;

- (NSData *)startSynchronous;

- (void)startAsynchronous;

- (void)cancel;

@end

@protocol PandoraConnectionDelegate <NSObject>

@optional
- (void)requestDidFinished:(PandoraConnection *)connection;
- (void)requestDidFailed:(PandoraConnection *)connection;

@end