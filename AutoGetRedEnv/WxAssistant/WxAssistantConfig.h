//
//  WxAssistantConfig.h
//  test
//
//  Created by tiger on 2017/6/6.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const AutoGetRedEnvKey;
extern NSString *const DelaySecondKey;
extern NSString *const NoGetRedEnvSerialKey;
extern NSString *const BlackListKey;
extern NSString *const ModifyStepCountKey;
extern NSString *const StepCountKey;
extern NSString *const ModifyLocationKey;
extern NSString *const LocationInfoKey;
extern NSString *const ModifyLikeUsersKey;

@interface WxAssistantConfig : NSObject

+ (instancetype)sharedInstance;
//更新配置参数
+ (void)saveValue:(id)value forKey:(NSString *)key;
//获得配置参数
+ (id)getValueForKey:(NSString *)key;
//显示微信助手控制器
- (void)showAssistVc;
//切换账号
- (void)switchAccount:(UIButton *)btn;

@end
