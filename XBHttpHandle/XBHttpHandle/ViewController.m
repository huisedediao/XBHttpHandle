//
//  ViewController.m
//  XBHttpHandle
//
//  Created by xxb on 2017/8/1.
//  Copyright © 2017年 xxb. All rights reserved.
//

#import "ViewController.h"
#import "XBDownloadManager.h"
#import "XBTableViewCell.h"
#import "XBNetHandleConfig.h"

#define downUrlStr @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.0.2.dmg"

@interface ViewController ()

@end

@implementation ViewController
- (IBAction)reload:(id)sender {
    [self.tableView reloadData];
}

- (IBAction)addTask:(UIBarButtonItem *)sender
{
    XBDownloadTask *task = [XBDownloadTask new];
    task.str_urlStr = downUrlStr;
    task.str_savePath = [NSString stringWithFormat:@"/Documents/qq%zd.dmg",[XBDownloadManager shared].taskList.count];
    [[XBDownloadManager shared] addTask:task];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.tableView registerClass:[XBTableViewCell class] forCellReuseIdentifier:@"cell"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView:) name:kNotice_downloadTasklistChanged object:nil];
}

- (void)reloadTableView:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)   return [XBDownloadManager shared].completedTaskList.count;
    else                return [XBDownloadManager shared].unCompletedTaskList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    XBDownloadTask *task = nil;
    if (indexPath.section == 0)
    {
        task = [XBDownloadManager shared].completedTaskList[indexPath.row];
        cell.task = nil;
        cell.textLabel.text = task.str_fileName;
    }
    else
    {
        task = [XBDownloadManager shared].unCompletedTaskList[indexPath.row];
        cell.task = task;
    }
    
    return cell;
}

@end



