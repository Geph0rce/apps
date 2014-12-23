//
//  PandoraFileListModel.h
//  Zen
//
//  Created by roger on 14-7-14.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "PandoraBaseModel.h"

#define kPandoraFileListLoadFinished    @"PandoraFileListLoadFinished"
#define kPandoraFileListLoadFailed      @"PandoraFileListLoadFailed"

typedef NS_OPTIONS(NSUInteger, PandoraFileType) {
    PandoraFileTypeUnknow = 0,
    PandoraFileTypeVideo = 1,
    PandoraFileTypeAudio = 2,
    PandoraFileTypeImage = 3,
    PandoraFileTypeFolder = 6
};

@interface PandoraFile : NSObject
{
    NSString *_fsId;
    NSString *_path;
    NSString *_name;
    NSString *_time;
    BOOL _isdir;
    int _category;
    NSString *_size;
    NSString *_thumb;
}

@property (nonatomic, strong) NSString *fsId;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, assign) BOOL isdir;
@property (nonatomic, assign) int category;
@property (nonatomic, strong) NSString *size;
@property (nonatomic, strong) NSString *thumb;

@end

@interface PandoraFileListModel : PandoraBaseModel
{
    NSMutableArray *_files;
    NSString *_token;
}

@property (nonatomic, strong) NSMutableArray *files;
@property (nonatomic, strong) NSString *token;

// file name or url
+ (NSString *)themeWithFile:(PandoraFile *)file;

- (void)load:(NSString *)dir;

@end
