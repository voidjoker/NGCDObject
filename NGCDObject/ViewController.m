//
//  ViewController.m
//  NGCDObject
//
//  Created by Nero on 2017/11/16.
//  Copyright © 2017年 creatingEV. All rights reserved.
//

#import "ViewController.h"
#import "NGCD.h"

@interface ViewController ()
@property (nonatomic, strong) GCDTimer *timer ;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.timer = [[GCDTimer alloc]init];
    [self.timer handleWithTimer:^{
        NSLog(@"123");
    } timeInterval:1.0];
    
}

///-*-/
//dispatch_set_target_queue
- (void)dispatchSetTargetQueueDemo {
    //创建自定义串行队列
    dispatch_queue_t serialQueue = dispatch_queue_create("com.starming.gcddemo.serialqueue", DISPATCH_QUEUE_SERIAL);
    //创建自定义并行队列
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.starming.gcddemo.secondqueue", DISPATCH_QUEUE_CONCURRENT);
    //队列默认是串行的，如果设置改参数为NULL会按串行处理，只能执行一个单独的block，队列也可以是并行的，同一时间执行多个block
    
    //设置队列的优先级
    dispatch_queue_attr_t queue_attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, -1); //设置（定义）一个优先级
    dispatch_queue_t attrQueue = dispatch_queue_create("com.starming.gcddemo.qosqueue", queue_attr); //创建一个优先级为自己创建的优先级attr的队列
    
    dispatch_queue_t queue = dispatch_queue_create("com.starming.gcddemo.settargetqueue",NULL); //需要设置优先级的queue
    dispatch_queue_t referQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0); //参考优先级
    dispatch_set_target_queue(queue, referQueue); //设置queue和referQueue的优先级一样
    
    [self dispatchSetTargetQueue];
    
}
///-*-/
//dispatch_set_target_queue：可以设置优先级，也可以设置队列层级体系，比如让多个串行和并行队列在统一一个串行队列里串行执行，如下:
- (void)dispatchSetTargetQueue{
    dispatch_queue_t serialQueue = dispatch_queue_create("com.starming.gcddemo.serialqueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t firstQueue = dispatch_queue_create("com.starming.gcddemo.firstqueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t secondQueue = dispatch_queue_create("com.starming.gcddemo.secondqueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_set_target_queue(firstQueue, serialQueue);
    dispatch_set_target_queue(secondQueue, serialQueue);
    
    dispatch_async(firstQueue, ^{
        NSLog(@"1");
        [NSThread sleepForTimeInterval:3.f];
    });
    dispatch_async(secondQueue, ^{
        NSLog(@"2");
        [NSThread sleepForTimeInterval:2.f];
    });
    dispatch_async(secondQueue, ^{
        NSLog(@"3");
        [NSThread sleepForTimeInterval:1.f];
    });
    
}

//dispatch_barrier_async
//Dispatch Barrier确保提交的闭包是指定队列中在特定时段唯一在执行的一个。在所有先于Dispatch Barrier的任务都完成的情况下这个闭包才开始执行。轮到这个闭包时barrier会执行这个闭包并且确保队列在此过程不会执行其它任务。闭包完成后队列恢复。需要注意dispatch_barrier_async只在自己创建的队列上有这种作用，在全局并发队列和串行队列上，效果和dispatch_sync一样
- (void)dispatchBarrierAsyncDemo {
    //防止文件读写冲突，可以创建一个串行队列，操作都在这个队列中进行，没有更新数据读用并行，写用串行。
    dispatch_queue_t dataQueue = dispatch_queue_create("com.starming.gcddemo.dataqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(dataQueue, ^{
        [NSThread sleepForTimeInterval:2.f];
        NSLog(@"read data 1");
    });
    dispatch_async(dataQueue, ^{
        NSLog(@"read data 2");
    });
    //等待前面的都完成，在执行barrier后面的
    dispatch_barrier_async(dataQueue, ^{
        NSLog(@"write data 1");
        [NSThread sleepForTimeInterval:1];
    });
    dispatch_async(dataQueue, ^{
        [NSThread sleepForTimeInterval:1.f];
        NSLog(@"read data 3");
    });
    dispatch_async(dataQueue, ^{
        NSLog(@"read data 4");
    });
}
///-*-/
//dispatch_apply
- (void)dispatchApplyDemo {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.starming.gcddemo.concurrentqueue", DISPATCH_QUEUE_CONCURRENT);
    //因为可以并行执行，所以使用dispatch_apply执行无序循环♻️操作可以运行的更快
    dispatch_apply(10, concurrentQueue, ^(size_t i) {
        NSLog(@"%zu",i);
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
    NSLog(@"The end"); //这里有个需要注意的是，dispatch_apply这个是会阻塞主线程的。这个log打印会在dispatch_apply都结束后才开始执行，但是使用dispatch_async包一下就不会阻塞了。
}

//dispatch_apply。dispatch_apply能避免线程爆炸，因为GCD会管理并发
- (void)dispatchDealWiththreadWithMaybeExplode:(BOOL)explode {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.starming.gcddemo.concurrentqueue",DISPATCH_QUEUE_CONCURRENT);
    if (explode) {
        //有问题的情况，可能会死锁
        for (int i = 0; i < 999 ; i++) {
            dispatch_async(concurrentQueue, ^{
                NSLog(@"wrong %d",i);
                //do something hard
            });
        }
    } else {
        //会优化很多，能够利用GCD管理
        dispatch_apply(999, concurrentQueue, ^(size_t i){
            NSLog(@"correct %zu",i);
            //do something hard
        });
    }
}

//create dispatch block
- (void)dispatchCreateBlockDemo {
    //normal way
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.starming.gcddemo.concurrentqueue",DISPATCH_QUEUE_CONCURRENT);
    dispatch_block_t block = dispatch_block_create(0, ^{
        NSLog(@"run block");
    });
    
    dispatch_async(concurrentQueue, block);
    
    //QOS way
    dispatch_block_t qosBlock = dispatch_block_create_with_qos_class(0, QOS_CLASS_USER_INITIATED, -1, ^{
        NSLog(@"run qos block");
    });
    dispatch_async(concurrentQueue, qosBlock);
}

//dispatch_block_wait。 可以根据dispatch block来设置等待时间，参数DISPATCH_TIME_FOREVER会一直等待block结束
- (void)dispatchBlockWaitDemo {
    dispatch_queue_t serialQueue = dispatch_queue_create("com.starming.gcddemo.serialqueue", DISPATCH_QUEUE_SERIAL);
    dispatch_block_t block = dispatch_block_create(0, ^{
        NSLog(@"star");
        [NSThread sleepForTimeInterval:5.f];
        NSLog(@"end");
    });
    dispatch_async(serialQueue, block);
    //设置DISPATCH_TIME_FOREVER会一直等到前面任务都完成
    dispatch_block_wait(block, DISPATCH_TIME_FOREVER);
    NSLog(@"ok, now can go on");
}

//dispatch_block_notify   可以监视指定dispatch block结束，然后再加入一个block到队列中。三个参数分别为，第一个是需要监视的block，第二个参数是需要提交执行的队列，第三个是待加入到队列中的block
- (void)dispatchBlockNotifyDemo {
    dispatch_queue_t serialQueue = dispatch_queue_create("com.starming.gcddemo.serialqueue", DISPATCH_QUEUE_SERIAL);
    dispatch_block_t firstBlock = dispatch_block_create(0, ^{
        NSLog(@"first block start");
        [NSThread sleepForTimeInterval:2.f];
        NSLog(@"first block end");
    });
    dispatch_async(serialQueue, firstBlock);
    dispatch_block_t secondBlock = dispatch_block_create(0, ^{
        NSLog(@"second block run");
    });
    //first block执行完才在serial queue中执行second block
    dispatch_block_notify(firstBlock, serialQueue, secondBlock);
}

//dispatch_block_cancel(iOS8+)
- (void)dispatchBlockCancelDemo {
    dispatch_queue_t serialQueue = dispatch_queue_create("com.starming.gcddemo.serialqueue", DISPATCH_QUEUE_SERIAL);
    dispatch_block_t firstBlock = dispatch_block_create(0, ^{
        NSLog(@"first block start");
        [NSThread sleepForTimeInterval:2.f];
        NSLog(@"first block end");
    });
    dispatch_block_t secondBlock = dispatch_block_create(0, ^{
        NSLog(@"second block run");
    });
    dispatch_async(serialQueue, firstBlock);
    dispatch_async(serialQueue, secondBlock);
    //取消secondBlock
    dispatch_block_cancel(secondBlock);
}

//dispatch_group_wait
- (void)dispatchGroupWaitDemo {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.starming.gcddemo.concurrentqueue",DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    //在group中添加队列的block
    dispatch_group_async(group, concurrentQueue, ^{
        [NSThread sleepForTimeInterval:2.f];
        NSLog(@"1");
    });
    dispatch_group_async(group, concurrentQueue, ^{
        NSLog(@"2");
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"can continue");
}

//dispatch_group_notify
- (void)dispatchGroupNotifyDemo {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("com.starming.gcddemo.concurrentqueue",DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, concurrentQueue, ^{
        NSLog(@"1");
    });
    dispatch_group_async(group, concurrentQueue, ^{
        NSLog(@"2");
    });
    //dispatch_group_async等价于dispatch_group_enter() 和 dispatch_group_leave()的组合。所以上面三行代码等价于下面三行代码：
    //    dispatch_group_enter(group);
    //    NSLog(@"2");
    //    dispatch_group_leave(group);
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"end");
    });
    NSLog(@"can continue");
}

//dispatch semaphore。 另外一种保证同步的方法。使用dispatch_semaphore_signal加1dispatch_semaphore_wait减1，为0时等待的设置方式来达到线程同步的目的和同步锁一样能够解决资源抢占的问题。
- (void)dispatchSemaphoreDemo {
    //创建semaphore
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"start");
        [NSThread sleepForTimeInterval:1.f];
        NSLog(@"semaphore +1");
        dispatch_semaphore_signal(semaphore); //+1 semaphore
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"continue");
    
    
}

