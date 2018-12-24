//
//  XBNetHandle.h
//  XBHttpHandle
//
//  Created by xxb on 2017/8/1.
//  Copyright © 2017年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XBNetworkingPublic.h"
#import "XBDownloadTask.h"

///服务器返回数据异常的错误码
#define kResponseErrorCode (1008611)

@interface XBNetHandle : NSObject

@property (nonatomic,strong) NSURLSession *session;

+ (instancetype)shared;

+ (void)getRequestWithUrlStr:(NSString *)urlStr successBlock:(XBRequestSuccessBlock)successBlock failureBlock:(XBFailureBlock)failureBlock;
+ (void)postRequestWithUrlStr:(NSString *)urlStr params:(NSDictionary *)params successBlock:(XBRequestSuccessBlock)successBlock failureBlock:(XBFailureBlock)failureBlock;

#pragma mark - 下载方法
/////注意，这里不可以直接调用，需要下载文件时，使用XBDownloadManager下载
+ (void)downFileWith:(XBDownloadTask *)xbTask;
+ (void)stop:(XBDownloadTask *)xbTask;
@end
