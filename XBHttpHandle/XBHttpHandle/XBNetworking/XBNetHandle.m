//
//  XBNetHandle.m
//  XBHttpHandle
//
//  Created by xxb on 2017/8/1.
//  Copyright © 2017年 xxb. All rights reserved.
//

#import "XBNetHandle.h"


@interface XBNetHandle () <NSURLSessionDownloadDelegate>

@end

@implementation XBNetHandle


+ (instancetype)shared
{
    return [self new];
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static XBNetHandle *handle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handle = [super allocWithZone:zone];
    });
    return handle;
}


#pragma mark - get、post请求
/*----- get请求 -----*/
+ (void)getRequestWithUrlStr:(NSString *)urlStr successBlock:(XBRequestSuccessBlock)successBlock failureBlock:(XBFailureBlock)failureBlock
{
    if (urlStr.length)
    {
        NSURL *url = [NSURL URLWithString:[XBNetHandle stringUseNSUTF8:urlStr]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSError *httpError = [XBNetHandle handleHttpUrlResponse:response responseError:error];
            if (httpError)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failureBlock)
                    {
                        failureBlock(httpError);
                    }
                });
                return;
            }
            
            id result = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
            BOOL resultIsDict=[result isKindOfClass:[NSDictionary class]];
            BOOL resultIsArr=[result isKindOfClass:[NSArray class]];
#ifdef DEBUG
            NSLog(@"\rGET请求\r请求链接是：\r%@",urlStr);
            NSLog(@"\r\r请求结果是：\r%@\r\r\r\r\r",(resultIsDict||resultIsArr)?result:data);
#endif
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    if (failureBlock)
                    {
                        XBFailureBlock faBlock=[failureBlock copy];
                        faBlock(error);
                    }
                }
                else
                {
                    if (successBlock)
                    {
                        XBRequestSuccessBlock suBlock=[successBlock copy];
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
            //            NSLog(@"\rGET请求\r请求链接是：%@",urlStr);
            //            NSLog(@"请求结果是：%@",data);
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                if (error)
            //                {
            //                    failureBlock(error);
            //                }
            //                else if (data)
            //                {
            //                    successBlock(data);
            //                }
            //            });
        }];
        
        [task resume];
    }
}

/*----- post请求 -----*/
+ (void)postRequestWithUrlStr:(NSString *)urlStr params:(NSDictionary *)params successBlock:(XBRequestSuccessBlock)successBlock failureBlock:(XBFailureBlock)failureBlock
{
    if (urlStr.length)
    {
        if (params.count<1)
        {
            [XBNetHandle getRequestWithUrlStr:urlStr successBlock:successBlock failureBlock:failureBlock];
            return;
        }
        
        //确定请求路径
        NSURL *url = [NSURL URLWithString:[XBNetHandle stringUseNSUTF8:urlStr]];
        //创建可变请求对象
        NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:url];
        //修改请求方法
        requestM.HTTPMethod = @"POST";
        
        //拼接参数
        NSMutableString *paramsStr = [XBNetHandle getParamsStrWithParamsDic:params];
        //        NSMutableString *paramsStr=[@"" mutableCopy];
        //        NSArray *allKeys = [params allKeys];
        //        for (NSString *key in allKeys)
        //        {
        //            NSInteger index = [allKeys indexOfObject:key];
        //            NSString *paramStr = nil;
        //            id para = params[key];
        //            if ([para isKindOfClass:[NSString class]])
        //            {
        //                paramStr = para;
        //            }
        //            else if ([para isKindOfClass:[NSNumber class]])
        //            {
        //                paramStr = [NSString stringWithFormat:@"%zd",[para integerValue]];
        //            }
        //            else
        //            {
        //                paramStr = para;
        //            }
        //
        //            NSString *str=[key stringByAppendingString:[@"="stringByAppendingString:paramStr]];
        //            [paramsStr appendString:str];
        //            if (index != allKeys.count - 1)
        //            {
        //                [paramsStr appendString:@"&"];
        //            }
        //        }
        if (params.count < 1)
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
                                              NSError *httpError = [XBNetHandle handleHttpUrlResponse:response responseError:error];
                                              if (httpError)
                                              {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      if (failureBlock)
                                                      {
                                                          failureBlock(httpError);
                                                      }
                                                  });
                                                  return;
                                              }
                                              
                                              if ([data isKindOfClass:NSClassFromString(@"NSZeroData")])
                                              {
                                                  
                                              }
                                              id result = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
                                              BOOL resultIsDict=[result isKindOfClass:[NSDictionary class]];
                                              BOOL resultIsArr=[result isKindOfClass:[NSArray class]];
