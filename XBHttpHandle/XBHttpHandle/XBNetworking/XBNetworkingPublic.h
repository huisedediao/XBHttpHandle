//
//  XBNetworkingPublic.h
//  XBHttpHandle
//
//  Created by xxb on 2017/8/1.
//  Copyright © 2017年 xxb. All rights reserved.
//

#ifndef XBNetworkingPublic_h
#define XBNetworkingPublic_h

//头文件----------------------------------------------------------------
#import "XBNetModel.h"



//block----------------------------------------------------------------
@class XBDownloadTask;

typedef void (^XBProgressBlock)(XBDownloadTask *xbTask);
typedef void (^XBDownloadBlock)(XBDownloadTask *xbTask);
typedef void (^XBFailureBlock)(NSError *error);
typedef void (^XBCompleteBlock)(XBDownloadTask *xbTask);
typedef void(^XBRequestSuccessBlock)(NSData *data);



//通知----------------------------------------------------------------
#define kNotice_progress                    @"Notice_progress"
#define kNotice_complete                    @"Notice_complete"
#define kNotice_failure                     @"Notice_failure"
#define kNotice_downloadTasklistChanged     @"Notice_downloadTasklistChanged"





#endif /* XBNetworkingPublic_h */
