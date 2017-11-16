//
//  GCDGroup.m
//  NGCDObject
//
//  Created by Nero on 2017/11/16.
//  Copyright © 2017年 creatingEV. All rights reserved.
//

#import "GCDGroup.h"

@interface GCDGroup ()
@property (strong, readwrite, nonatomic) dispatch_group_t dispatchGroup;
@end

@implementation GCDGroup

- (instancetype)init{
    return [self initWithDispatchGroup:dispatch_group_create()];
}

- (instancetype)initWithDispatchGroup:(dispatch_group_t)dispatchGroup {
    self = [super init];
    if(self){
        self.dispatchGroup = dispatch_group_create();
    }
    return self;
}

- (void)enterGroup {
    dispatch_group_enter(self.dispatchGroup);
}

- (void)leaveGroup{
    dispatch_group_leave(self.dispatchGroup);
}

- (void)wait{
    dispatch_group_wait(self.dispatchGroup, DISPATCH_TIME_FOREVER);
}

- (void)wait:(float)delay{
    dispatch_group_wait(self.dispatchGroup, dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC));
}

@end
