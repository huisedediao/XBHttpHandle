//
//  XBDownloadTaskManager.m
//  XBHttpHandle
//
//  Created by xxb on 2016/12/26.
//  Copyright © 2016年 chuango. All rights reserved.
//

#import "XBDownloadTaskManager.h"
#import "XBHttpHandle.h"

#define kListSavePath [NSHomeDirectory() stringByAppendingString:@"/Documents/xbTaskList.xb"]

@implementation XBDownloadTaskManager

+(instancetype)shareManager
{
    return [XBDownloadTaskManager new];
}

-(instancetype)init
{
    if (self=[super init])
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            /** 
             这里有个坑，以为allocWithZone只分配一次内存，这里面的代码就不执行了。而事实上，在 shareManager 方法中调用 [XBDownloadTaskManager new] ，每次都会调用init方法，每次都调用allocWithZone方法，确实是只分配了一次内存，但是if (self=[super init])这个条件是成立的，所以内次都跑了，所以，如果在init方法里有对属性的相关操作，也要加once操作
             */
            self.taskList=[NSMutableArray new];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
            NSArray *arr=[NSKeyedUnarchiver unarchiveObjectWithFile:kListSavePath];
            if (arr.count)
            {
                //这里又有个坑，ios10开始，每次启动程序沙盒路径都变了（但是之前存储在沙盒里的东西会移到新路径），如果保存的是之前的路径，用到的时候会处错误（比如往之前存储的路径下归档文件，会返回失败），所以这里要更新之前存储的沙盒路径
                for (XBDownloadTask *task in arr)
                {
                    NSLog(@"旧的存储路径：%@",task.savePath);
                    task.savePath=[NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@",[task.savePath lastPathComponent]]];
                    NSLog(@"新的存储路径：%@",task.savePath);
                }
                [self.taskList addObjectsFromArray:arr];
            }
        });
    }
    return self;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static XBDownloadTaskManager *task=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        task=[super allocWithZone:zone];
    });
    return task;
}

-(BOOL)saveTaskList
{
    return [NSKeyedArchiver archiveRootObject:self.taskList toFile:kListSavePath];
}


-(void)startTask:(XBDownloadTask *)task
{
    [XBHttpHandle downFileWithXBDownloadTask:task progressBlock:^(XBHttpHandleDownTaskModel *model, float progress,int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        NSLog(@"回调进度：%f",progress);
        model.xbTask.progress=progress;
        model.xbTask.totalBytesWritten=totalBytesWritten;
        model.xbTask.totalBytesExpectedToWrite=totalBytesExpectedToWrite;
        [[NSNotificationCenter defaultCenter] postNotificationName:XBDownloadTaskProgressNoti object:model.xbTask];
    } complete:^(XBHttpHandleDownTaskModel *model) {
        model.xbTask.isComplete=YES;
        [self saveTaskList];
        [[NSNotificationCenter defaultCenter] postNotificationName:XBDownloadTaskCompleteNoti object:model.xbTask];
    } failureBlock:^(NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:XBDownloadTaskFailureNoti object:error];
    }];
}

-(void)stopTask:(XBDownloadTask *)task
{
    task.isDownloading=NO;
    [XBHttpHandle stopTaskWithXBDownloadTask:task];
}

-(void)saveUncompleteTask
{
    @synchronized (self)
    {
        NSArray *unCompleteTaskArr=[self.unCompleteList copy];
        for (XBDownloadTask *task in unCompleteTaskArr)
        {
            if (task.isComplete==NO) {
                [self stopTask:task];
            }
        }
    }
}

-(void)stopTaskAndstoreTaskList
{
    [[XBDownloadTaskManager shareManager] saveUncompleteTask];
    [[XBDownloadTaskManager shareManager] saveTaskList];
}


#pragma mark - 通知回调
-(void)appWillEnterForeground:(NSNotification *)noti
{
    NSArray *unCompleteTaskArr=[self.unCompleteList copy];
    for (XBDownloadTask *task in unCompleteTaskArr)
    {
        if (task.isComplete==NO) {
            if (task.isDownloading==YES)
            {
                [self startTask:task];
                //多调一次，避免有时候从后台进入前台没有刷新界面进度
                [self startTask:task];
            }
        }
    }
     
}



#pragma mark - 懒加载

-(NSMutableArray<XBDownloadTask *> *)completeList
{
    NSMutableArray *result=[NSMutableArray new];
    for (XBDownloadTask *task in self.taskList)
    {
        if (task.isComplete)
        {
            [result addObject:task];
        }
    }
    return result;
}
-(NSMutableArray<XBDownloadTask *> *)unCompleteList
{
    NSMutableArray *result=[NSMutableArray new];
    for (XBDownloadTask *task in self.taskList)
    {
        if (task.isComplete==NO)
        {
            [result addObject:task];
        }
    }
    return result;
}
@end
