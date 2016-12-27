//
//  XBHttpHandle.m
//  XBHttpHandle
//
//  Created by chuango on 16/10/26.
//  Copyright © 2016年 chuango. All rights reserved.
//

#import "XBHttpHandle.h"
#import <objc/runtime.h>

#define downTaskSavePathAppendTemp @"XBDownloadTemp"

@interface XBHttpHandle ()<NSURLSessionDownloadDelegate>
    @property (nonatomic,strong) NSURLSession *session;
    @property (nonatomic,strong) NSMutableDictionary *downTaskModelDicM;
    @end

@implementation XBHttpHandle
    
    
    
#pragma mark - 构造方法
    
+(instancetype)shareHttpHandle
    {
        return [self new];
    }
    
+(instancetype)allocWithZone:(struct _NSZone *)zone
    {
        static XBHttpHandle *handle=nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            handle=[super allocWithZone:zone];
            
            if([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0)
            {
                NSURLSessionConfiguration *configuration = nil;
                
#ifdef TARGET_IPHONE_SIMULATOR
                configuration=[NSURLSessionConfiguration backgroundSessionConfiguration:@"lalala"];
//                configuration=[NSURLSessionConfiguration defaultSessionConfiguration];
#else
                configuration=[NSURLSessionConfiguration backgroundSessionConfiguration:@"lalala"];
#endif
                 
                /*
                configuration=[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"lalala"];
                 */
                handle.session=[NSURLSession sessionWithConfiguration:configuration delegate:handle delegateQueue:[NSOperationQueue new]];
            }
            else
            {
                handle.session=[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:handle delegateQueue:[NSOperationQueue new]];
            }
            handle.downTaskModelDicM=[NSMutableDictionary new];
        });
        return handle;
    }
    
    
    
#pragma mark - 类方法
    /** get请求 */
+(void)getRequestWithUrlStr:(NSString *)urlStr successBlock:(RequestSuccessBlock)successBlock failureBlock:(RequestFailureBlock)failureBlock
    {
        NSURL *url=[NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
        NSURLSession *session=[NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
#ifdef DEBUG
            NSLog(@"\r回调\r");
            NSLog(@"\r下载数据线程：%@\r",[NSThread currentThread]);
#endif
            id result=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            BOOL resultIsDict=[result isKindOfClass:[NSDictionary class]];
            BOOL resultIsArr=[result isKindOfClass:[NSArray class]];
#ifdef DEBUG
            NSLog(@"\r\r网络请求：get 请求\r\r请求链接是：\r%@\r\r请求结果是：\r%@\r\r\r\r\r",urlStr,resultIsDict?result:data);
#endif
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"");
                if (error)
                {
                    if (failureBlock)
                    {
                        RequestFailureBlock faBlock=[failureBlock copy];
                        faBlock(error);
                    }
                }
                else
                {
                    if (successBlock)
                    {
                        RequestSuccessBlock suBlock=[successBlock copy];
                        if (resultIsDict || resultIsArr)//如果结果是字典，返回字典
                        {
                            suBlock(result);
                        }
                        else//否则直接返回数据
                        {
                            suBlock(data);
                        }
                    }
                }
            });
        }];
        //        NSURLSessionDataTask *dataTask=[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //#ifdef DEBUG
        //            NSLog(@"\r回调\r");
        //            NSLog(@"\r下载数据线程：%@\r",[NSThread currentThread]);
        //#endif
        //            id result=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        //            BOOL resultIsDict=[result isKindOfClass:[NSDictionary class]];
        //            BOOL resultIsArr=[result isKindOfClass:[NSArray class]];
        //#ifdef DEBUG
        //            NSLog(@"\r\r网络请求：get 请求\r\r请求链接是：\r%@\r\r请求结果是：\r%@\r\r\r\r\r",urlStr,resultIsDict?result:data);
        //#endif
        //            dispatch_async(dispatch_get_main_queue(), ^{
        //                if (error)
        //                {
        //                    if (failureBlock)
        //                    {
        //                        RequestFailureBlock faBlock=[failureBlock copy];
        //                        faBlock(error);
        //                    }
        //                }
        //                else
        //                {
        //                    if (successBlock)
        //                    {
        //                        RequestSuccessBlock suBlock=[successBlock copy];
        //                        if (resultIsDict || resultIsArr)//如果结果是字典，返回字典
        //                        {
        //                            suBlock(result);
        //                        }
        //                        else//否则直接返回数据
        //                        {
        //                            suBlock(data);
        //                        }
        //                    }
        //                }
        //            });
        //        }];
        [dataTask resume];
    }
    /** post请求 */
