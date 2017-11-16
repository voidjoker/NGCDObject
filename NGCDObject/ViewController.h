//
//  ViewController.h
//  NGCDObject
//
//  Created by Nero on 2017/11/16.
//  Copyright © 2017年 creatingEV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic,strong) dispatch_source_t myWriteSource;
@property (nonatomic,strong) dispatch_source_t myReadSource;
@property (nonatomic,strong) dispatch_source_t source;

@end

