//
//  XBNetModel.h
//  XBHttpHandle
//
//  Created by xxb on 2017/8/2.
//  Copyright © 2017年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XBDownloadCompleteObj : NSObject
@property (nonatomic,strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic,strong) NSURL *location;
@end





@interface XBDownloadFailureObj : NSObject
@property (nonatomic,strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic,strong) NSError *error;
@end



@interface XBDownloadProgressObj : NSObject
@property (nonatomic,strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic,assign) int64_t int_bytesWritten;
@property (nonatomic,assign) int64_t int_totalBytesWritten;
@property (nonatomic,assign) int64_t int_totalBytesExpectedToWrite;
@end


