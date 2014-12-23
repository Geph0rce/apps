//
//  PandoraUserManager.h
//  Zen
//
//  Created by roger on 14-7-10.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

@interface PandoraUser : NSObject
{
    NSString *_name;
    NSString *_desc;
    NSString *_token;
    NSString *_md5;
    BOOL _isMe;
}

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *md5;
@property (nonatomic, assign) BOOL isMe;

- (BOOL)isValid;

@end


@interface PandoraUserManager : NSObject
{
    NSMutableArray *_users;
}

@property (nonatomic, strong) NSMutableArray *users;

+ (PandoraUserManager *)sharedInstance;

- (void)save:(PandoraUser *)user;

- (void)remove:(NSUInteger)index;

@end