+(void)postRequestWithUrlStr:(NSString *)urlStr params:(NSDictionary *)params successBlock:(RequestSuccessBlock)successBlock failureBlock:(RequestFailureBlock)failureBlock
    {
        if (params.count<1)
        {
            [XBHttpHandle getRequestWithUrlStr:urlStr successBlock:successBlock failureBlock:failureBlock];
            return;
        }
        
        //确定请求路径
        NSURL *url = [NSURL URLWithString:urlStr];
        //创建可变请求对象
        NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:url];
        //修改请求方法
        requestM.HTTPMethod = @"POST";
        
        //拼接参数
        NSMutableString *paramsStr=[@"" mutableCopy];
        for (NSString *key in params)
        {
            NSString *str=[key stringByAppendingString:[@"="stringByAppendingString:params[key]]];
            [paramsStr appendString:str];
            [paramsStr appendString:@"&"];
        }
        if (params.count<1)
        {
            [paramsStr appendString:@"&"];
        }
        [paramsStr appendString:@"type=JSON"];
        //设置请求体
        requestM.HTTPBody = [paramsStr dataUsingEncoding:NSUTF8StringEncoding];
        //创建会话对象
        NSURLSession *session = [NSURLSession sharedSession];
        //创建请求 Task
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:requestM completionHandler:
                                          ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                              
                                              id result=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                              BOOL resultIsDict=[result isKindOfClass:[NSDictionary class]];
                                              BOOL resultIsArr=[result isKindOfClass:[NSArray class]];
#ifdef DEBUG
                                              NSLog(@"\r\r网络请求：post 请求\r\r请求链接是：\r%@\r\r请求参数是：\r%@\r\r请求结果是：\r%@\r\r转换成get请求：\r%@\r\r\r\r\r",urlStr,params,resultIsDict?result:data,[urlStr stringByAppendingString:[@"?" stringByAppendingString:paramsStr]]);
#endif
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  if (error)
                                                  {
                                                      if (failureBlock)
                                                      {
                                                          RequestFailureBlock faBlock=[failureBlock copy];
                                                          faBlock(error);
                                                      }
                                                  }
                                                  else
                                                  {
                                                      if (successBlock)
                                                      {
                                                          RequestSuccessBlock suBlock=[successBlock copy];
                                                          if (resultIsDict || resultIsArr)//如果结果是字典，返回字典
                                                          {
                                                              suBlock(result);
                                                          }
                                                          else//否则直接返回数据
                                                          {
                                                              suBlock(data);
                                                          }
                                                      }
                                                  }
                                              });
                                          }];
        //发送请求
        [dataTask resume];
    }
    
    
    
