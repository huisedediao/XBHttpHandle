//
//  ViewController.m
//  XBHttpHandle
//
//  Created by chuango on 16/10/26.
//  Copyright © 2016年 chuango. All rights reserved.
//

#import "ViewController.h"
#import "XBHttpHandle.h"
#import "XBViewController.h"
#import "MJExtension.h"
#import "XBTestModel.h"

#define downUrlStr @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.0.2.dmg"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;

@end

@implementation ViewController
-(void)viewWillAppear:(BOOL)animated
{
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self postTest];

}

-(void)downloadTest
{
    NSString *savePath=[NSHomeDirectory() stringByAppendingString:@"/Documents/qq1.dmg"];
    [XBHttpHandle downFileWithUrlStr:downUrlStr savePath:savePath progressBlock:^(float progress) {
        NSLog(@"%f",progress);
        _label1.text=[NSString stringWithFormat:@"%.2f%%",progress*100];
    } complete:^{
        _label1.text=[NSString stringWithFormat:@"100%%"];
    } failureBlock:^(NSError *error) {
        NSLog(@"failureBlock");
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *savePath1=[NSHomeDirectory() stringByAppendingString:@"/Documents/qq2.dmg"];
        [XBHttpHandle downFileWithUrlStr:downUrlStr savePath:savePath1 progressBlock:^(float progress) {
            NSLog(@"%f",progress);
            _label2.text=[NSString stringWithFormat:@"%.2f%%",progress*100];
        } complete:^{
            _label2.text=[NSString stringWithFormat:@"100%%"];
        } failureBlock:^(NSError *error) {
            NSLog(@"failureBlock");
        }];
    });

}

-(void)postTest
{
    [XBHttpHandle postRequestWithUrlStr:@"http://112.74.195.215:100/VHDWS/wsbbs.asmx/StatisticsInfo" params:@{@"userid":@"1",@"tokenid":@"1",@"typeid":@"1"} successBlcok:^(id data) {
        XBTestModel *model=[XBTestModel mj_objectWithKeyValues:data];
        NSLog(@"\r%@",data);
    } failureBlock:^(NSError *error) {
        
    }];
}

-(void)getTest
{
    [XBHttpHandle getRequestWithUrlStr:@"https://www.baidu.com/img/baidu_jgylogo3.gif" successBlcok:^(NSData *data) {
        UIImage *image=[UIImage imageWithData:data];
        self.imageView.image=image;
    } failureBlock:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    [XBHttpHandle getRequestWithUrlStr:@"https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=1218408038,1340707126&fm=116&gp=0.jpg" successBlcok:^(NSData *data) {
        UIImage *image=[UIImage imageWithData:data];
        self.imageView2.image=image;
    } failureBlock:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (IBAction)btnClick:(id)sender
{
//    [XBHttpHandle startUncompleteTask];
    [self.navigationController pushViewController:[XBViewController new] animated:YES];
}
- (IBAction)stop:(id)sender {
//    [XBHttpHandle saveUncompleteTask];
}
@end
