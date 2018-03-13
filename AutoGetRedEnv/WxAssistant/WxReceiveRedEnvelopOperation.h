//
//  WxReceiveRedEnvelopOperation.h
//  WeChatRedEnvelop
//
//  Created by musk on 17/2/22.
//  Copyright © 2017年 swiftyper. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WeChatRedEnvelopParam;
@interface WxReceiveRedEnvelopOperation : NSOperation

- (instancetype)initWithRedEnvelopParam:(WeChatRedEnvelopParam *)param delay:(unsigned int)delaySeconds;

@end
