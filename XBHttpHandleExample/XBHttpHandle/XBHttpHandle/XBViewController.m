//
//  XBViewController.m
//  XBHttpHandle
//
//  Created by chuango on 16/10/26.
//  Copyright © 2016年 chuango. All rights reserved.
//

#import "XBViewController.h"
#import "XBHttpHandle.h"
#import "XBDefine.h"
#import "XBDownloadTaskManager.h"
#import "XBDownloadingCell.h"
#import "XBTaskCompleteCell.h"

#define downUrlStr @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.0.2.dmg"

#define completeID @"completeCell"
#define downlondingId @"downloadingCell"

@interface XBViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation XBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"XBTaskCompleteCell" bundle:nil] forCellReuseIdentifier:completeID];
    [self.tableView registerNib:[UINib nibWithNibName:@"XBDownloadingCell" bundle:nil] forCellReuseIdentifier:downlondingId];

    [self addNoti];
}
-(void)viewDidDisappear:(BOOL)animated
{
    //[[XBDownloadTaskManager shareManager] stopTaskAndstoreTaskList];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self reloadTable];
}
-(void)reloadTable
{
    [self.tableView reloadData];
}
-(void)addNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadTaskProgressNoti:) name:XBDownloadTaskProgressNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadTaskCompleteNoti:) name:XBDownloadTaskCompleteNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadTaskFailureNoti:) name:XBDownloadTaskFailureNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:UIApplicationWillEnterForegroundNotification object:nil];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)downloadTaskProgressNoti:(NSNotification *)noti
{
    if ([noti.object isKindOfClass:[XBDownloadTask class]])
    {
        XBDownloadTask *task=(XBDownloadTask *)noti.object;
    }
    
}
-(void)downloadTaskCompleteNoti:(NSNotification *)noti
{
    if ([noti.object isKindOfClass:[XBDownloadTask class]])
    {
        XBDownloadTask *task=(XBDownloadTask *)noti.object;
        [self.tableView reloadData];
    }
}
-(void)downloadTaskFailureNoti:(NSNotification *)noti
{
    if ([noti.object isKindOfClass:[NSError class]])
    {
        NSError *error=(NSError *)noti.object;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0)
    {
        return [XBDownloadTaskManager shareManager].completeList.count;
    }
    else
    {
        return [XBDownloadTaskManager shareManager].unCompleteList.count;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0)
    {
        XBTaskCompleteCell *cell=[tableView dequeueReusableCellWithIdentifier:completeID];
        cell.contentView.backgroundColor=RandColor;
        XBDownloadTask *task=[XBDownloadTaskManager shareManager].completeList[indexPath.row];
        cell.task=task;
        return cell;
    }
    else
    {
        XBDownloadingCell *cell=[tableView dequeueReusableCellWithIdentifier:downlondingId];
        cell.contentView.backgroundColor=RandColor;
        XBDownloadTask *task=[XBDownloadTaskManager shareManager].unCompleteList[indexPath.row];
        cell.task=task;
        return cell;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *header=[UILabel new];
    header.backgroundColor=[UIColor whiteColor];
    header.frame=CGRectMake(0, 0, ScreenWidth, 30);
    header.textColor=[UIColor blackColor];
    if (section==0)
    {
        header.text=@"已完成";
    }
    else
    {
        header.text=@"下载中";
    }
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

@end
