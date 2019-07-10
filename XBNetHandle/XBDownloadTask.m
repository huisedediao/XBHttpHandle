//
//  XBDownloadTask.m
//  XBHttpHandle
//
//  Created by xxb on 2017/8/1.
//  Copyright © 2017年 xxb. All rights reserved.
//

#import "XBDownloadTask.h"


#define key_str_urlStr @"str_urlStr"
#define key_str_savePath @"_str_savePath"
#define key_b_isCompleted @"b_isCompleted"
#define key_int_totalBytesWritten @"int_totalBytesWritten"
#define key_int_totalBytesExpectedToWrite @"int_totalBytesExpectedToWrite"

@implementation XBDownloadTask

#pragma mark - 生命周期
- (instancetype)init
{
    if (self = [super init])
    {
        _b_isPause = YES;
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        _str_urlStr = [aDecoder decodeObjectForKey:key_str_urlStr];
        _str_savePath = [aDecoder decodeObjectForKey:key_str_savePath];
        _b_isCompleted = [aDecoder decodeBoolForKey:key_b_isCompleted];
        _int_totalBytesWritten = [aDecoder decodeIntegerForKey:key_int_totalBytesWritten];
        _int_totalBytesExpectedToWrite = [aDecoder decodeIntegerForKey:key_int_totalBytesExpectedToWrite];
        _b_isPause = YES;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.str_urlStr forKey:key_str_urlStr];
    [aCoder encodeObject:self.str_savePath forKey:key_str_savePath];
    [aCoder encodeBool:self.b_isCompleted forKey:key_b_isCompleted];
    [aCoder encodeInteger:self.int_totalBytesWritten forKey:key_int_totalBytesWritten];
    [aCoder encodeInteger:self.int_totalBytesExpectedToWrite forKey:key_int_totalBytesExpectedToWrite];
}


#pragma mark - 方法重写
/// 保存路径(只需传沙盒之后的路径)
- (void)setStr_savePath:(NSString *)str_savePath
{
    _str_savePath = str_savePath;
    NSString *savePathWithoutLastComponent = [str_savePath stringByDeletingLastPathComponent];
    if ([[NSFileManager defaultManager] fileExistsAtPath:savePathWithoutLastComponent] == false)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:savePathWithoutLastComponent withIntermediateDirectories:true attributes:nil error:nil];
    }
}
- (NSString *)str_savePath
{
    return [NSHomeDirectory() stringByAppendingString:_str_savePath];
}

/// 缓存路径
- (NSString *)str_savePath_temp
{
    return [self.str_savePath stringByAppendingString:@"XBDownloadTemp"];
}

/// 名称
- (NSString *)str_fileName
{
    return self.str_savePath.lastPathComponent;
}

/// 进度
- (double)f_progress
{
    if (self.int_totalBytesExpectedToWrite != 0)
    {
        return (float)self.int_totalBytesWritten / _int_totalBytesExpectedToWrite;
    }
    else
    {
        return 0;
    }
}

/// 已写入的大小（转换成KB,MB,GB）
- (NSString *)str_totalWritten
{
    return [self getSizeDescribe:self.int_totalBytesWritten];
}

///总的大小（转换成KB,MB,GB）
- (NSString *)str_totalExpectedToWrite
{
    return [self getSizeDescribe:self.int_totalBytesExpectedToWrite];
}

#pragma mark - 其他方法
- (NSString *)getSizeDescribe:(int64_t)bytes
{
    NSString *result = nil;
    
    //先判断有没有到KB
    double size = bytes * 1.0 / 1024;
    if (size < 1)
    {
        result = [NSString stringWithFormat:@"%zd b",bytes];
    }
    else
    {
        size = size / 1024;
        //判断有没有到MB
        if (size < 1)
        {
            result = [NSString stringWithFormat:@"%.2f KB",size * 1024];
        }
        else
        {
            //判断有没有到G
            size = size / 1024;
            if (size < 1)
            {
                result = [NSString stringWithFormat:@"%.2f MB",size * 1024];
            }
            else
            {
                result = [NSString stringWithFormat:@"%.2f GB",size];
            }
        }
    }
    return result;
}
@end