//dispatch source directory demo
//dispatch io读取文件的方式类似于下面的方式，多个线程去读取文件的切片数据，对于大的数据文件这样会比单线程要快很多。
//dispatch_async(queue,^{/*read 0-99 bytes*/});
//dispatch_async(queue,^{/*read 100-199 bytes*/});
//dispatch_async(queue,^{/*read 200-299 bytes*/});

//监视文件夹内文件变化
- (void)dispatchSourceDirectoryDemo {
    NSURL *directoryURL; // assume this is set to a directory
    int const fd = open([[directoryURL path] fileSystemRepresentation], O_EVTONLY);
    if (fd < 0) {
        char buffer[80];
        strerror_r(errno, buffer, sizeof(buffer));
        NSLog(@"Unable to open \"%@\": %s (%d)", [directoryURL path], buffer, errno);
        return;
    }
    //dispatch_source_create：创建dispatch source，创建后会处于挂起状态进行事件接收，需要设置事件处理handler进行事件处理。
    //Dispatch Source用于监听系统的底层对象，比如文件描述符，Mach端口，信号量等。主要处理的事件如下表：
    //DISPATCH_SOURCE_TYPE_VNODE    文件系统变化事件（还有其他种类事件）
    
    /**
      DISPATCH_SOURCE_TYPE_VNODE 指定 Dispatch Source 类型，共有 11 个类型，特定的类型监听特定的事件
      fd 取决于要监听的事件类型，比如如果是监听 Mach 端口相关的事件，那么该参数就是 mach_port_t 类型的 Mach 端口号，如果是监听事件变量数据类型的事件那么该参数就不需要，设置为 0 就可以了
      DISPATCH_VNODE_DELETE 取决于要监听的事件类型，比如如果是监听文件属性更改的事件，那么该参数就标识文件的哪个属性，比如DISPATCH_VNODE_RENAME
      DISPATCH_TARGET_QUEUE_DEFAULT 设置回调函数所在的队列
     */
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fd,
                                                      DISPATCH_VNODE_WRITE | DISPATCH_VNODE_DELETE, DISPATCH_TARGET_QUEUE_DEFAULT);
    //dispatch_source_set_event_handler：设置事件处理handler
    //    当 Dispatch Source 监听到事件时会调用指定的回调函数或闭包，该回调函数或闭包就是 Dispatch Source 的事件处理器。
    //    我们可以使用 dispatch_source_set_event_handler 或 dispatch_source_set_event_handler_f 函数给创建好的 Dispatch Source 设置处理器，前者是设置闭包形式的处理器，后者是设置函数形式的处理器
    
    dispatch_source_set_event_handler(source, ^(){
        //        既然是事件处理器，那么肯定需要获取一些 Dispatch Source 的信息，GCD 提供了三个在处理器中获取 Dispatch Source 相关信息的函数，比如 handle、mask。而且针对不同类型的 Dispatch Source，这三个函数返回数据的值和类型都会不一样
        
        // dispatch_source_get_handle：这个函数用于获取在创建 Dispatch Source 时设置的第二个参数 handle：
        // dispatch_source_get_data：该函数用于获取 Dispatch Source 监听到事件的相关数据
        // dispatch_source_get_mask：该函数用于获取在创建 Dispatch Source 时设置的第三个参数 mask
        unsigned long const data = dispatch_source_get_data(source);
        if (data & DISPATCH_VNODE_WRITE) {
            NSLog(@"The directory changed.");
        }
        if (data & DISPATCH_VNODE_DELETE) {
            NSLog(@"The directory has been deleted.");
        }
    });
    //dispatch_source_set_cancel_handler：事件取消handler，就是在dispatch source释放前做些清理的事。
    //取消处理器就是当 Dispatch Source 被释放时用来处理一些后续事情，比如关闭文件描述符或者释放 Mach 端口等。我们可以使用
    //    dispatch_source_set_cancel_handler 函数或者 dispatch_source_set_cancel_handler_f 函数给 Dispatch Source 注册取消处理器
    
    dispatch_source_set_cancel_handler(source, ^(){
        close(fd);
    });
    //在事件源传到你的事件处理前需要调用dispatch_resume()这个方法
    dispatch_resume(source);
    //还要注意需要用DISPATCH_VNODE_DELETE 去检查监视的文件或文件夹是否被删除，如果删除了就停止监听
}

