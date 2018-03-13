//
//  WxRedEnvelopTaskManager.h
//  WeChatRedEnvelop
//
//  Created by musk on 17/2/22.
//  Copyright © 2017年 swiftyper. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WxReceiveRedEnvelopOperation;
@interface WxRedEnvelopTaskManager : NSObject

+ (instancetype)sharedManager;

- (void)addNormalTask:(WxReceiveRedEnvelopOperation *)task;
- (void)addSerialTask:(WxReceiveRedEnvelopOperation *)task;

- (BOOL)serialQueueIsEmpty;

@end