#pragma mark - 代理方法
#pragma mark - 下载相关
+(void)downFileWithXBDownloadTask:(XBDownloadTask *)task progressBlock:(DownloadProgressBlockWithTask)progressBlock complete:(DownloadCompleteBlockWithTask)completeBlock failureBlock:(RequestFailureBlock)failureBlock
{
    NSString *urlStr=task.urlStr;
    NSString *savePath=task.savePath;
#ifdef DEBUG
    NSLog(@"\r\r正在下载，下载地址：\r%@\r\r下载完成后的存储路径：\r%@\r\r\r\r\r",urlStr,savePath);
#endif
    XBHttpHandleDownTaskModel *model=[XBHttpHandle shareHttpHandle].downTaskModelDicM[savePath];
    if (model)//如果当前任务已存在，只是被挂起
    {
        model.progressBlockWithTask=[progressBlock copy];
        model.completeBlockWithTask=[completeBlock copy];
        model.failureBlock=[failureBlock copy];
        if (model.isStopping==YES)
        {
            model.downTask=[[XBHttpHandle shareHttpHandle] downloadTaskWithPath:model.savePath];
            [model.downTask resume];
            model.isStopping=NO;
        }
    }
    else
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:savePath])//如果已经下载完成
        {
            if (completeBlock)
            {
                DownloadCompleteBlockWithTask comBlock=[completeBlock copy];
                comBlock(nil);
            }
        }
        else if ([[NSFileManager defaultManager] fileExistsAtPath:[savePath stringByAppendingString:downTaskSavePathAppendTemp]])//如果之前有下载，但是没有完成
        {
            NSURLSessionDownloadTask *downTask=[[XBHttpHandle shareHttpHandle] downloadTaskWithPath:savePath];
            model=[XBHttpHandle shareHttpHandle].downTaskModelDicM[savePath];
            if (model==nil)
            {
                model=[XBHttpHandleDownTaskModel new];
                model.savePath=savePath;
                model.xbTask=task;
                model.progressBlockWithTask=[progressBlock copy];
                model.completeBlockWithTask=[completeBlock copy];
                model.failureBlock=[failureBlock copy];
                [[XBHttpHandle shareHttpHandle].downTaskModelDicM setObject:model forKey:savePath];
            }
            model.downTask=downTask;
            [downTask resume];
        }
        else//全新的下载
        {
            NSURLSessionDownloadTask *downTask=[[XBHttpHandle shareHttpHandle].session downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
            model=[XBHttpHandleDownTaskModel new];
            model.downTask=downTask;
            model.savePath=savePath;
            model.xbTask=task;
            model.progressBlockWithTask=[progressBlock copy];
            model.completeBlockWithTask=[completeBlock copy];
            model.failureBlock=[failureBlock copy];
            [[XBHttpHandle shareHttpHandle].downTaskModelDicM setObject:model forKey:savePath];
            [downTask resume];
        }
    }
}
+(void)downFileWithUrlStr:(NSString *)urlStr savePath:(NSString *)savePath progressBlock:(DownloadProgressBlock)progressBlock complete:(DownloadCompleteBlock)completeBlock failureBlock:(RequestFailureBlock)failureBlock
    {
#ifdef DEBUG
        NSLog(@"\r\r正在下载，下载地址：\r%@\r\r下载完成后的存储路径：\r%@\r\r\r\r\r",urlStr,savePath);
#endif
        XBHttpHandleDownTaskModel *model=[XBHttpHandle shareHttpHandle].downTaskModelDicM[savePath];
        if (model)//如果当前任务已存在，只是被挂起
        {
            model.progressBlock=[progressBlock copy];
            model.completeBlock=[completeBlock copy];
            model.failureBlock=[failureBlock copy];
            if (model.isStopping==YES)
            {
                model.downTask=[[XBHttpHandle shareHttpHandle] downloadTaskWithPath:model.savePath];
                [model.downTask resume];
                model.isStopping=NO;
            }
        }
        else
        {
            if ([[NSFileManager defaultManager] fileExistsAtPath:savePath])//如果已经下载完成
            {
                if (completeBlock)
                {
                    DownloadCompleteBlock comBlock=[completeBlock copy];
                    comBlock();
                }
            }
            else if ([[NSFileManager defaultManager] fileExistsAtPath:[savePath stringByAppendingString:downTaskSavePathAppendTemp]])//如果之前有下载，但是没有完成
            {
                NSURLSessionDownloadTask *downTask=[[XBHttpHandle shareHttpHandle] downloadTaskWithPath:savePath];
                model=[XBHttpHandle shareHttpHandle].downTaskModelDicM[savePath];
                if (model==nil)
                {
                    model=[XBHttpHandleDownTaskModel new];
                    model.savePath=savePath;
                    model.progressBlock=[progressBlock copy];
                    model.completeBlock=[completeBlock copy];
                    model.failureBlock=[failureBlock copy];
                    [[XBHttpHandle shareHttpHandle].downTaskModelDicM setObject:model forKey:savePath];
                }
                model.downTask=downTask;
                [downTask resume];
            }
            else//全新的下载
            {
                NSURLSessionDownloadTask *downTask=[[XBHttpHandle shareHttpHandle].session downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
                model=[XBHttpHandleDownTaskModel new];
                model.downTask=downTask;
                model.savePath=savePath;
                model.progressBlock=[progressBlock copy];
                model.completeBlock=[completeBlock copy];
                model.failureBlock=[failureBlock copy];
                [[XBHttpHandle shareHttpHandle].downTaskModelDicM setObject:model forKey:savePath];
                [downTask resume];
            }
        }
    }
#pragma mark - 代理方法
    //下载完成、发生错误、手动取消（调用saveUncompleteTask）时会调用
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
    {
        XBHttpHandleDownTaskModel *model=[self findModelWithDownloadtask:task];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                if(error.code==-999)//手动取消
                {
                    
                }
                else
                {
                    if (model.failureBlock)
                    {
                        RequestFailureBlock failureBlock=[model.failureBlock copy];
                        failureBlock(error);
                    }
                }
            }
            else
            {
                
            }
        });
    }
    
    //下载完成
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
    {
        XBHttpHandleDownTaskModel *model=[self findModelWithDownloadtask:downloadTask];
        if (model.savePath) {
            [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:model.savePath] error:nil];
            if ([[NSFileManager defaultManager] fileExistsAtPath:[model.savePath stringByAppendingString:downTaskSavePathAppendTemp]])
            {
                [[NSFileManager defaultManager] removeItemAtPath:[model.savePath stringByAppendingString:downTaskSavePathAppendTemp] error:nil];
            }
        }
        if (model.completeBlock)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                DownloadCompleteBlock completeBlock=[model.completeBlock copy];
                completeBlock();
            });
        }
        if (model.completeBlockWithTask)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                DownloadCompleteBlockWithTask completeBlock=[model.completeBlockWithTask copy];
                completeBlock(model);
            });
        }
        if (model.savePath) {
            [[XBHttpHandle shareHttpHandle].downTaskModelDicM removeObjectForKey:model.savePath];
        }
    }
    
    //下载进度
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
    {
        XBHttpHandleDownTaskModel *model=[self findModelWithDownloadtask:downloadTask];
        if (model.progressBlock)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                DownloadProgressBlock progressBlock=[model.progressBlock copy];
                progressBlock(1.0*totalBytesWritten/totalBytesExpectedToWrite);
            });
        }
        if (model.progressBlockWithTask)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                DownloadProgressBlockWithTask progressBlock=[model.progressBlockWithTask copy];
                progressBlock(model,1.0*totalBytesWritten/totalBytesExpectedToWrite,totalBytesWritten,totalBytesExpectedToWrite);
            });
        }
    }
    
    /* Sent when a download has been resumed. If a download failed with an
     * error, the -userInfo dictionary of the error will contain an
     * NSURLSessionDownloadTaskResumeData key, whose value is the resume
     * data.
     */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
    {
        
    }
    
    //查找model
