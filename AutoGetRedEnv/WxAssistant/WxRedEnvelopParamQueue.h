//
//  WxRedEnvelopParamQueue.h
//  WeChatRedEnvelop
//
//  Created by musk on 2017/2/22.
//  Copyright © 2017年 swiftyper. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WeChatRedEnvelopParam;
@interface WxRedEnvelopParamQueue : NSObject

+ (instancetype)sharedQueue;

- (void)enqueue:(WeChatRedEnvelopParam *)param;
- (WeChatRedEnvelopParam *)dequeue;
- (WeChatRedEnvelopParam *)peek;
- (BOOL)isEmpty;

@end
