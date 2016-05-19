//
//  ViewController.m
//  GCDTest
//
//  Created by xiaobing on 15/10/14.
//  Copyright © 2015年 xiaobing. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property(nonatomic , strong) NSString *test;
@end

@implementation ViewController
@dynamic test;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    [self singleTest];
    [self singleTestGroup];
}
#pragma mark - 信号量机制

- (void)singleTest
{
    for (int i = 0; i < 10 ; i++ )
    {
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        NSString *string = [NSString stringWithFormat:@"%@",@(i)];
        dispatch_async(dispatch_queue_create(string.UTF8String, DISPATCH_QUEUE_PRIORITY_DEFAULT ), ^{
            sleep(0.25);
            NSLog(@"%@---->%@",@(i),[NSThread currentThread]);
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    NSLog(@"执行完了");
}

- (void)singleTestGroup {
    
    dispatch_queue_t q = dispatch_queue_create("itcast", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < 10 ; i++ ) {
        dispatch_async(q, ^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            NSLog(@"%@---->%@",@(i),[NSThread currentThread]);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"主线程回调");
            });
            sleep(1);
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            NSLog(@">>>>>>>>>>>>>>>>");
        });
    }
    NSLog(@"执行完了");
}

- (void)groupTest
{
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(10);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (int i = 0; i < 20; i++)
    {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_group_async(group, queue, ^{
            NSLog(@"%i",i);
            sleep(0.25);
            dispatch_semaphore_signal(semaphore);
        });
    }
    //    dispatch_group_notify(<#dispatch_group_t group#>, <#dispatch_queue_t queue#>, <#^(void)block#>)
    // 和上边的代码效果相同
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"任务完了");
}



#pragma mark - 任务组
/**
 *  GCD任务组
 */
- (void)gcdGroup1
{
    // 案例：譬如要"下载"4本小说，最后全部下载完成之后通知用户
    
    // 多线程执行，是由CPU来调度，程序员不能参与
    
    // 创建一个任务组，可以在任务组中指定队列派发任务
    // 任务组，是可以跨队列的，所有的异步任务完成之后，在主线程更新UI
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t q = dispatch_get_global_queue(0, 0);
    //派发任务组中的任务
    dispatch_group_async(group, q, ^{
        NSLog(@"下载小说 1 %@", [NSThread currentThread]);
    });
    dispatch_group_async(group, q, ^{
        NSLog(@"下载小说 2 %@", [NSThread currentThread]);
    });
    dispatch_group_async(group, q, ^{
        NSLog(@"下载小说 3 %@", [NSThread currentThread]);
        
    });
    dispatch_group_async(group, q, ^{
        NSLog(@"下载小说 4 %@", [NSThread currentThread]);
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"下载完了%@", [NSThread currentThread]);
    });
    
}
- (void)gcdGroup
{
    // 案例：譬如要"下载"4本小说，最后全部下载完成之后通知用户
    
    // 多线程执行，是由CPU来调度，程序员不能参与
    
    // 创建一个任务组，可以在任务组中指定队列派发任务
    // 任务组，是可以跨队列的，所有的异步任务完成之后，在主线程更新UI
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t q = dispatch_get_global_queue(0, 0);
    //派发任务组中的任务
    dispatch_group_async(group, q, ^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"下载小说 1 %@", [NSThread currentThread]);
        });
    });
    dispatch_group_async(group, q, ^{
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            NSLog(@"下载小说 2 %@", [NSThread currentThread]);
        });
    });
    dispatch_group_async(group, q, ^{
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            NSLog(@"下载小说 3 %@", [NSThread currentThread]);
        });
    });
    dispatch_group_async(group, q, ^{
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            NSLog(@"下载小说 4 %@", [NSThread currentThread]);
        });
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"下载完了%@", [NSThread currentThread]);
    });
    
}
#pragma mark - 多线程简单演练
- (void)delay
{
    // 延迟 - 从现在开始，经过多少纳秒之后，由队列调度任务
    /**
     when:  从现在开始，经过多少纳秒之后
     queue: 队列
     block： "异步"任务
     */
    
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    
    //    dispatch_after(when, dispatch_get_main_queue(), ^{
    //        NSLog(@"%@", [NSThread currentThread]);
    //    });
    
    // 延迟1.0之后，在其他队列执行任务
    //    dispatch_after(when, dispatch_get_global_queue(0, 0), ^{
    //        NSLog(@"%@", [NSThread currentThread]);
    //    });
    
    // 串行队列同样会在其他线程工作
    dispatch_after(when, dispatch_queue_create("itcast", NULL), ^{
        NSLog(@"%@", [NSThread currentThread]);
    });
}
/**
 全局队列，异步任务
 */
- (void)gcdDemo9 {
    
    // 获取全局队列
    /**
     参数
     1. 优先级：
     #define DISPATCH_QUEUE_PRIORITY_HIGH 2                 高
     #define DISPATCH_QUEUE_PRIORITY_DEFAULT 0              默认
     #define DISPATCH_QUEUE_PRIORITY_LOW (-2)               低
     #define DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN   后台线程调度队列
     2. flags：为未来使用的，应该传入0
     */
    //    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t q = dispatch_get_global_queue(0, 0);
    for (int i = 0; i < 10; i++) {
        dispatch_async(q, ^{
            NSLog(@"%@ %d", [NSThread currentThread], i);
        });
    }
}
/**
 要写出稳定的好的多线程程序，能多简单，就多简单！
 */
