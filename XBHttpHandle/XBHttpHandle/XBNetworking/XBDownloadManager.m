//
//  XBDownloadManager.m
//  XBHttpHandle
//
//  Created by xxb on 2017/8/1.
//  Copyright © 2017年 xxb. All rights reserved.
//

#import "XBDownloadManager.h"
#import "XBNetworkingPublic.h"
#import <UIKit/UIKit.h>
#import "XBNetHandle.h"

#define listSavePath [NSHomeDirectory() stringByAppendingString:@"/Documents/XBDownloadManager_taskList"]

@interface XBDownloadManager ()

@end

@implementation XBDownloadManager
+ (instancetype)shared
{
    return [self new];
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static XBDownloadManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:zone];
    });
    return manager;
}
- (instancetype)init
{
    if (self = [super init])
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self addNotice];
        });
    }
    return self;
}
- (void)dealloc
{
    [self removeNotice];
}

#pragma mark - 任务管理
- (void)addTask:(XBDownloadTask *)xbTask
{
    BOOL isExist = NO;
    for (XBDownloadTask *task in self.taskList)
    {
        if (task.str_urlStr == xbTask.str_urlStr && task.str_savePath == xbTask.str_savePath)
        {
            isExist = YES;
            break;
        }
    }
    if ([self.taskList containsObject:xbTask] == NO && isExist == NO)
    {
        [self.taskList addObject:xbTask];
        [self saveTaskList];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotice_downloadTasklistChanged object:nil];
    }
}
- (void)removeTask:(XBDownloadTask *)xbTask deleteFile:(BOOL)deleteFile
{
    if (xbTask.b_isCompleted)
    {
        if (deleteFile)
        {
            if ([[NSFileManager defaultManager] fileExistsAtPath:xbTask.str_savePath])
            {
                [[NSFileManager defaultManager] removeItemAtPath:xbTask.str_savePath error:nil];
            }
        }
    }
    else
    {
        if (xbTask.b_isPause == false) //正在下载
        {
            [[XBDownloadManager shared] pauseTask:xbTask];
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:xbTask.str_savePath_temp])
        {
            [[NSFileManager defaultManager] removeItemAtPath:xbTask.str_savePath_temp error:nil];
        }
    }
    [self.taskList removeObject:xbTask];
    [self saveTaskList];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotice_downloadTasklistChanged object:nil];
}

- (void)saveTaskList
{
    [NSKeyedArchiver archiveRootObject:self.taskList toFile:listSavePath];;
}


- (void)startTask:(XBDownloadTask *)xbTask progressBlock:(XBProgressBlock)progressBlock completeBlock:(XBCompleteBlock)completeBlock failureBlock:(XBFailureBlock)failureBlock
{
    if (progressBlock)  {xbTask.bl_progressBlock = progressBlock;}
    if (completeBlock)  {xbTask.bl_completeBlock = completeBlock;}
    if (failureBlock)   {xbTask.bl_failureBlock = failureBlock;}
    
    XBDownloadTask *tempTask = nil;
    
    //先判断列表中有没有该任务（相同任务或者相同的下载链接并且相同的存储位置视作同一任务）
    for (XBDownloadTask *task in self.taskList)
    {
        if (task == xbTask)
        {
            tempTask = task;
            break;
        }
    }
    
    if (tempTask == nil) // 如果列表中没有该任务，判断下载地址和存储路径是否同时和任务列表中的某个任务相同
    {
        for (XBDownloadTask *task in self.taskList)
        {
            if (task.str_urlStr == xbTask.str_urlStr && task.str_savePath == xbTask.str_savePath)
            {
                tempTask = task;
                break;
            }
        }
    }
    
    if (tempTask != nil)  //任务已存在
    {
        if (tempTask.b_isCompleted)  //任务已经完成
        {
            if (xbTask.bl_completeBlock)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    XBDownloadTask * __weak weakTask = xbTask;
                    xbTask.bl_completeBlock(weakTask);
                });
            }
        }
        else if (tempTask.b_isPause)  //任务未完成，并处于暂停（停止）状态
        {
            [XBNetHandle downFileWith:tempTask];
        }
        else //任务未完成，并处于下载状态
        {
            [XBNetHandle downFileWith:tempTask];
        }
    }
    else //任务不存在
    {
        BOOL savePathExist = false;
        
        //不存在，遍历数组，查看保存路径是否已经被占用
        for (XBDownloadTask *item in self.taskList)
        {
            if (item.str_savePath == xbTask.str_savePath)
            {
                savePathExist = true;
                break;
            }
        }
        
        if (savePathExist)
        {
            //弹窗提醒，名字重复，请重新命名
            [[[UIAlertView alloc] initWithTitle:@"名称已存在！" message:[NSString stringWithFormat:@"%@ 名称已存在，请重命名",xbTask.str_savePath.lastPathComponent] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil] show];
        }
        else//都不存在，添加任务到列表，开始任务
        {
            [self addTask:xbTask];
            [XBNetHandle downFileWith:xbTask];
        }
    }
}