//dispatch source timer demo
- (void)dispatchSourceTimerDemo {
    //NSTimer在主线程的runloop里会在runloop切换其它模式时停止，这时就需要手动在子线程开启一个模式为NSRunLoopCommonModes的runloop，如果不想开启一个新的runloop可以用不跟runloop关联的dispatch source timer
    
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0, 0, DISPATCH_TARGET_QUEUE_DEFAULT);
    dispatch_source_set_event_handler(source, ^(){
        NSLog(@"Time flies.");
    });
    
    //    source：待配置的定时器类型的 Dispatch Source
    //    start：控制定时器第一次触发的时刻。参数类型是
    //    dispatch_time_t，这是一个 opaque 类型，我们不能直接操作它。我们得需要 dispatch_time 和 dispatch_walltime 函数来创建它们。另外，常量 DISPATCH_TIME_NOW 和                    DISPATCH_TIME_FOREVER 通常很有用
    //    interval：触发间隔
    //    leeway：定时器进度，单位纳秒；如果设为 0，系统只是最大程度满足精度需求。精度越高功耗越大
    dispatch_source_set_timer(source, DISPATCH_TIME_NOW, 5ull * NSEC_PER_SEC,100ull * NSEC_PER_MSEC);
    self.source = source; // 将定时器写成属性，是因为内存管理的原因，使用了dispatch_source_create方法，这种方法GCD是不会帮你管理内存的。*只要是使用dispatch_source_t都需要写成属性，造成强引用
    dispatch_resume(source);
}

