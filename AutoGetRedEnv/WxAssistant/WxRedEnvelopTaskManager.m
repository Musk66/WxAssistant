//
//  WxRedEnvelopTaskManager.m
//  WeChatRedEnvelop
//
//  Created by musk on 17/2/22.
//  Copyright © 2017年 swiftyper. All rights reserved.
//

#import "WxRedEnvelopTaskManager.h"
#import "WxReceiveRedEnvelopOperation.h"

@interface WxRedEnvelopTaskManager ()

@property (strong, nonatomic) NSOperationQueue *normalTaskQueue;
@property (strong, nonatomic) NSOperationQueue *serialTaskQueue;

@end

@implementation WxRedEnvelopTaskManager

+ (instancetype)sharedManager {
    static WxRedEnvelopTaskManager *taskManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        taskManager = [WxRedEnvelopTaskManager new];
    });
    return taskManager;
}

- (instancetype)init {
    if (self = [super init]) {
        _serialTaskQueue = [[NSOperationQueue alloc] init];
        _serialTaskQueue.maxConcurrentOperationCount = 1;
        
        _normalTaskQueue = [[NSOperationQueue alloc] init];
        _normalTaskQueue.maxConcurrentOperationCount = 5;
    }
    return self;
}

- (void)addNormalTask:(WxReceiveRedEnvelopOperation *)task {
    [self.normalTaskQueue addOperation:task];
}

- (void)addSerialTask:(WxReceiveRedEnvelopOperation *)task {
    [self.serialTaskQueue addOperation:task];
}

- (BOOL)serialQueueIsEmpty {
    return [self.serialTaskQueue operations].count == 0;
}

@end
