//
//  GCDTimer.m
//  NGCDObject
//
//  Created by Nero on 2017/11/16.
//  Copyright © 2017年 creatingEV. All rights reserved.
//

#import "GCDTimer.h"

@interface GCDTimer ()

@property (strong, readwrite, nonatomic) dispatch_source_t timer;

@end

@implementation GCDTimer

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    }
    return self;
}

- (instancetype)initInQueue:(dispatch_queue_t )queue{

    self = [super init];
    if (self) {
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    }
    return self;
}


- (void)handleWithTimer:(dispatch_block_t)block timeInterval:(float)secs{
    dispatch_source_set_timer(self.timer, dispatch_time(DISPATCH_TIME_NOW, 0), secs * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.timer, block);
    dispatch_resume(self.timer);
}

- (void)start{
    dispatch_resume(self.timer);
}

- (void)suspend{
    dispatch_suspend(self.timer);
}

- (void)destroy{
    dispatch_source_cancel(self.timer);
}
@end
