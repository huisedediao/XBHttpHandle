//
//  XBHttpHandle.h
//  XBHttpHandle
//
//  Created by chuango on 16/10/26.
//  Copyright © 2016年 chuango. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XBHttpHandleDownTaskModel.h"
#import <UIKit/UIKit.h>

@interface XBHttpHandle : NSObject


+(instancetype)shareHttpHandle;

/** get请求
 *  参数1：下载的url
 */
+(void)getRequestWithUrlStr:(NSString *)urlStr successBlock:(RequestSuccessBlock)successBlock failureBlock:(RequestFailureBlock)failureBlock;

/** post请求
 *  参数1：下载的url
 *  参数2：参数
 */
+(void)postRequestWithUrlStr:(NSString *)urlStr params:(NSDictionary *)params successBlock:(RequestSuccessBlock)successBlock failureBlock:(RequestFailureBlock)failureBlock;

/** 下载大文件，支持后台下载
 *  参数1：下载的url
 *  参数2：下载完成保存在哪里
 *  注意：必须用真机！！！
 */
+(void)downFileWithUrlStr:(NSString *)urlStr savePath:(NSString *)savePath progressBlock:(DownloadProgressBlock)progressBlock complete:(DownloadCompleteBlock)completeBlock failureBlock:(RequestFailureBlock)failureBlock;

/** 暂停未完成的任务
 *  手动暂停，或者在app被杀死时，在appdelegate的- (void)applicationWillTerminate:(UIApplication *)application 方法里调用
 */
+(void)saveUncompleteTask;

/** 重新开始没有完成的任务，仅限于此次开启app添加的并且未完成的任务
 *  如果是重新打开的app或者已经完成的任务，调此方法不起作用
 */
+(void)startUncompleteTask;

@end