-(XBHttpHandleDownTaskModel *)findModelWithDownloadtask:(NSURLSessionTask *)downloadTask
    {
        __block XBHttpHandleDownTaskModel *model=nil;
        NSMutableDictionary *dictTemp=[XBHttpHandle shareHttpHandle].downTaskModelDicM;
        for (XBHttpHandleDownTaskModel *obj in dictTemp.allValues)
        {
            if (obj.downTask==downloadTask)
            {
                model=obj;
                break;
            }
        }
        return model;
    }
    
    
    //程序要退出时，保存未完成的任务
    //在appDelegate的代理方法中调用
+(void)saveUncompleteTask
    {
        for (NSString *key in [XBHttpHandle shareHttpHandle].downTaskModelDicM.allValues)
        {
            XBHttpHandleDownTaskModel *model=[XBHttpHandle shareHttpHandle].downTaskModelDicM[key];
            [XBHttpHandle stopTaskWithModel:model];
        }
    }

//停止任务
+(void)stopTaskWithModel:(XBHttpHandleDownTaskModel *)model
{
    if(model.isStopping==NO)
    {
        [model.downTask cancelByProducingResumeData:^(NSData * _Nullable resumeData)
         {
             BOOL result=[NSKeyedArchiver archiveRootObject:resumeData toFile:[model.savePath stringByAppendingString:downTaskSavePathAppendTemp]];
             NSLog(@"归档路径：%@",[model.savePath stringByAppendingString:downTaskSavePathAppendTemp]);
             if (result == YES)
             {
                 NSLog(@"存储未完成任务结果：成功");
             }
             else
             {
                 NSLog(@"存储未完成任务结果：失败");
             }
         }];
        model.isStopping=YES;
    }
}

    //重新开始没有完成的任务
+(void)startUncompleteTask
    {
        for (NSString *key in [XBHttpHandle shareHttpHandle].downTaskModelDicM.allValues)
        {
            XBHttpHandleDownTaskModel *model=[XBHttpHandle shareHttpHandle].downTaskModelDicM[key];
            [XBHttpHandle startTaskWithModel:model];
        }
    }

+(void)startTaskWithModel:(XBHttpHandleDownTaskModel *)model
{
    if (model.isStopping==YES)
    {
        model.downTask=[[XBHttpHandle shareHttpHandle] downloadTaskWithPath:model.savePath];
        [model.downTask resume];
        model.isStopping=NO;
    }
}

+(void)stopTaskWithXBDownloadTask:(XBDownloadTask *)task
{
    [XBHttpHandle stopTaskWithModel:[XBHttpHandle fineModelWithXBDownloadTask:task]];
}


+(XBHttpHandleDownTaskModel *)fineModelWithXBDownloadTask:(XBDownloadTask *)task
{
    __block XBHttpHandleDownTaskModel *model=nil;
    NSMutableDictionary *dictTemp=[XBHttpHandle shareHttpHandle].downTaskModelDicM;
    for (XBHttpHandleDownTaskModel *obj in dictTemp.allValues)
    {
        if (obj.xbTask==task)
        {
            model=obj;
            break;
        }
    }
    return model;
}


-(NSURLSessionDownloadTask *)downloadTaskWithPath:(NSString *)savePath
    {
        NSData *resumeData=[NSKeyedUnarchiver unarchiveObjectWithFile:[savePath stringByAppendingString:downTaskSavePathAppendTemp]];
        return [[XBHttpHandle shareHttpHandle].session downloadTaskWithResumeData:resumeData];
    }
    @end
