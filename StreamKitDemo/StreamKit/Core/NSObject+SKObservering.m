//
//  NSObject+SKObserveing.m
//  StreamKitDemo
//
//  Created by 李浩 on 2018/6/24.
//  Copyright © 2018年 李浩. All rights reserved.
//

#import "NSObject+SKObservering.h"
#import "SKSignal.h"
#import "SKSignal+Operations.h"
#import "NSObject+SKDeallocating.h"
#import "SKSubscriber.h"
#import "SKDisposable.h"
#import "SKCompoundDisposable.h"
#import "SKObjectifyMarco.h"

@interface _SKObserverTarget : NSObject

- (instancetype)initWithSubscriber:(id<SKSubscriber>)subscriber;


@end

@implementation _SKObserverTarget {
    id<SKSubscriber> _subscriber;
#ifdef DEBUG
    __unsafe_unretained id _observer;
    NSString *_keyPath;
#endif
}

- (instancetype)initWithSubscriber:(id<SKSubscriber>)subscriber {
    self = [super init];
    if (self) {
        _subscriber = subscriber;
    }
    return self;
}

#ifdef DEBUG
- (instancetype)initWithSubscriber:(id<SKSubscriber>)subscriber observer:(id)observer keyPath:(NSString *)keyPath {
    self = [super init];
    if (self) {
        _subscriber = subscriber;
        _observer = observer;
        _keyPath = keyPath;
    }
    return self;
}

#endif

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (_subscriber) {
        [_subscriber sendNext:change];
    }
}

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"observerTarget will dealloc by observer is %@ keyPath is %@",_observer,_keyPath);
}

#endif
@end

@implementation NSObject (SKObservering)

- (SKSignal *)sk_observerWithKeyPath:(NSString *)keyPath {
    return [self sk_observerWithKeyPath:keyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld];
}

- (SKSignal *)sk_observerWithKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options {
    @weakify(self)
    return [[SKSignal signalWithBlock:^SKDisposable *(id<SKSubscriber> subscriber) {
        @strongify(self)
        _SKObserverTarget *target = nil;
#ifdef DEBUG
        target = [[_SKObserverTarget alloc] initWithSubscriber:subscriber observer:self keyPath:keyPath];
#else
        target  = [[_SKObserverTarget alloc] initWithSubscriber:subscriber];
#endif
        [self addObserver:target forKeyPath:keyPath options:options context:nil];
        SKDisposable *removeDisposable = [SKDisposable disposableWithBlock:^{
            @strongify(self)
            [self removeObserver:target forKeyPath:keyPath];
        }];
        [self.deallocDisposable addDisposable:removeDisposable];
        return [SKDisposable disposableWithBlock:^{
            [removeDisposable dispose];
        }];
    }] takeUntil:self.deallocSignal];
}

@end
