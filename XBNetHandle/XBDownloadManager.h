//
//  XBDownloadManager.h
//  XBHttpHandle
//
//  Created by xxb on 2017/8/1.
//  Copyright © 2017年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XBDownloadTask.h"

@interface XBDownloadManager : NSObject
@property (nonatomic,strong) NSMutableArray <XBDownloadTask *> *taskList;
@property (nonatomic,strong) NSMutableArray <XBDownloadTask *> *unCompletedTaskList;
@property (nonatomic,strong) NSMutableArray <XBDownloadTask *> *completedTaskList;

+ (instancetype)shared;
- (void)addTask:(XBDownloadTask *)task;
- (void)removeTask:(XBDownloadTask *)xbTask deleteFile:(BOOL)deleteFile;
- (void)saveTaskList;
- (void)pauseTask:(XBDownloadTask *)xbTask;
- (void)pauseAllTask;
- (void)exitHandle;
- (void)startTask:(XBDownloadTask *)xbTask progressBlock:(XBProgressBlock)progressBlock completeBlock:(XBCompleteBlock)completeBlock failureBlock:(XBFailureBlock)failureBlock;
@end
