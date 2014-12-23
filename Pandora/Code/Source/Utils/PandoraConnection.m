//
//  PandoraConnection.m
//  Zen
//
//  Created by roger on 13-07-23.
//  Copyright (c) 2013年 Zen. All rights reserved.
//

#import "PandoraConnection.h"

@interface PandoraConnection ()
{
    NSURLConnection *_connection;
    NSURL *_url;
    
}
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURLConnection *connection;

@end

@implementation PandoraConnection
@synthesize didFinishedSelector = _didFinishedSelector;
@synthesize didFailedSelector = _didFailedSelector;
@synthesize url = _url;
@synthesize connection = _connection;
@synthesize delegate = _delegate;

/**
 *  cheat the llvm
 *
 */

- (void)requestDidFinished:(PandoraConnection *)connection
{}

- (void)requestDidFailed:(PandoraConnection *)connection
{}


- (id)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        _delegate = nil;
        _responseData = nil;
        _requestHeaders = nil;
        _connection = nil;
        _shouldHandleCookies = YES;
        _httpBody = nil;
        self.httpMethod = @"GET";
        self.url = url;
        [self setDidFinishedSelector:@selector(requestDidFinished:)];
        [self setDidFailedSelector:@selector(requestDidFailed:)];
    }
    
    return self;
}


+ (PandoraConnection *)connectionWithURL:(NSURL *)url
{
    return [[self alloc] initWithURL:url];
}

#pragma mark -
#pragma mark Certificate Utils

OSStatus PandoraExtractIdentityAndTrust(CFDataRef inP12data, SecIdentityRef *identity, SecTrustRef *trust)
{
    OSStatus securityError = errSecSuccess;
    
    CFStringRef password = CFSTR("123456");
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    
    CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError = SecPKCS12Import(inP12data, options, &items);
    
    if (securityError == 0) {
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex(items, 0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemIdentity);
        *identity = (SecIdentityRef)tempIdentity;
        const void *tempTrust = NULL;
        tempTrust = CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemTrust);
        *trust = (SecTrustRef)tempTrust;
    }
    
    if (options) {
        CFRelease(options);
    }
    
    return securityError;
}

- (NSURLCredential *)loadCertificate
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"p12"];
    NSData *p12data = [NSData dataWithContentsOfFile:path];
    CFDataRef inP12data = (__bridge CFDataRef)p12data;
    
    SecIdentityRef identity = nil;
    SecTrustRef trust;
    PandoraExtractIdentityAndTrust(inP12data, &identity, &trust);
    
    SecCertificateRef certificate;
    if (identity) {
        SecIdentityCopyCertificate(identity, &certificate);
        const void *certs[] = { certificate };
        CFArrayRef certsArray = CFArrayCreate(NULL, certs, 1, NULL);
        
        NSURLCredential *credential = [NSURLCredential credentialWithIdentity:identity certificates:(__bridge NSArray *)certsArray persistence:NSURLCredentialPersistenceNone];
        CFRelease(certsArray);
        return credential;
    }
    
    return nil;
}

- (BOOL)shouldTrustProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    // Load up the bundled certificate.
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"server" ofType:@"der"];
    NSData *certData = [[NSData alloc] initWithContentsOfFile:certPath];
    CFDataRef certDataRef = (__bridge_retained CFDataRef) certData;
    SecCertificateRef cert = SecCertificateCreateWithData(NULL, certDataRef);
    
    // Establish a chain of trust anchored on our bundled certificate.
    CFArrayRef certArrayRef = CFArrayCreate(NULL, (void *)&cert, 1, NULL);
    SecTrustRef serverTrust = protectionSpace.serverTrust;
    SecTrustSetAnchorCertificates(serverTrust, certArrayRef);
    
    // Verify that trust.
    SecTrustResultType trustResult;
    SecTrustEvaluate(serverTrust, &trustResult);
    
    // Clean up.
    CFRelease(certArrayRef);
    CFRelease(cert);
    CFRelease(certDataRef);
    
    // Did our custom trust chain evaluate successfully?
    return trustResult == kSecTrustResultUnspecified;
}

- (void)addRequestHeader:(NSString *)header value:(NSString *)value
{
    if (!_requestHeaders) {
        _requestHeaders = [[NSMutableDictionary alloc] init];
    }
    [_requestHeaders setObject:value forKey:header];
}

#pragma mark -
#pragma mark HTTP Methods

- (NSURLRequest *)request
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url];
    [request setHTTPMethod:_httpMethod];
    [request setHTTPShouldHandleCookies:_shouldHandleCookies];
    if (_requestHeaders && _requestHeaders.count > 0) {
        [_requestHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [request addValue:obj forHTTPHeaderField:key];
        }];
    }
    
    [request addValue:@" Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Mobile/10A403" forHTTPHeaderField:@"User-Agent"];
    if (_httpBody && [_httpMethod isEqualToString:@"POST"]) {
        [request setHTTPBody:_httpBody];
    }
    return request;
}

- (NSData *)startSynchronous
{
    NSURLRequest *request = [self request];
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
    self.responseHeaders = res.allHeaderFields;
    NSLog(@"allHeaderFields: %@", [res.allHeaderFields description]);
    if (!data && error) {
        NSLog(@"error: %@", error.userInfo);
    }
    return data;
}

- (void)startAsynchronous
{
    NSURLRequest *request = [self request];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)cancel
{
    if (_connection) {
        [_connection cancel];
    }
    _delegate = nil;
}


#pragma mark- 
#pragma mark NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (_delegate && [_delegate respondsToSelector:_didFailedSelector]) {
        self.error = error;
        [_delegate performSelector:_didFailedSelector withObject:self];
    }
}


#pragma mark - 
#pragma mark NSURLConnectionDataDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.cookie = @"";
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    NSDictionary *fields = [HTTPResponse allHeaderFields];
    NSString *cookie = [fields valueForKey:@"Set-Cookie"];
    self.cookie = cookie;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!_responseData) {
        _responseData = [[NSMutableData alloc] initWithData:data];
    }
    else {
        [_responseData appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    NSLog(@"progress: %ld", (long)(100 * totalBytesWritten)/totalBytesExpectedToWrite);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (_responseData) {
        _responseString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
        if (!_responseString) {
             NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            NSString *response = [[NSString alloc] initWithData:_responseData encoding:encoding];
            NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
            self.responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    
    if (_delegate && [_delegate respondsToSelector:_didFinishedSelector]) {
        [_delegate performSelector:_didFinishedSelector withObject:self];
    }
    
    self.connection = nil;
}



- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}


- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
       [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }
    else {
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
    
}

@end
