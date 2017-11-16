//
//  GCDTimer.h
//  NGCDObject
//
//  Created by Nero on 2017/11/16.
//  Copyright © 2017年 creatingEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDTimer : NSObject

@property (strong, readonly, nonatomic) dispatch_source_t timer;

//默认开启一条全局线程（非主线程）
- (instancetype)init;

- (instancetype)initInQueue:(dispatch_queue_t )queue;
/**
 使用dispatch_source_t的时候，必须在控制器或者其他持有使用的类中，强引用这个对象，也就是是这个对象成为类的一个属性
 */

- (void)handleWithTimer:(dispatch_block_t)block timeInterval:(float)secs;

- (void)start;

- (void)suspend;

- (void)destroy;
@end
