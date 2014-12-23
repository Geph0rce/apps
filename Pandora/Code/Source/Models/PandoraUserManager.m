//
//  PandoraUserManager.m
//  Zen
//
//  Created by roger on 14-7-10.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "Singleton.h"
#import "ZenCategory.h"
#import "PandoraUserManager.h"

@implementation PandoraUser

- (BOOL)isValid
{
    if (_token && ![_token isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

@end

#define kPandoraUsers  @"PandoraUsers"

@implementation PandoraUserManager

SINGLETON_FOR_CLASS(PandoraUserManager);

- (id)init
{
    self = [super init];
    if (self) {
        [self load];
    }
    return self;
}

- (void)load
{
    @try {
        _users = [[NSMutableArray alloc] init];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSArray *users = [ud objectForKey:kPandoraUsers];
        for (NSDictionary *user in users) {
            PandoraUser *pandora = [self userForDict:user];
            if (pandora) {
                [_users addObject:pandora];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"PandoraUserManager load exception: %@", [exception description]);
    }
    
}

- (void)synchronize
{
    NSMutableArray *array = [NSMutableArray array];
    for (PandoraUser *pandora in _users) {
        NSDictionary *dict = [self dictForUser:pandora];
        if (dict) {
            [array addObject:dict];
        }
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:array forKey:kPandoraUsers];
    [ud synchronize];
}

- (void)save:(PandoraUser *)user
{
    if (user && [user isValid] && ![self contains:user]) {
        [_users addObject:user];
        NSMutableArray *array = [NSMutableArray array];
        for (PandoraUser *pandora in _users) {
            NSDictionary *dict = [self dictForUser:pandora];
            if (dict) {
                [array addObject:dict];
            }
        }
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:array forKey:kPandoraUsers];
        [ud synchronize];
    }
    else {
        NSLog(@"PandoraUserManager save: user is invalid.");
    }
}

- (void)remove:(NSUInteger)index
{
    if (index < _users.count) {
        [_users removeObjectAtIndex:index];
        [self synchronize];
    }
}


#pragma mark
#pragma mark Utils

- (BOOL)contains:(PandoraUser *)user
{
    for (PandoraUser *pandora in _users) {
        if ([user.md5 isEqualToString:pandora.md5]) {
            return YES;
        }
    }
    return NO;
}

- (PandoraUser *)userForDict:(NSDictionary *)dict
{
    if (dict) {
        PandoraUser *user = [[PandoraUser alloc] init];
        user.name = [dict stringForKey:@"name"];
        user.desc = [dict stringForKey:@"desc"];
        user.token = [dict stringForKey:@"token"];
        user.md5 = [dict stringForKey:@"md5"];
        
        user.isMe = NO;
        NSString *isMe = [dict stringForKey:@"isMe"];
        if ([isMe isEqualToString:@"1"]) {
            user.isMe = YES;
        }
        return user;
    }
    return nil;
}

- (NSDictionary *)dictForUser:(PandoraUser *)user
{
    if (user && [user isValid]) {
        NSString *name = (user.name != nil? user.name : @"pandora");
        NSString *desc = (user.description != nil? user.description : @"oops...");
        NSString *token = (user.token != nil ? user.token : @"");
        NSString *md5 = (user.md5 != nil? user.md5 : [token md5]);
        NSString *isMe = (user.isMe? @"1" : @"0");
        NSDictionary *dict = @{ @"name" : name, @"desc" : desc, @"token" : token, @"isMe" : isMe, @"md5" : md5};
        return dict;
    }
    return nil;
}

@end
