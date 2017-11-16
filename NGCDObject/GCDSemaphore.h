//
//  GCDSemaphore.h
//  NGCDObject
//
//  Created by Nero on 2017/11/16.
//  Copyright © 2017年 creatingEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDSemaphore : NSObject

@property (strong, readonly, nonatomic) dispatch_semaphore_t semaphore;

- (instancetype)init;

- (instancetype)initWithValue:(long)value;

- (void)signal;

- (void)wait;

- (void)waitDelay:(int64_t)delay;

@end