- (void)pauseTask:(XBDownloadTask *)xbTask
{
    [XBNetHandle stop:xbTask];
}

- (void)pauseAllTask
{
    if (self.unCompletedTaskList.count < 1)
    {
        return;
    }
    
    for (XBDownloadTask *task in self.unCompletedTaskList)
    {
        if (task.b_isPause == false)
        {
            [self pauseTask:task];
        }
    }
}

- (void)exitHandle
{
    [self pauseAllTask];
    [self saveTaskList];
}


#pragma mark - 通知,处理下载回调
- (void)addNotice
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskProgressHandle:) name:kNotice_progress object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskCompleteHandle:) name:kNotice_complete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskFailureHandle:) name:kNotice_failure object:nil];
}
- (void)removeNotice
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotice_progress object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotice_complete object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotice_failure object:nil];
}

- (void)taskProgressHandle:(NSNotification *)noti
{
    @synchronized (self)
    {
        NSLog(@"这是任务进度的回调");
        XBDownloadProgressObj *progressObj = noti.object;
        XBDownloadTask *task = nil;
        for (XBDownloadTask *tempTask in self.taskList) {
            if (tempTask.downloadTask == progressObj.downloadTask)
            {
                task = tempTask;
                break;
            }
        }
        task.int_bytesWritten = progressObj.int_bytesWritten;
        task.int_totalBytesWritten = progressObj.int_totalBytesWritten;
        task.int_totalBytesExpectedToWrite = progressObj.int_totalBytesExpectedToWrite;
        
        if (task.bl_progressBlock)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                XBDownloadTask * __weak weakTask = task;
                task.bl_progressBlock(weakTask);
            });
        }
    }
}

- (void)taskCompleteHandle:(NSNotification *)noti
{
    @synchronized (self)
    {
        NSLog(@"这是任务完成的回调");
        XBDownloadCompleteObj *completeObj = noti.object;
        XBDownloadTask *task = nil;
        for (XBDownloadTask *tempTask in self.taskList) {
            if (tempTask.downloadTask == completeObj.downloadTask)
            {
                task = tempTask;
                break;
            }
        }
        task.b_isPause = YES;
        task.b_isCompleted = YES;
        [self saveTaskList];
        
        //保存文件
        NSError *error_move = nil;
        NSURL *saveUrl = [NSURL fileURLWithPath:task.str_savePath];
        if (saveUrl == nil)
        {
            
            return;
        }
        [[NSFileManager defaultManager] moveItemAtURL:completeObj.location toURL:saveUrl error:&error_move];
        if (error_move)
        {
            NSLog(@"保存出错了，错误:%@",error_move);
        }
        
        //删除缓存
        if ([[NSFileManager defaultManager] fileExistsAtPath:task.str_savePath_temp])
        {
            
            NSError *error_remove = nil;
            [[NSFileManager defaultManager] removeItemAtPath:task.str_savePath_temp error:&error_remove];
            if (error_remove)
            {
                NSLog(@"删除缓存出错了，错误:%@",error_remove);
            }
        }
        
        if (task.bl_completeBlock)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                XBDownloadTask * __weak weakTask = task;
                task.bl_completeBlock(weakTask);
            });
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotice_downloadTasklistChanged object:nil];
    }
}

- (void)taskFailureHandle:(NSNotification *)noti
{
    @synchronized (self)
    {
        XBDownloadFailureObj *failureObj = noti.object;
        XBDownloadTask *task = nil;
        for (XBDownloadTask *tempTask in self.taskList) {
            if (tempTask.downloadTask == failureObj.downloadTask)
            {
                task = tempTask;
                break;
            }
        }
        task.b_isPause = YES;
        
        if (task.bl_failureBlock)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                task.bl_failureBlock(failureObj.error);
            });
        }
    }
}


#pragma mark - 懒加载
- (NSMutableArray<XBDownloadTask *> *)taskList
{
    if (_taskList == nil)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:listSavePath])
        {
            _taskList = [NSKeyedUnarchiver unarchiveObjectWithFile:listSavePath];
        }
        else
        {
            _taskList = [NSMutableArray new];
        }
    }
    return _taskList;
}
-(NSMutableArray<XBDownloadTask *> *)unCompletedTaskList
{
    NSMutableArray *arrM = [NSMutableArray new];
    for (XBDownloadTask *tempTask in self.taskList)
    {
        if (tempTask.b_isCompleted == NO)
        {
            [arrM addObject:tempTask];
        }
    }
    return arrM;
}
- (NSMutableArray<XBDownloadTask *> *)completedTaskList
{
    NSMutableArray *arrM = [NSMutableArray new];
    for (XBDownloadTask *tempTask in self.taskList)
    {
        if (tempTask.b_isCompleted == YES)
        {
            [arrM addObject:tempTask];
        }
    }
    return arrM;
}


#pragma mark - 其他方法


@end
