
//  WxAssistConfig.m
//  test
//
//  Created by tiger on 2017/6/6.
//
//

#import "WxAssistantConfig.h"
#import <objc/runtime.h>
#import "WxAssistantViewController.h"
#import "WxAccountListController.h"
@class MMUINavigationController;

//配置文件的路径
#define docDirPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
#define filePath [docDirPath stringByAppendingPathComponent:@"WxAConfig.cfg"]

NSString *const AutoGetRedEnvKey = @"AutoGetRedEnv";
NSString *const DelaySecondKey = @"DelaySecond";
NSString *const NoGetRedEnvSerialKey = @"NoGetRedEnvSerial";
NSString *const BlackListKey = @"BlackList";
NSString *const ModifyStepCountKey = @"ModifyStepCount";
NSString *const StepCountKey = @"StepCount";
NSString *const ModifyLocationKey = @"ModifyLocation";
NSString *const LocationInfoKey = @"LocationInfo";
NSString *const ModifyLikeUsersKey = @"ModifyLikeUsers";

@interface WxAssistantConfig()
@end

@implementation WxAssistantConfig

#pragma mark - init

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (instancetype)sharedInstance {
    static WxAssistantConfig *_wxAssistConfig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _wxAssistConfig = [[WxAssistantConfig alloc] init];
    });
    return _wxAssistConfig;
}


#pragma mark - 跳转控制器

//跳转设置中心界面
- (void)showAssistVc {
    WxAssistantViewController *wxAssistantViewController = [[WxAssistantViewController alloc] init];
    UIViewController *vc = [self visibleViewController];
    if ([vc isKindOfClass:NSClassFromString(@"MMTabBarController")]) {
        if ([[vc selectedViewController].childViewControllers[1] isKindOfClass:NSClassFromString(@"NewSettingViewController")]) {
            wxAssistantViewController.isPresented = NO;
            [[vc selectedViewController].childViewControllers[1].navigationController pushViewController:wxAssistantViewController animated:YES];
        } else {
            //如果查找不到NewSettingViewController，则使用跟控制器present新控制器的方式
            wxAssistantViewController.isPresented = YES;
//            [vc presentViewController:wxAssistantViewController animated:YES completion:nil];
            MMUINavigationController *mmNavC = [[objc_getClass("MMUINavigationController") alloc] initWithRootViewController:wxAssistantViewController];
            [vc presentViewController:mmNavC animated:YES completion:nil];
        }
    }
}

//跳转切换账号界面
- (void)switchAccount:(UIButton *)btn {
    WxAccountListController *accountListVc = [[WxAccountListController alloc] init];
//    UINavigationController *mmNavVc = [[UINavigationController alloc] initWithRootViewController:accountListVc];
    MMUINavigationController *mmNavVc = [[objc_getClass("MMUINavigationController") alloc] initWithRootViewController:accountListVc];
//    [mmNavVc.navigationBar setBackgroundColor:[UIColor blackColor]];
//    [mmNavVc.navigationBar setTintColor:[UIColor whiteColor]];
    UIViewController *vc = [self visibleViewController];
    accountListVc.parent = vc;
    accountListVc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [vc presentViewController:mmNavVc animated:YES completion:nil];
}

- (UIWindow *)visibleWindow {
    return [UIApplication sharedApplication].windows.firstObject;
}

- (UIViewController *)visibleViewController {
    UIWindow *window = [self visibleWindow];
    UIViewController *vc = window.rootViewController;
    //控制器类型MMTabBarController--MMTabBarController
    while (vc.presentedViewController) {
        vc = vc.presentedViewController;
    }
    return vc;
}

#pragma mark - 配置参数

+ (void)saveValue:(id)value forKey:(NSString *)key {
    if (!filePath) {
//        NSLog(@"没有找到微信2的配置文件");
        return;
    }
    NSMutableDictionary *newDic = [NSMutableDictionary dictionary];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSDictionary *originalDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
        [newDic setDictionary:originalDic];
    }
    [newDic setValue:value forKey:key];
    BOOL ret = [newDic writeToFile:filePath atomically:YES];
    if (ret) {
//        NSLog(@"配置信息写入成功!");
    } else {
//        NSLog(@"配置信息写入失败!");
    }
}

+ (id)getValueForKey:(NSString *)key {
    if (!filePath) {
//        NSLog(@"没有找到微信2的配置文件");
        return nil;
    }
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    if (!dict) {
//        NSLog(@"微信2的配置文件内容为空->%@", key);
        return nil;
    }
    return [dict valueForKey:key];
}

@end