- (void)writeDispatchSource {
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [filePath stringByAppendingString:@"/test.txt"];
    int fd = open([fileName UTF8String], O_WRONLY | O_CREAT | O_TRUNC,
                  (S_IRUSR | S_IWUSR | S_ISUID | S_ISGID));
    NSLog(@"Write fd:%d",fd);
    if (fd == -1)
        return ;
    fcntl(fd, F_SETFL); // Block during the write.
    
    dispatch_source_t writeSource = nil;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    writeSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_WRITE,fd, 0, queue);
    _myWriteSource = writeSource;
    dispatch_source_set_event_handler(_myWriteSource, ^{
        size_t bufferSize = 100;
        void *buffer = malloc(bufferSize);
        
        static NSString *content = @"Write Data Action: ";
        content = [content stringByAppendingString:@"=New info="];
        
        NSString *writeContent = [content stringByAppendingString:@"\n"];
        void *string = [writeContent UTF8String];
        size_t actual = strlen(string);
        memcpy(buffer, string, actual);
        
        write(fd, buffer, actual);
        NSLog(@"Write to file Finished");
        
        free(buffer);
        // Cancel and release the dispatch source when done.
        //        dispatch_source_cancel(writeSource);
        dispatch_suspend(_myWriteSource);  //不能省,否则只要文件可写，写操作会一直进行，直到磁盘满，本例中，只要超过buffer容量就会崩溃
        //        close(fd);   //会崩溃
    });
    
    dispatch_source_set_cancel_handler(_myWriteSource, ^{
        NSLog(@"Write to file Canceled");
        close(fd);
    });
    
    if (!_myWriteSource) {
        close(fd);
        return;
    }
    dispatch_resume(_myWriteSource); //必须有这句话都啧不会开始执行
}

