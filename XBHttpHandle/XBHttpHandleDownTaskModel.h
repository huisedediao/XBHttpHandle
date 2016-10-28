//
//  XBHttpHandleDownTaskModel.h
//  XBHttpHandle
//
//  Created by chuango on 16/10/26.
//  Copyright © 2016年 chuango. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DownloadProgressBlock)(float progress);
typedef void (^DownloadCompleteBlock)(void);
typedef void (^RequestSuccessBlock) (NSData *data);
typedef void (^RequestFailureBlock) (NSError *error);


@interface XBHttpHandleDownTaskModel : NSObject
@property (nonatomic,strong) NSURLSessionDownloadTask *downTask;
@property (nonatomic,copy) DownloadProgressBlock progressBlock;
@property (nonatomic,copy) DownloadCompleteBlock completeBlcok;
@property (nonatomic,copy) RequestFailureBlock failureBlock;
@property (nonatomic,copy) NSString *savePath;
@property (nonatomic,assign) BOOL isStopping;
@end
