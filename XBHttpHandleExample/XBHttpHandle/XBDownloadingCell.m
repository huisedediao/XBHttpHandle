//
//  XBDownloadingCell.m
//  XBHttpHandle
//
//  Created by xxb on 2016/12/27.
//  Copyright © 2016年 chuango. All rights reserved.
//

#import "XBDownloadingCell.h"
#import "XBDownloadTaskManager.h"

@interface XBDownloadingCell ()
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end


@implementation XBDownloadingCell


-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super initWithCoder:aDecoder])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(undateProgress:) name:XBDownloadTaskProgressNoti object:nil];

    }
    return self;
}
- (IBAction)startTask:(UIButton *)sender {
    sender.selected=!sender.selected;
    if (sender.selected)
    {
        self.task.isDownloading=YES;
        [[XBDownloadTaskManager shareManager] startTask:self.task];
        [[XBDownloadTaskManager shareManager] startTask:self.task];
    }
    else
    {
        self.task.isDownloading=NO;
        [[XBDownloadTaskManager shareManager] stopTask:self.task];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)undateProgress:(NSNotification *)noti
{
    if (noti.object==self.task)
    {
        self.task=noti.object;
    }
}

-(void)setTask:(XBDownloadTask *)task
{
    _task=task;
    self.detailLabel.text=[NSString stringWithFormat:@"%.2f %% (%@/%@)",task.progress * 100 , task.fs_downloaded , task.fs_total];
    self.nameLabel.text=[task.savePath lastPathComponent];
    
    if (task.isDownloading)
    {
        self.startBtn.selected=YES;
    }
    else
    {
        self.startBtn.selected=NO;
    }
}


@end
