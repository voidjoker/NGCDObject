//
//  GCDQueue.m
//  NGCDObject
//
//  Created by Nero on 2017/11/16.
//  Copyright © 2017年 creatingEV. All rights reserved.
//

#import "GCDQueue.h"

@implementation GCDQueue

+ (dispatch_queue_t)mainQueue{
    return dispatch_get_main_queue();
}
+ (dispatch_queue_t)globalQueue{
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}
+ (dispatch_queue_t)highPriorityGlobalQueue{
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
}
+ (dispatch_queue_t)lowPriorityGlobalQueue{
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
}
+ (dispatch_queue_t)backgroundPriorityGlobalQueue{
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
}


#pragma mark - handleBlock in queue
+ (void)handleInMainQueue:(dispatch_block_t)block{
    dispatch_async([GCDQueue mainQueue], block);
}
+ (void)handleInGlobalQueue:(dispatch_block_t)block{
    dispatch_async([GCDQueue globalQueue], block);
}
+ (void)handleBlock:(dispatch_block_t)block inQueue:(dispatch_queue_t)queue{
    dispatch_async(queue, block);
}

#pragma mark - handleBlock in queue after Delay
+ (void)handleBlock:(dispatch_block_t)block inMainQueueAfterDelaySecs:(NSTimeInterval)sec{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), [GCDQueue mainQueue], block);
}
+ (void)handleBlock:(dispatch_block_t)block inGlobalQueueAfterDelaySecs:(NSTimeInterval)sec{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), [GCDQueue globalQueue], block);
}
+ (void)handleBlock:(dispatch_block_t)block inQueue:(dispatch_queue_t)queue afterDelaySecs:(NSTimeInterval)sec{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), queue, block);
}

#pragma mark - init queue
+ (dispatch_queue_t)serialQueue{
    return dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL);
}
+ (dispatch_queue_t)serialQueueWithAttach:(NSString *)attach{
    return dispatch_queue_create([attach UTF8String], DISPATCH_QUEUE_SERIAL);
}
+ (dispatch_queue_t)concurrentQueue{
    return dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT);
}
+ (dispatch_queue_t)concurrentQueueWithAttach:(NSString *)attach{
    return dispatch_queue_create([attach UTF8String], DISPATCH_QUEUE_CONCURRENT);
}
#pragma mark - sync handle block
+ (void)syncHandleBlockinMainQueue:(dispatch_block_t)block  {
    dispatch_sync([GCDQueue mainQueue], block);
}
+ (void)syncHandleBlockinGlobalQueue:(dispatch_block_t)block  {
    dispatch_sync([GCDQueue globalQueue], block);
}
+ (void)syncHandleBlock:(dispatch_block_t)block inQueue:(dispatch_queue_t)queue {
    dispatch_sync(queue, block);
}

#pragma mark - barrier handle
//dispatch_barrier_async是会等待前面提到的任务执行结束，才执行barrier中的任务，执行完barrier中的任务后，才执行后面的任务。

/**
 比如任务顺序：1，2，3，通过barrier加入的任务0，4，5，6
 dispatch_barrier_sync和dispatch_barrier_async的共同点：
 1、都会等待在它前面插入队列的任务（1、2、3）先执行完
 2、都会等待他们自己的任务（0）执行完再执行后面的任务（4、5、6）
 dispatch_barrier_sync和dispatch_barrier_async的不同点：
 在将任务插入到queue的时候，dispatch_barrier_sync需要等待自己的任务（0）结束之后才会继续程序，然后才执行插入到它后面的任务（4、5、6），即使4，5，6任务不在queue队列中而在别的队列中。
 而dispatch_barrier_async将自己的任务（0）插入到queue之后，不会等待自己的任务结束，它会继续把后面的任务（4、5、6）插入到对应的queue中，这样的话，如果4、5、6也是插入到queue中，则4，5，6会在0执行完之后才执行，而如果4，5，6插入了别的队列而不是queue的时候，则4，5，6会先执行，然后才执行0
 所以，dispatch_barrier_async的不等待（异步）特性体现在将任务插入队列的过程，它的等待特性体现在任务真正执行的过程。
 参考URL：http://blog.csdn.net/u013046795/article/details/47057585
 */
+ (void)barrierHandle:(dispatch_block_t)block inQueue:(dispatch_queue_t)queue{
    dispatch_barrier_async(queue, block);
}
+ (void)barrierAndAwaitHandle:(dispatch_block_t)block inQueue:(dispatch_queue_t)queue{
    dispatch_barrier_sync(queue, block);
}

+ (void)waitingBlock:(dispatch_block_t)block{
    dispatch_block_wait(block, DISPATCH_TIME_FOREVER);
}

#pragma mark - 暂停恢复执行操作

/**
 暂停一个线程对象的继续操作。线程对象可以是一个队列，可以是一个dispatch_source_t输入源
 @param object dispatch_object_t可以是dispatch_queue_t，也可以是dispatch_source_t
 */
+ (void)suspend:(dispatch_object_t)object {
    dispatch_suspend(object);
}
+ (void)resume:(dispatch_object_t)object {
    dispatch_resume(object);
}
#pragma mark - 异步取消执行操作
+ (void)cancleBlock:(dispatch_block_t )block {
    dispatch_block_cancel(block);
}
+ (void)cancleSource:(dispatch_source_t )source {
    dispatch_source_cancel(source);
}

#pragma mark - dispatch_get_specific获取指定标识队列，为队列添加指定标识

/**
 1.dispatch_queue_set_specific就是向指定队列里面设置一个标识
 2.dispatch_get_specific 就是在当前所在队列中取出标识
 3.通过判断一个队列中是否有自己设置的标识可以判断是否为想要获取的队列
 
 @param key 标识
 @param context 描述性内容，可以为NULL，可以理解为所添加的key对应的value
 @param queue 要添加的队列
 */
+ (void)setKey:(const void *)key context:(void *)context forQueue:(dispatch_queue_t)queue{
    dispatch_queue_set_specific(queue, key, context, NULL);
}
+ (void *)getContextForQueueKey:(const void *)key{
    return dispatch_get_specific(key);
}




@end
