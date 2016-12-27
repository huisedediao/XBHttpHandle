//
//  AppDelegate.m
//  XBHttpHandle
//
//  Created by chuango on 16/10/26.
//  Copyright © 2016年 chuango. All rights reserved.
//

#import "AppDelegate.h"
#import "XBHttpHandle.h"
#import "XBDownloadTaskManager.h"
#import "AvoidCrash.h"

#define downUrlStr @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.0.2.dmg"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AvoidCrash becomeEffective];
    // Override point for customization after application launch.
    NSLog(@"沙盒路径：%@", NSHomeDirectory());
    
    XBDownloadTaskManager *manager=[XBDownloadTaskManager shareManager];
    
    if (manager.taskList.count<1)
    {
        for (int i=0; i<10; i++)
        {
            XBDownloadTask *task=[XBDownloadTask new];
            
            task.progress=0.0;
            task.savePath=[NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/qq%d.dmg",i]];
            task.urlStr=downUrlStr;
            task.totalBytesWritten=0;
            task.totalBytesExpectedToWrite=0;
            
            [manager.taskList addObject:task];
        }
    }
    

    
    
    
    
    
    
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.

}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //[[XBDownloadTaskManager shareManager] stopTaskAndstoreTaskList];
}
/* 后台下载任务完成后，程序被唤醒，该方法将被调用 */
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
//    NSLog(@”Application Delegate: Background download task finished”);
    
    // 设置回调的完成代码块
//    self.backgroundURLSessionCompletionHandler = completionHandler;
}



- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    NSLog(@"重新进入前台，沙盒路径：%@", NSHomeDirectory());
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[XBDownloadTaskManager shareManager] stopTaskAndstoreTaskList];
}


@end
