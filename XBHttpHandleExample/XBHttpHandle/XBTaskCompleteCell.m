//
//  XBTaskCompleteCell.m
//  XBHttpHandle
//
//  Created by xxb on 2016/12/27.
//  Copyright © 2016年 chuango. All rights reserved.
//

#import "XBTaskCompleteCell.h"

@interface XBTaskCompleteCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end

@implementation XBTaskCompleteCell

-(void)setTask:(XBDownloadTask *)task
{
    _task=task;
    self.nameLabel.text=[task.savePath lastPathComponent];
    self.detailLabel.text=[NSString stringWithFormat:@"%@",task.fs_total];
}

@end
