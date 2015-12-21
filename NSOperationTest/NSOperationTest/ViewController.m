//
//  ViewController.m
//  NSOperationTest
//
//  Created by 杨小兵 on 15/6/23.
//  Copyright (c) 2015年 杨小兵. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) NSOperationQueue *myQueue;
@end

@implementation ViewController

/**
 *  初始化一个队列
 *
 *  @return 初始化好的对列
 */
- (NSOperationQueue *)myQueue {
    if (_myQueue == nil)
    {
        _myQueue = [[NSOperationQueue alloc] init];
    }
    return _myQueue;
    
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event

{
    [self opDemo4];
}
/**
 *  NSInvocationOperation 测试样例
 */
- (void)opDemo4
{
    NSInvocationOperation *invocationOperation1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(demo4Test1) object:nil];
    NSInvocationOperation *invocationOperation2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(demo4Test2) object:nil];
    NSInvocationOperation *invocationOperation3 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(demo4Test3) object:nil];
    NSInvocationOperation *invocationOperation4 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(demo4Test4) object:nil];
    /**
     *  添加依赖关系
     */
    [invocationOperation2 addDependency:invocationOperation1];
    [invocationOperation3 addDependency:invocationOperation2];
    [invocationOperation4 addDependency:invocationOperation3];
    [self.myQueue addOperations:@[invocationOperation1, invocationOperation2, invocationOperation3,invocationOperation4] waitUntilFinished:NO];
    
}
- (void)demo4Test1
{
    NSLog(@"test1  %@",[NSThread currentThread]);
}
- (void)demo4Test2
{
    NSLog(@"test2  %@",[NSThread currentThread]);
}
- (void)demo4Test3
{
    NSLog(@"test3  %@",[NSThread currentThread]);
}
- (void)demo4Test4
{
    NSLog(@"test4  %@",[NSThread currentThread]);
}
#pragma mark - 操作的依赖->操作的执行顺序
/**
 *  NSBlockOperation 测试阳历
 */
- (void)opDemo3
{
    
    /**
     测试的操作
     例如：
     1. 下载小电影压缩包
     2. 解压缩
     3. 保存文件
     4. 通知用户
     */
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        
        NSLog(@"下载 %@", [NSThread currentThread]);
        
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        
        NSLog(@"解压缩 %@", [NSThread currentThread]);
        
    }];
    
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"保存 %@", [NSThread currentThread]);
    }];
    NSBlockOperation *op4 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"通知用户 %@", [NSThread currentThread]);
        
    }];
    // Dependency依赖
    [op2 addDependency:op1];
    [op3 addDependency:op2];
    [op4 addDependency:op3];
    // 一定注意不要出现循环依赖，
    //    [op1 addDependency:op4];
    // waitUntilFinished等待所有操作完成再继续
    //    [self performSelectorOnMainThread:<#(SEL)#> withObject:<#(id)#> waitUntilDone:<#(BOOL)#>]
    
    [self.myQueue addOperations:@[op1, op2, op3] waitUntilFinished:NO];
    
    [[NSOperationQueue mainQueue] addOperation:op4];
}

/**
 *  队列的暂停和继续
 *
 */
#pragma mark - 队列的暂停和继续
- (IBAction)start:(id)sender {
    [self opDemo1];
}

- (IBAction)pause {
    
    // 先判断队列中是否有操作
    
    if (self.myQueue.operationCount == 0) {
        
        NSLog(@"无操作");
        
        return;
        
    }
    // 挂起－》暂停，暂停的是队列，让队列暂时不再派发任务
    NSLog(@"暂停");
    [self.myQueue setSuspended:YES];
}

- (IBAction)resumue
{
    // 先判断队列中是否有操作
    if (self.myQueue.operationCount == 0)
    {
        NSLog(@"无操作");
        return;
    }
    NSLog(@"继续");
    [self.myQueue setSuspended:NO];
    
}



#pragma mark - 同时并发线程数量
/**
 *  在队列中添加操作
 */
- (void)opDemo1
{
    
    // 线程开启的数量是由GCD底层来决定的，程序员不能参与
    // Mac 10.10 ＋ Xcode 6.0.1 GCD & NSOperation => 能建立 60～70 个线程
    /**
     设置最大并发数的好处，线程开启有消耗
     3G     :   2~3条线程就可以了，线程少，流量少，省钱，省电
     WIFI   :   5～6条线程就可以了，线程多，效率高，流量大，不花钱，可以随时充电！
     */
    // NSOperation提供过了一个属性->最大并发线程数量
    self.myQueue.maxConcurrentOperationCount = 2;
    for (int i = 0; i < 10; i++)
    {
        [self.myQueue addOperationWithBlock:^{
            // 阻塞自己的操作
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"%@ %d", [NSThread currentThread], i);
        }];
        if(self.myQueue.operationCount >= 2)
        {
            NSBlockOperation *lastOperation = [self.myQueue.operations lastObject];
            
            NSBlockOperation *descSecondOperation = self.myQueue.operations[self.myQueue.operations.count - 2];
            [lastOperation addDependency:descSecondOperation];
        }
        NSLog(@"+++++%@ --->>>%@",@(self.myQueue.operations.count),@(self.myQueue.operationCount));
    }
}

@end
