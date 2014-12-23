//
//  PandoraFileCell.m
//  Zen
//
//  Created by roger on 14-7-14.
//  Copyright (c) 2014年 Zen. All rights reserved.
//

#import "UIImageView+WebCache.h"

#import "ZenMacros.h"
#import "ZenCategory.h"

#import "PandoraFileCell.h"

#define kPandoraThemeWidth 40.0f
#define kPandoraFileMargin 10.0f
#define kPandoraFileCellWidth kZenDeviceWidth
#define kPandoraMaxTitleSize CGSizeMake(kPandoraFileCellWidth - 3 * kPandoraFileMargin - kPandoraThemeWidth, 36.0f)
#define kPandoraFileCellHeight 60.0f
#define kPandoraContainerFrame CGRectMake(2 * kPandoraFileMargin + kPandoraThemeWidth, 0.0f, kPandoraFileCellWidth - 3 * kPandoraFileMargin - kPandoraThemeWidth, 0.0f);
#define kPandoraMaxLines 2

@interface PandoraFileCell ()
{
    UIView *_container;
    UIImageView *_theme;
    UILabel *_subject;
    UILabel *_size;
}
@end

@implementation PandoraFileCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kZenBackgroundColor;
        
        UIImageView *theme = [[UIImageView alloc] initWithFrame:CGRectMake(kPandoraFileMargin, kPandoraFileMargin, 40.0f, 40.0f)];
        theme.backgroundColor = kZenBackgroundColor;
        _theme = theme;
        [self.contentView addSubview:theme];
        
        _container = [[UIView alloc] init];
        _container.backgroundColor = [UIColor clearColor];
        _container.frame = kPandoraContainerFrame;
        
        UILabel *subject = [[UILabel alloc] init];
        [subject setBackgroundColor:[UIColor clearColor]];
        subject.userInteractionEnabled = NO;
        subject.textAlignment = NSTextAlignmentLeft;
        [subject setTextColor:kZenMainFontColor];
        [subject setFont:kZenFont15];
        [subject setLineBreakMode:NSLineBreakByWordWrapping];
        [subject setNumberOfLines:kPandoraMaxLines];
        _subject = subject;
        [_container addSubview:subject];
        
        UILabel *size = [[UILabel alloc] init];
        _size = size;
        [size setBackgroundColor:[UIColor clearColor]];
        size.userInteractionEnabled = NO;
        size.textAlignment = NSTextAlignmentLeft;
        [size setTextColor:[UIColor grayColor]];
        [size setFont:kZenFont13];
        [_container addSubview:_size];

        [self.contentView addSubview:_container];
        
        UIView *seprator = [[UIView alloc] initWithFrame:CGRectMake(kPandoraFileMargin, kPandoraFileCellHeight - 1.0f, kPandoraFileCellWidth - 2 * kPandoraFileMargin, 1.0f)];
        seprator.backgroundColor = kZenBorderColor;
        [self.contentView addSubview:seprator];
    }
    return self;
}

- (void)load:(PandoraFile *)file
{
    if (!file) {
        NSLog(@"PandoraFileCell file is nil.");
        return;
    }
    // load theme
    NSString *uri = [PandoraFileListModel themeWithFile:file];
    if ([uri contains:@"http"]) {
        [_theme setImageWithURL:[NSURL URLWithString:uri] placeholderImage:[UIImage imageNamed:@"file_unknown_pressed"]];
    }
    else {
        [_theme setImage:[UIImage imageNamed:uri]];
    }
    
    // layout subject and size label
    CGSize size = [file.name sizeWithZenFont:kZenFont15 constrainedToSize:kPandoraMaxTitleSize];
    _subject.text = file.name;
    _subject.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
    
    CGFloat height = size.height + kPandoraFileMargin;
    _size.hidden = YES;
    if (!file.isdir) {
        _size.hidden = NO;
        _size.frame = CGRectMake(0.0f, height, 160.0f, 15.0f);
        _size.text = file.size;
        height += 15.0f;
    }
    
    CGFloat offsetY = (kPandoraFileCellHeight - height)/2.0f;
    
    CGRect frame = _container.frame;
    frame.origin.y = offsetY;
    frame.size.height = height;
    _container.frame = frame;
}


@end
