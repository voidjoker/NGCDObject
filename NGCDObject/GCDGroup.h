//
//  GCDGroup.h
//  NGCDObject
//
//  Created by Nero on 2017/11/16.
//  Copyright © 2017年 creatingEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDGroup : NSObject

@property (strong, readonly, nonatomic) dispatch_group_t dispatchGroup;

- (instancetype)init;

- (instancetype)initWithDispatchGroup:(dispatch_group_t)dispatchGroup;

//dispatch_group_async等价于dispatch_group_enter() 和 dispatch_group_leave()的组合。

/**
 表示接下来的执行操作将加入到group中执行，直到运行到leaveGroup的时候，离开group
 */
- (void)enterGroup;

/**
 表示接下来的执行操作将不会再添加到group中执行
 */
- (void)leaveGroup;

/**
 将等待之前的操作全部执行结束后草会继续执行接下来的操作
 */
- (void)wait;


/**
 将等待一定时间，规定等待时间到后，才继续执行接下来的操作
 @param delay 等待时长
 */
- (void)wait:(float)delay;


@end
