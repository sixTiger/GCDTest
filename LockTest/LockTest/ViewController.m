//
//  ViewController.m
//  LockTest
//
//  Created by xiaobing on 15/12/31.
//  Copyright © 2015年 xiaobing. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property(nonatomic , assign)int                tickets;
@property(nonatomic , strong)NSRecursiveLock    *lock;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //    [self p_lockDemo_1];
    //    [self p_lockDemo_2];
    //    [self p_lockDemo_3];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)p_lockDemo_1
{
    // 会发生死锁
    NSLog(@"%s",__func__);
    NSLock *lock = [[NSLock alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        static void (^RecursiveMethod)(int);
        
        RecursiveMethod = ^(int value) {
            
            [lock lock];
            if (value > 0) {
                
                NSLog(@"value = %d", value);
                sleep(2);
                RecursiveMethod(value - 1);
            }
            [lock unlock];
        };
        
        RecursiveMethod(5);
    });
}

- (void)p_lockDemo_2
{
    // 会发生死锁
    NSLog(@"%s",__func__);
    
    NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        static void (^RecursiveMethod)(int);
        
        RecursiveMethod = ^(int value) {
            
            [lock lock];
            if (value > 0) {
                
                NSLog(@"value = %d", value);
                sleep(2);
                RecursiveMethod(value - 1);
            }
            [lock unlock];
        };
        
        __block int count = 5;
        RecursiveMethod(count);
    });
}

- (void)p_lockDemo_3
{
    // 会发生死锁
    NSLog(@"%s",__func__);
    
    NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];
    
    static void (^RecursiveMethod)(NSNumber *);
    
    RecursiveMethod = ^(NSNumber *number) {
        
        [lock lock];
        if (number.intValue > 0) {
            
            NSLog(@"value = %@", number);
            sleep(2);
            number = @(number.intValue - 1);
            RecursiveMethod(number);
        }
        [lock unlock];
    };
    
    __block NSNumber *number = @(5);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        RecursiveMethod(number);
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        RecursiveMethod(number);
    });
}

- (IBAction)p_startLockDemo4:(id)sender
{
    if(self.tickets <= 0)
    {
        self.tickets = 20;
        [self p_lockDemo_4];
    }
}

- (void)p_lockDemo_4
{
    
    NSThread *threadA = [[NSThread alloc] initWithTarget:self selector:@selector(saleTickets) object:nil];
    threadA.name = @"售票员 A";
    [threadA start];
    NSThread *threadB = [[NSThread alloc] initWithTarget:self selector:@selector(saleTickets) object:nil];
    threadB.name = @"售票员 B";
    [threadB start];
}



- (void)saleTickets
{
    while (YES)
    {
        // 模拟休眠
        [NSThread sleepForTimeInterval:1.0f];
        //枷锁 防止资源抢夺错误
        
        [self.lock lock];
        if (self.tickets > 0)
        {
            self.tickets--;
            NSLog(@"剩余票数 %@ %d", [NSThread currentThread], self.tickets);
            
        }
        else
        {
            break;
        }
        [self.lock unlock];
    }
}


- (void)saleTickets_synchronized
{
    while (YES)
    {
        // 模拟休眠
        [NSThread sleepForTimeInterval:1.0f];
        //枷锁 防止资源抢夺错误
        @synchronized(self) {
            if (self.tickets > 0)
            {
                self.tickets--;
                NSLog(@"剩余票数 %@ %d", [NSThread currentThread], self.tickets);
                
            }
            else
            {
                break;
            }
        }
    }
}


- (NSRecursiveLock *)lock
{
    if(_lock == nil)
    {
        _lock = [[NSRecursiveLock alloc] init];
        
    }
    return _lock;
}
@end
