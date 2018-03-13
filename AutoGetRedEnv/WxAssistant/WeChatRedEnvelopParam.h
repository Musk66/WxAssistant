//
//  WeChatRedEnvelopParam.h
//  WeChatRedEnvelop
//
//  Created by musk on 2017/1/22.
//  Copyright © 2017年 swiftyper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeChatRedEnvelopParam : NSObject

@property (nonatomic, strong) NSString *msgType;
@property (nonatomic, strong) NSString *sendId;
@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *headImg;
@property (nonatomic, strong) NSString *nativeUrl;
@property (nonatomic, strong) NSString *sessionUserName;
@property (nonatomic, strong) NSString *sign;
@property (nonatomic, strong) NSString *timingIdentifier;

@property (assign, nonatomic) BOOL isGroupSender;

- (NSDictionary *)toParams;

@end
