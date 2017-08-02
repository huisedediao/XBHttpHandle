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

@interface XBNetHandle : NSObject

@property (nonatomic,strong) NSURLSession *session;

+ (instancetype)shared;

+ (void)getRequestWithUrlStr:(NSString *)urlStr successBlock:(XBRequestSuccessBlock)successBlock failureBlock:(XBFailureBlock)failureBlock;
+ (void)postRequestWithUrlStr:(NSString *)urlStr params:(NSDictionary *)params successBlock:(XBRequestSuccessBlock)successBlock failureBlock:(XBFailureBlock)failureBlock;

#pragma mark - 下载方法
+ (void)downFileWith:(XBDownloadTask *)xbTask;
+ (void)stop:(XBDownloadTask *)xbTask;
@end
