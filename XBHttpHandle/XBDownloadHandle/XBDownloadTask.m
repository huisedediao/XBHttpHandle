//
//  XBDownloadTask.m
//  XBHttpHandle
//
//  Created by xxb on 2016/12/26.
//  Copyright © 2016年 chuango. All rights reserved.
//

#import "XBDownloadTask.h"
#import <objc/message.h>

@interface XBDownloadTask ()<NSCoding>

@end

@implementation XBDownloadTask
- (void)encodeWithCoder:(NSCoder *)encoder{
    //归档存储自定义对象
    unsigned int count = 0;
    //获得指向该类所有属性的指针
    objc_property_t *properties =     class_copyPropertyList([self class], &count);
    for (int i =0; i < count; i ++) {
        //获得
        objc_property_t property = properties[i];        //根据objc_property_t获得其属性的名称--->C语言的字符串
        const char *name = property_getName(property);
        NSString *key = [NSString   stringWithUTF8String:name];
        //      编码每个属性,利用kVC取出每个属性对应的数值
        [encoder encodeObject:[self valueForKeyPath:key] forKey:key];
    }}

- (instancetype)initWithCoder:(NSCoder *)decoder{
    //归档存储自定义对象
    unsigned int count = 0;
    //获得指向该类所有属性的指针
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i =0; i < count; i ++) {
        objc_property_t property = properties[i];        //根据objc_property_t获得其属性的名称--->C语言的字符串
        const char *name = property_getName(property);
        NSString *key = [NSString stringWithUTF8String:name];        //解码每个属性,利用kVC取出每个属性对应的数值
        [self setValue:[decoder decodeObjectForKey:key] forKeyPath:key];
    }   
    return self;
}
-(NSString *)getFileSizeDescribeWithBytes:(int64_t)bytes
{
    NSString *result=nil;
    //先判断有没有到KB
    double size=bytes * 1.0 / 1024;
    if (size<1)
    {
        result=[NSString stringWithFormat:@"%zd b",self.totalBytesWritten];
    }
    else
    {
        size=size / 1024;
        //判断有没有到MB
        if (size<1)
        {
            result=[NSString stringWithFormat:@"%.2f KB",size * 1024];
        }
        else
        {
            //判断有没有到G
            size=size / 1024;
            if (size<1)
            {
                result=[NSString stringWithFormat:@"%.2f MB",size *1024];
            }
            else
            {
                result=[NSString stringWithFormat:@"%.2f GB",size];
            }
        }
    }
    
    return result;
}
-(NSString *)fs_downloaded
{
    return [self getFileSizeDescribeWithBytes:self.totalBytesWritten];
}
-(NSString *)fs_total
{
    return [self getFileSizeDescribeWithBytes:self.totalBytesExpectedToWrite];
}
@end
