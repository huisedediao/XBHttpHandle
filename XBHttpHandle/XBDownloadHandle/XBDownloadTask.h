//
//  XBDownloadTask.h
//  XBHttpHandle
//
//  Created by xxb on 2016/12/26.
//  Copyright © 2016年 chuango. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XBDownloadTask : NSObject

/** 进度 */
@property (nonatomic,assign) double progress;

/** 已完成 */
@property (nonatomic,assign) int64_t totalBytesWritten;
/** 已完成的大小filesize */
@property (nonatomic,copy) NSString *fs_downloaded;

/** 总共要接受的数据 */
@property (nonatomic,assign) int64_t totalBytesExpectedToWrite;
/** 总大小 */
@property (nonatomic,copy) NSString *fs_total;

/** 保存的位置 */
@property (nonatomic,copy) NSString *savePath;

/** 下载地址 */
@property (nonatomic,copy) NSString *urlStr;

/** 是否已经完成 */
@property (nonatomic,assign) BOOL isComplete;

/** 是否正在下载 */
@property (nonatomic,assign) BOOL isDownloading;

@end
