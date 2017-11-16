//
//  GCDQueue.h
//  NGCDObject
//
//  Created by Nero on 2017/11/16.
//  Copyright © 2017年 creatingEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDQueue : NSObject

@property (strong, readonly, nonatomic) dispatch_queue_t dispatchQueue;

#pragma mark - queue
+ (dispatch_queue_t)mainQueue;
+ (dispatch_queue_t)globalQueue;
+ (dispatch_queue_t)highPriorityGlobalQueue;
+ (dispatch_queue_t)lowPriorityGlobalQueue;
+ (dispatch_queue_t)backgroundPriorityGlobalQueue;

#pragma mark - handle operation in GCD queue
+ (void)handleInMainQueue:(dispatch_block_t)block;
+ (void)handleInGlobalQueue:(dispatch_block_t)block;
+ (void)handleBlock:(dispatch_block_t)block inQueue:(dispatch_queue_t)queue;

#pragma mark - handleBlock in queue after Delay
+ (void)handleBlock:(dispatch_block_t)block inQueue:(dispatch_queue_t)queue afterDelaySecs:(NSTimeInterval)sec;

#pragma mark - init
+ (dispatch_queue_t)serialQueue;
+ (dispatch_queue_t)serialQueueWithAttach:(NSString *)attach;
+ (dispatch_queue_t)concurrentQueue;
+ (dispatch_queue_t)concurrentQueueWithAttach:(NSString *)attach;

#pragma mark - sync handle block
+ (void)syncHandleBlockinMainQueue:(dispatch_block_t)block;
+ (void)syncHandleBlockinGlobalQueue:(dispatch_block_t)block ;
+ (void)syncHandleBlock:(dispatch_block_t)block inQueue:(dispatch_queue_t)queue;

#pragma mark - barrier handle
+ (void)barrierHandle:(dispatch_block_t)block inQueue:(dispatch_queue_t)queue;
+ (void)barrierAndAwaitHandle:(dispatch_block_t)block inQueue:(dispatch_queue_t)queue;

#pragma mark - waiting
+ (void)waitingBlock:(dispatch_block_t)block;

#pragma mark - 暂停恢复执行操作
+ (void)suspend:(dispatch_object_t)object;
+ (void)resume:(dispatch_object_t)object;

#pragma mark - 异步取消执行操作
+ (void)cancleBlock:(dispatch_block_t )block ;
+ (void)cancleSource:(dispatch_source_t )source;

#pragma mark - dispatch_get_specific获取指定标识队列，为队列添加指定标识
+ (void)setKey:(const void *)key context:(void *)context forQueue:(dispatch_queue_t)queue;
+ (void *)getContextForQueueKey:(const void *)key;

@end
