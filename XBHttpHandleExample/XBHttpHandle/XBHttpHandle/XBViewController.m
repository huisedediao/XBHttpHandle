//
//  XBViewController.m
//  XBHttpHandle
//
//  Created by chuango on 16/10/26.
//  Copyright © 2016年 chuango. All rights reserved.
//

#import "XBViewController.h"
#import "XBHttpHandle.h"
#define downUrlStr @"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.0.2.dmg"

@interface XBViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
- (IBAction)start:(id)sender;
- (IBAction)stop:(id)sender;


@end

@implementation XBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self downloadTest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)dealloc
{
    NSLog(@"----->dealloc");
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

- (IBAction)start:(id)sender {
        [XBHttpHandle startUncompleteTask];
}

- (IBAction)stop:(id)sender {
    [XBHttpHandle saveUncompleteTask];
}
@end
