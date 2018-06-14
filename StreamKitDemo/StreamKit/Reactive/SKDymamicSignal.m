//
//  SKRealSignal.m
//  StreamKitDemo
//
//  Created by imac on 2018/6/14.
//  Copyright © 2018年 李浩. All rights reserved.
//

#import "SKDymamicSignal.h"
#import "SKScheduler.h"
#import "SKCompoundDisposable.h"

@interface SKDymamicSignal ()

@property (nonatomic,copy) SKDisposable *(^subscriberBlock)(id<SKSubscriber> subscriber);

@end

@implementation SKDymamicSignal

+ (instancetype)signalWithBlock:(SKDisposable * (^)(id<SKSubscriber> subscriber))block {
    SKDymamicSignal *signal = [SKDymamicSignal new];
    signal.subscriberBlock = block;
    return signal;
}

- (SKDisposable *)subscribe:(id<SKSubscriber>)subscriber {
    SKCompoundDisposable *disposable = [SKCompoundDisposable disposableWithBlock:nil];
    if (self.subscriberBlock) {
        SKDisposable *schedulerDisposable = [[SKScheduler subscriptionScheduler] schedule:^{
            SKDisposable *selfDisposabel = self.subscriberBlock(subscriber);
            [disposable addDisposable:selfDisposabel];
        }];
        [disposable addDisposable:schedulerDisposable];
    }
    return disposable;
}

@end
