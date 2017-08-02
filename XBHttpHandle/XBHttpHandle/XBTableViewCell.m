//
//  XBTableViewCell.m
//  XBHttpHandle
//
//  Created by xxb on 2017/8/2.
//  Copyright © 2017年 xxb. All rights reserved.
//

#import "XBTableViewCell.h"
#import "XBNetworkingPublic.h"
#import "XBDownloadManager.h"
#import "XBNetHandle.h"

@implementation XBTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTextlabelText:) name:kNotice_progress object:nil];
    }
    return self;
}
- (void)setTask:(XBDownloadTask *)task
{
    _task = task;
    [XBNetHandle downFileWith:task];
    typeof(self) __weak weakSelf = self;
//    task.bl_progressBlock = ^(XBDownloadTask *xbTask) {
//        weakSelf.textLabel.text = [NSString stringWithFormat:@"%@,progress:%f",weakSelf.task.str_fileName,weakSelf.task.f_progress];
//    };


//    [[XBDownloadManager shared] startTask:task progressBlock:^(XBDownloadTask *xbTask) {
//        weakSelf.textLabel.text = [NSString stringWithFormat:@"%@,progress:%f",weakSelf.task.str_fileName,weakSelf.task.f_progress];
//    } completeBlock:^(XBDownloadTask *xbTask) {
//        
//    } failureBlock:^(NSError *error) {
//        
//    }];
    self.textLabel.text = [NSString stringWithFormat:@"%@,progress:%f",task.str_fileName,task.f_progress];
}

- (void)updateTextlabelText:(NSNotification *)noti
{
    XBDownloadProgressObj *obj = noti.object;
    if (self.task.downloadTask == obj.downloadTask)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textLabel.text = [NSString stringWithFormat:@"%@,progress:%f",self.task.str_fileName,(obj.int_totalBytesWritten * 1.0 / obj.int_totalBytesExpectedToWrite)];
        });
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
