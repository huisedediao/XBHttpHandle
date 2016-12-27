//
//  XBDownloadTaskManager.h
//  XBHttpHandle
//
//  Created by xxb on 2016/12/26.
//  Copyright © 2016年 chuango. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XBDownloadTask.h"

#define XBDownloadTaskProgressNoti @"XBDownloadTaskProgressNoti"
#define XBDownloadTaskCompleteNoti @"XBDownloadTaskCompleteNoti"
#define XBDownloadTaskFailureNoti @"XBDownloadTaskFailureNoti"

@interface XBDownloadTaskManager : NSObject

+(instancetype)shareManager;

//-(BOOL)saveTaskList;

-(void)startTask:(XBDownloadTask *)task;

-(void)stopTask:(XBDownloadTask *)task;

//-(void)saveUncompleteTask;

-(void)stopTaskAndstoreTaskList;

@property (nonatomic,strong) NSMutableArray<XBDownloadTask *> *taskList;

@property (nonatomic,strong,readonly) NSMutableArray<XBDownloadTask *> *completeList;

@property (nonatomic,strong,readonly) NSMutableArray<XBDownloadTask *> *unCompleteList;



@end
