//
//  XBDownloadTask.h
//  XBHttpHandle
//
//  Created by xxb on 2017/8/1.
//  Copyright © 2017年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XBNetworkingPublic.h"


@interface XBDownloadTask : NSObject <NSCoding>
{
    NSString *_str_savePath;
}
/// 下载地址
@property (nonatomic,copy) NSString *str_urlStr;
/// 保存路径(只需传沙盒之后的路径)
@property (nonatomic,copy) NSString *str_savePath;
/// 缓存路径
@property (nonatomic,copy,readonly) NSString *str_savePath_temp;
/// 名称
@property (nonatomic,copy,readonly) NSString *str_fileName;
/// URLSession的下载任务
@property (nonatomic,strong) NSURLSessionDownloadTask *downloadTask;
/// 进度
@property (nonatomic,assign,readonly) double f_progress;
/// 已写入的大小（转换成KB,MB,GB）
@property (nonatomic,copy,readonly) NSString *str_totalWritten;
/// 总的大小（转换成KB,MB,GB）
@property (nonatomic,copy,readonly) NSString *str_totalExpectedToWrite;
///是否完成
@property (nonatomic,assign) BOOL b_isCompleted;
///是否暂停
@property (nonatomic,assign) BOOL b_isPause;
/// 进度回调
@property (nonatomic,copy) XBProgressBlock bl_progressBlock;
/// 完成回调
@property (nonatomic,copy) XBCompleteBlock bl_completeBlock;
/// 错误回调
@property (nonatomic,copy) XBFailureBlock bl_failureBlock;

/// 本次写入的量
@property (nonatomic,assign) int64_t int_bytesWritten;

/// 已经下载的量
@property (nonatomic,assign) int64_t int_totalBytesWritten;

/// 总共要下载的量
@property (nonatomic,assign) int64_t int_totalBytesExpectedToWrite;

@end