#ifdef DEBUG
                                              NSLog(@"\r\r网络请求：post 请求\r\r请求链接是：\r%@\r\r请求参数是：\r%@\r\r请求结果是：\r%@\r\r转换成get请求：\r%@\r\r\r\r\r",urlStr,params,(resultIsDict||resultIsArr)?result:data,[urlStr stringByAppendingString:[@"?" stringByAppendingString:paramsStr]]);
#endif
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  if (error)
                                                  {
                                                      if (failureBlock)
                                                      {
                                                          XBFailureBlock faBlock=[failureBlock copy];
                                                          faBlock(error);
                                                      }
                                                  }
                                                  else
                                                  {
                                                      if (successBlock)
                                                      {
                                                          XBRequestSuccessBlock suBlock=[successBlock copy];
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
}
#pragma mark - 其他方法
/**
 网址中文转码
 */
+(NSString *)stringUseNSUTF8:(NSString *)str
{
    if([XBNetHandle isChineseStr:str])//网址带中文,转码
    {
        return [[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    return [str stringByReplacingOccurrencesOfString:@" " withString:@""];
}

/**
 判断字符串中是否有中文
 */
+(BOOL)isChineseStr:(NSString *)str
{
    for(int i=0; i< [str length];i++)
    {
        int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff)
        {
            return YES;
        }
    }
    return NO;
}

/**
 把参数字典拼接成参数字符串
 */
+ (NSMutableString *)getParamsStrWithParamsDic:(NSDictionary *)params
{
    NSMutableString *paramsStr = [NSMutableString new];
    NSArray *allKeys = [params allKeys];
    for (NSString *key in allKeys)
    {
        NSInteger index = [allKeys indexOfObject:key];
        NSString *paramStr = nil;
        id para = params[key];
        if ([para isKindOfClass:[NSString class]])
        {
            paramStr = para;
        }
        else if ([para isKindOfClass:[NSNumber class]])
        {
            paramStr = [NSString stringWithFormat:@"%zd",[para integerValue]];
        }
        else if ([para isKindOfClass:[NSDictionary class]])
        {
            paramStr = [XBNetHandle getParamsStrWithParamsDic:para];
        }
        else
        {
            paramsStr = para;
        }
        
        NSString *str=[key stringByAppendingString:[@"="stringByAppendingString:paramStr]];
        [paramsStr appendString:str];
        if (index != allKeys.count - 1)
        {
            [paramsStr appendString:@"&"];
        }
    }
    return paramsStr;
}

/**
 处理服务器错误
 */
+ (NSError *)handleHttpUrlResponse:(NSURLResponse *)response responseError:(NSError *)responseError
{
    NSInteger code = 200;
    NSError *error = nil;
    if (responseError)
    {
        code = responseError.code;
    }
    if (code == 200 && [response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        code = httpResponse.statusCode;
    }
    
    if (code == 200)
    {
        
    }
    else if (code == 404 || code == -1100 || code == -1003)
    {
        error = [[NSError alloc] initWithDomain:@"请求的页面不存在" code:kResponseErrorCode userInfo:nil];
    }
    else if (code == 503)
    {
        error = [[NSError alloc] initWithDomain:@"服务不可用" code:kResponseErrorCode userInfo:nil];
    }
    else if (code == -1001)
    {
        error = [[NSError alloc] initWithDomain:@"请求超时" code:kResponseErrorCode userInfo:nil];
    }
    else
    {
        error = [[NSError alloc] initWithDomain:@"服务器返回数据异常" code:kResponseErrorCode userInfo:nil];
    }
    return error;
}


#pragma mark - 下载方法
+ (void)downFileWith:(XBDownloadTask *)xbTask
{
    @synchronized ([XBNetHandle shared])
    {
        NSString *savePath = xbTask.str_savePath;
        NSString *urlStr = xbTask.str_urlStr;
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:savePath])//已经存在，表示已经下载完成
        {
            if (xbTask.bl_completeBlock)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    XBDownloadTask * __weak weakTask = xbTask;
                    xbTask.bl_completeBlock(weakTask);
                });
            }
        }
        else if ([[NSFileManager defaultManager] fileExistsAtPath:xbTask.str_savePath_temp])//之前有下载，但是没有下载完成
        {
            if (xbTask.b_isPause == YES)
            {
                NSData *data = [NSKeyedUnarchiver unarchiveObjectWithFile:xbTask.str_savePath_temp];
                NSURLSessionDownloadTask *downloadTask = [[XBNetHandle shared].session downloadTaskWithResumeData:data];
                [downloadTask resume];
                xbTask.b_isPause = false;
                xbTask.downloadTask = downloadTask;
            }
        }
        else //全新的下载,还有一种情况就是重复开始某个任务，但是重复开始下载之前，并没有暂停，所以加个判断
        {
            if (xbTask.b_isPause == YES)
            {
                NSURLSessionDownloadTask *downloadTask = [[XBNetHandle shared].session downloadTaskWithURL:[NSURL URLWithString:urlStr]];
                [downloadTask resume];
                xbTask.b_isPause = false;
                xbTask.downloadTask = downloadTask;
            }
        }
    }
}

