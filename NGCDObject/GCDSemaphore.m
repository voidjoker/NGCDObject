//
//  GCDSemaphore.m
//  NGCDObject
//
//  Created by Nero on 2017/11/16.
//  Copyright © 2017年 creatingEV. All rights reserved.
//

#import "GCDSemaphore.h"

@interface GCDSemaphore ()

@property (strong, readwrite, nonatomic) dispatch_semaphore_t semaphore;

@end

@implementation GCDSemaphore

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.semaphore = dispatch_semaphore_create(0);
    }
    return self;
}

- (instancetype)initWithValue:(long)value {
    self = [super init];
    if (self) {
        self.semaphore = dispatch_semaphore_create(value);
    }
    return self;
}

- (void)signal{
    dispatch_semaphore_signal(self.semaphore);
}
- (void)wait{
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}
- (void)waitDelay:(int64_t)delay{
    dispatch_semaphore_wait(self.semaphore, delay);
}
@end
