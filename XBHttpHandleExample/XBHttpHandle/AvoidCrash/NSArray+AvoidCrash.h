//
//  NSArray+AvoidCrash.h
//  AvoidCrash
//
//  Created by mac on 16/9/21.
//  Copyright © 2016年 chenfanfang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (AvoidCrash)

+ (void)avoidCrashExchangeMethod;

@end


/**
 *  Can avoid crash method
 *
 *  1. NSArray的快速创建方式 NSArray *array = @[@"chenfanfang", @"AvoidCrash"];  //这种创建方式其实调用的是2中的方法
 *  2. +(instancetype)arrayWithObjects:(const id  _Nonnull __unsafe_unretained *)objects count:(NSUInteger)cnt
 *  3. - (id)objectAtIndex:(NSUInteger)index
 *
 */