+ (void)stop:(XBDownloadTask *)xbTask
{
    @synchronized ([XBNetHandle shared])
    {
        xbTask.b_isPause = true;
        if (xbTask.downloadTask)
        {
            [xbTask.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                if (1)//条件后面再加，10.2还是10.1忘了，从数据创建任务会出错，保存了也没用，
                {
                    [NSKeyedArchiver archiveRootObject:resumeData toFile:xbTask.str_savePath_temp];
                }
            }];
        }
    }
}

#pragma mark - URLSession代理方法
/// 下载完成
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    @synchronized ([XBNetHandle shared])
    {
        NSLog(@"URLSession代理方法 任务完成回调");
        XBDownloadCompleteObj *completeObj = [XBDownloadCompleteObj new];
        completeObj.downloadTask = downloadTask;
        completeObj.location = location;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotice_complete object:completeObj];
    }
}
/// 下载进度
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    @synchronized ([XBNetHandle shared])
    {
        XBDownloadProgressObj *progressObj = [XBDownloadProgressObj new];
        progressObj.downloadTask = downloadTask;
        progressObj.int_bytesWritten = bytesWritten;
        progressObj.int_totalBytesWritten = totalBytesWritten;
        progressObj.int_totalBytesExpectedToWrite = totalBytesExpectedToWrite;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotice_progress object:progressObj];
    }
}

/// 任务完成、出现错误、手动取消都会跑这个方法
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    @synchronized ([XBNetHandle shared])
    {
        if (error)
        {
            if (error.code == 999) //手动取消
            {
                
            }
            else
            {
                XBDownloadFailureObj *failureObj = [XBDownloadFailureObj new];
                failureObj.downloadTask = (NSURLSessionDownloadTask *)task;
                failureObj.error = error;
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotice_failure object:failureObj];
            }
        }
    }
}
#pragma mark - 懒加载
- (NSURLSession *)session
{
    if (_session == nil)
    {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"XBNetHandle"];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue new]];
    }
    return _session;
}

@end