- (void)readDataDispatchSource {
    if (_myReadSource) {
        dispatch_source_cancel(_myReadSource);
    }
    
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [filePath stringByAppendingString:@"/test.txt"];
    // Prepare the file for reading.
    int fd = open([fileName UTF8String], O_RDONLY);
    NSLog(@"read fd:%d",fd);
    if (fd == -1)
        return ;
    fcntl(fd, F_SETFL, O_NONBLOCK);  // Avoid blocking the read operation
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t readSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, fd, 0, queue);
    if (!readSource) {
        close(fd);
        return ;
    }
    // Install the event handler
    //只要文件写入了新内容，就会自动读入新内容
    dispatch_source_set_event_handler(readSource, ^{
        long estimated = dispatch_source_get_data(readSource);
        NSLog(@"Read From File, estimated length: %ld",estimated);
        if (estimated < 0) {
            NSLog(@"Read Error:");
            dispatch_source_cancel(readSource);  //如果文件发生了截短，事件处理器会一直不停地重复
        }
        
        // Read the data into a text buffer.
        char *buffer = (char *)malloc(estimated);
        if (buffer) {
            ssize_t actual = read(fd, buffer, (estimated));
            NSLog(@"Read From File, actual length: %ld",actual);
            NSLog(@"Readed Data: \n%s",buffer);
            //            Boolean done = MyProcessFileData(buffer, actual);  // Process the data.
            
            // Release the buffer when done.
            free(buffer);
            
            // If there is no more data, cancel the source.
            //            if (done)
            //                dispatch_source_cancel(readSource);
        }
    });
    
    // Install the cancellation handler
    dispatch_source_set_cancel_handler(readSource, ^{
        NSLog(@"Read from file Canceled");
        close(fd);
    });
    
    // 开始执行读取操作
    dispatch_resume(readSource);
    _myReadSource = readSource; //can be omitted。必须强饮用
}



/**
 这里简单介绍下iOS中常用的各种锁和他们的性能。
 
 NSRecursiveLock：递归锁，可以在一个线程中反复获取锁不会造成死锁，这个过程会记录获取锁和释放锁的次数来达到何时释放的作用。
 NSDistributedLock：分布锁，基于文件方式的锁机制，可以跨进程访问。
 NSConditionLock：条件锁，用户定义条件，确保一个线程可以获取满足一定条件的锁。因为线程间竞争会涉及到条件锁检测，系统调用上下切换频繁导致耗时是几个锁里最长的。
 OSSpinLock：自旋锁，不进入内核，减少上下文切换，性能最高，但抢占多时会占用较多cpu，好点多，这时使用pthread_mutex较好。
 pthread_mutex_t：同步锁基于C语言，底层api性能高，使用方法和其它的类似。
 @synchronized：更加简单。
 
 */
//当前串行队列里面同步执行当前串行队列就会死锁，解决的方法就是将同步的串行队列放到另外一个线程就能够解决。
//Dead Lock case 1

- (void)deadLockCase1 {
    NSLog(@"1");
    //主队列的同步线程，按照FIFO的原则（先入先出），2排在3后面会等3执行完，但因为同步线程，3又要等2执行完，相互等待成为死锁。
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"2");
    });
    NSLog(@"3");
}

//Dead Lock case 2
- (void)deadLockCase2 {
    NSLog(@"1");
    //3会等2，因为2在全局并行队列里，不需要等待3，这样2执行完回到主队列，3就开始执行
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"2");
    });
    NSLog(@"3");
}

//Dead Lock case 3
- (void)deadLockCase3 {
    dispatch_queue_t serialQueue = dispatch_queue_create("com.starming.gcddemo.serialqueue", DISPATCH_QUEUE_SERIAL);
    NSLog(@"1");
    dispatch_async(serialQueue, ^{
        NSLog(@"2");
        //串行队列里面同步一个串行队列就会死锁
        dispatch_sync(serialQueue, ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
}

//Dead Lock case 4
- (void)deadLockCase4 {
    NSLog(@"1");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"2");
        //将同步的串行队列放到另外一个线程就能够解决
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
}

//Dead Lock case 5
- (void)deadLockCase5 {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"1");
        //回到主线程发现死循环后面就没法执行了
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"2");
        });
        NSLog(@"3");
    });
    NSLog(@"4");
    //死循环
    while (1) {
        //
    }
}
@end
