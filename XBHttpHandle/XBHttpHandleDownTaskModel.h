//
//  XBHttpHandleDownTaskModel.h
//  XBHttpHandle
//
//  Created by chuango on 16/10/26.
//  Copyright © 2016年 chuango. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XBDownloadTask.h"

@class XBHttpHandleDownTaskModel;

typedef void (^DownloadProgressBlock)(float progress);
typedef void (^DownloadCompleteBlock)(void);
typedef void (^RequestSuccessBlock) (id data);
typedef void (^RequestFailureBlock) (NSError *error);

typedef void (^DownloadProgressBlockWithTask)(XBHttpHandleDownTaskModel *model,float progress,int64_t totalBytesWritten,int64_t totalBytesExpectedToWrite);
typedef void (^DownloadCompleteBlockWithTask)(XBHttpHandleDownTaskModel *model);


@interface XBHttpHandleDownTaskModel : NSObject

@property (nonatomic,strong) XBDownloadTask *xbTask;
@property (nonatomic,strong) NSURLSessionDownloadTask *downTask;
@property (nonatomic,copy) DownloadProgressBlock progressBlock;
@property (nonatomic,copy) DownloadCompleteBlock completeBlock;
@property (nonatomic,copy) DownloadProgressBlockWithTask progressBlockWithTask;
@property (nonatomic,copy) DownloadCompleteBlockWithTask completeBlockWithTask;
@property (nonatomic,copy) RequestFailureBlock failureBlock;
@property (nonatomic,copy) NSString *savePath;
@property (nonatomic,assign) BOOL isStopping;
@end