- (void)gcdDemo8 {
    
    // 并发队列
    dispatch_queue_t q = dispatch_queue_create("itcast", DISPATCH_QUEUE_CONCURRENT);
    //在并发队列中执行异步任务
    // 目的：将用户登录也放到后台线程中执行
    dispatch_async(q, ^{
        //先执行一个同步任务阻塞线程
        // 1. 用户登录
        dispatch_sync(q, ^{
            NSLog(@"用户登录 %@", [NSThread currentThread]);
        });
        // 然后再执行异步任务（可以再开辟新的线程）
        // 2. 下载小说
        for (int i = 0; i < 5; i++) {
            dispatch_async(q, ^{
                NSLog(@"下载小说 %d %@", i, [NSThread currentThread]);
            });
        }
    });
}
/**
 在多线程开发中，同步任务只有一个用处！
 
 用来阻塞后面的异步任务，一定要等同步任务执行完成之后，才开发派发
 */
- (void)gcdDemo7 {
    
    // 并发队列
    dispatch_queue_t q = dispatch_queue_create("itcast", DISPATCH_QUEUE_CONCURRENT);
    
    // 1. 用户登录
    //同步任务 阻塞后续的任务
    dispatch_sync(q, ^{
        NSLog(@"用户登录 %@", [NSThread currentThread]);
    });
    
    // 2. 下载小说
    for (int i = 0; i < 5; i++) {
        dispatch_async(q, ^{
            NSLog(@"下载小说 %d %@", i, [NSThread currentThread]);
        });
    }
}
/**
 主队列 同步任务 - 会死锁！
 */
- (void)gcdDemo6 {
    dispatch_queue_t q = dispatch_get_main_queue();
    
    for (int i = 0; i < 10; i++) {
        NSLog(@"执行了吗？ %d", i);
        
        // 一旦向主队列添加了同步任务，就会死锁！！
        dispatch_sync(q, ^{
            NSLog(@"%@ %d", [NSThread currentThread], i);
        });
    }
}

/**
 主队列 异步任务
 
 因为没有也不能开启线程，因此任务是顺序执行的
 */
- (void)gcdDemo5 {
    // 主队列 程序一启动就有主线程，主队列并不需要创建
    dispatch_queue_t q =dispatch_get_main_queue();
    
    for (int i = 0; i < 10; i++) {
        dispatch_async(q, ^{
            NSLog(@"%@ %d", [NSThread currentThread], i);
        });
    }
}
/**
 并发队列，异步任务
 */
- (void)gcdDemo4
{
    dispatch_queue_t q = dispatch_queue_create("XXB", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < 10; i++) {
        dispatch_async(q, ^{
            NSLog(@"%@  %d",[NSThread currentThread] , i);
        });
    }
}
/**
 并发队列，同步任务
 由于没有创建新线程的能里 所以基本没有用
 */
- (void)gcdDemo3
{
    dispatch_queue_t q = dispatch_queue_create("XXB", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < 10; i++) {
        dispatch_sync(q, ^{
            NSLog(@"%@  %d",[NSThread currentThread] , i);
        });
    }
}
/**
 串行队列，异步任务
 只能多开一个线程
 */
- (void)gcdDemo2
{
    dispatch_queue_t q = dispatch_queue_create("XXB", DISPATCH_QUEUE_SERIAL);
    for (int i = 0; i < 10 ; i ++)
    {
        dispatch_async(q, ^{
            NSLog(@"%@  %d",[NSThread currentThread] , i);
        });
    }
}

/**
 串行队列，同步任务，开发中不用
 没有开辟新线程的能力，全部在主线程中执行
 */
- (void)gcdDemo1
{
    // 1. 队列
    /**
     GCD的函数都是以dispatch开头的，在GCD语言的框架中，定义对象的时候 _t结尾
     dispatch   派发任务
     queue      队列
     serial     串行
     sync       同步任务
     */
    dispatch_queue_t q = dispatch_queue_create("XXB", DISPATCH_QUEUE_SERIAL);
    for (int i = 0; i < 10; i++)
    {
        dispatch_sync(q, ^{
            NSLog(@"%@  %d",[NSThread currentThread] , i);
        });
        NSLog(@"+++++®++++++");
    }
    NSLog(@"+++++++++++");
}

- (void)gcdDemo10
{
    // 1. 队列
    /**
     GCD的函数都是以dispatch开头的，在GCD语言的框架中，定义对象的时候 _t结尾
     dispatch   派发任务
     queue      队列
     serial     串行
     sync       同步任务
     */
    dispatch_queue_t q = dispatch_queue_create("XXB", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(q, ^{
        NSLog(@"%@  %d",[NSThread currentThread] , 0);
        dispatch_sync(q, ^{
            NSLog(@"%@  %d",[NSThread currentThread] , 1);
        });
    });
    
    
    dispatch_sync(q, ^{
        NSLog(@"%@  %d",[NSThread currentThread] , 2);
    });
}
- (void)gcdDemo11
{
    // 1. 队列
    /**
     GCD的函数都是以dispatch开头的，在GCD语言的框架中，定义对象的时候 _t结尾
     dispatch   派发任务
     queue      队列
     serial     串行
     sync       同步任务
     */
    dispatch_queue_t q = dispatch_queue_create("XXB", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t q2 = dispatch_queue_create("XXB", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(q, ^{
        NSLog(@"%@  %d",[NSThread currentThread] , 0);
        dispatch_sync(q2, ^{
            NSLog(@"%@  %d",[NSThread currentThread] , 1);
        });
    });
    dispatch_sync(q, ^{
        NSLog(@"%@  %d",[NSThread currentThread] , 2);
    });
}

@end
