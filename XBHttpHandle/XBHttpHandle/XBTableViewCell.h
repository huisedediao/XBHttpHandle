//
//  XBTableViewCell.h
//  XBHttpHandle
//
//  Created by xxb on 2017/8/2.
//  Copyright © 2017年 xxb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XBDownloadTask.h"

@interface XBTableViewCell : UITableViewCell
@property (nonatomic,strong) XBDownloadTask *task;
@end
