//
//  ViewController.m
//  NSThreadTest
//
//  Created by 杨小兵 on 15/6/23.
//  Copyright (c) 2015年 杨小兵. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property(nonatomic , assign)int tickets;
@end

@implementation ViewController

- (void)test
{
    @synchronized(self){
    };
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    self.tickets = 20;
    
    
    
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
@end
