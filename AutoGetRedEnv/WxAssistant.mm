//
//  AutoGetRedEnv.m
//  AutoGetRedEnv
//
//  Created by Tiger on 16/3/21.
//  Copyright (c) 2016年 tqsoft. All rights reserved.
//

#import "CaptainHook.h"
#import "WxAssistantConfig.h"
#import "WeChatRedEnvelopParam.h"
#import "WxRedEnvelopParamQueue.h"
#import "WxReceiveRedEnvelopOperation.h"
#import "WxRedEnvelopTaskManager.h"
#import "WxAccountListController.h"

#pragma mark - 声明类部分

//声明类
//红包
CHDeclareClass(CMessageMgr);
CHDeclareClass(CMessageWrap);
CHDeclareClass(WCRedEnvelopesLogicMgr);
CHDeclareClass(HongBaoRes);
CHDeclareClass(HongBaoReq);
//设置界面
CHDeclareClass(NewSettingViewController);
CHDeclareClass(MMTableViewInfo);
CHDeclareClass(MMTableViewSectionInfo);
CHDeclareClass(MMTableViewCellInfo);
CHDeclareClass(MMTableView);
//运动
CHDeclareClass(WCDeviceStepObject);
//定位
CHDeclareClass(MMLocationMgr);
//登录
CHDeclareClass(WCAccountLoginLastUserViewController);
CHDeclareClass(WCAccountLoginControlLogic);
CHDeclareClass(WCBaseTextFieldItem);
CHDeclareClass(WCAccountLoginFirstUserViewController);
//安全处理
CHDeclareClass(JailBreakHelper);
CHDeclareClass(WCPayTouchIDAuthHelper);
CHDeclareClass(KSSystemInfo);

#pragma mark - 防越狱检测

//判断是否越狱
CHDeclareMethod0(BOOL, JailBreakHelper, IsJailBreak) {
//    NSLog(@"越狱01->%d", CHSuper0(JailBreakHelper, IsJailBreak));
    return NO;
}

//判断是否安装越狱插件
CHDeclareMethod1(BOOL, JailBreakHelper, HasInstallJailbreakPlugin, id, arg1) {
//    NSLog(@"越狱02->%d", CHSuper1(JailBreakHelper, HasInstallJailbreakPlugin, arg1));
    return NO;
}

//内购检测
CHDeclareMethod0(BOOL, JailBreakHelper, HasInstallJailbreakPluginInvalidIAPPurchase) {
//    NSLog(@"越狱03->%d", CHSuper0(JailBreakHelper, HasInstallJailbreakPluginInvalidIAPPurchase));
    return NO;
}

CHDeclareMethod0(BOOL, KSSystemInfo, isJailbroken) {
//    NSLog(@"KS是否越狱%d", CHSuper0(KSSystemInfo, isJailbroken));
    return NO;
}

//CHOptimizedMethod0(self, id, KSSystemInfo, systemInfo) {
//    NSLog(@"KS的参数1->%@", CHSuper0(KSSystemInfo, systemInfo));
//    NSDictionary *ksDic = CHSuper0(KSSystemInfo, systemInfo);
//    if (ksDic.count>0 && [ksDic.allKeys containsObject:@"CFBundleIdentifier"]) {
//        [ksDic setValue:@"com.tencent.xin" forKey:@"CFBundleIdentifier"];
//        NSLog(@"KS的参数2->%@", ksDic);
//        return ksDic;
//    }
//    return CHSuper0(KSSystemInfo, systemInfo);
//}

CHDeclareMethod0(BOOL, WCPayTouchIDAuthHelper, isDeviceJailBreak) {
//    NSLog(@"越狱04->%d", CHSuper0(WCPayTouchIDAuthHelper, isDeviceJailBreak));
    return NO;
}

#pragma mark - 设置界面部分

//设置界面增加“微信小助手”的cell
CHDeclareMethod0(void, NewSettingViewController, reloadTableData) {
    CHSuper0(NewSettingViewController, reloadTableData);
    MMTableViewInfo *tableInfo = [self valueForKeyPath:@"m_tableViewInfo"];
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoDefaut];
    MMTableViewCellInfo *assistantCellInfo = [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(showAssistVc) target:[WxAssistantConfig sharedInstance] title:@"微信小助手" accessoryType:1];
    [sectionInfo addCell:assistantCellInfo];
    [tableInfo insertSection:sectionInfo At:0];
    MMTableView *tableView = [tableInfo getTableView];
    [tableView reloadData];
}

#pragma mark - 红包功能部分

//设置自动抢红包队列的延迟时间
float getDelaySecond() {
    float delaySecond = [[WxAssistantConfig getValueForKey:DelaySecondKey] floatValue];
    BOOL noGetRedEnvSerial = [[WxAssistantConfig getValueForKey:NoGetRedEnvSerialKey] boolValue];
    if (noGetRedEnvSerial) {
        float serialDelaySecond = 0;
        if ([WxRedEnvelopTaskManager sharedManager].serialQueueIsEmpty) {
            serialDelaySecond = delaySecond;
        } else {
            serialDelaySecond = 15;
        }
        return serialDelaySecond;
    } else {
        return delaySecond;
    }
}

//红包管理类(防外挂检测)
//- (void)OnWCToHongbaoCommonResponse:(HongBaoRes *)arg1 Request:(HongBaoReq *)arg2
CHMethod2(void, WCRedEnvelopesLogicMgr, OnWCToHongbaoCommonResponse, id, arg1, Request, id, arg2) {
    CHSuper2(WCRedEnvelopesLogicMgr, OnWCToHongbaoCommonResponse, arg1, Request, arg2);
    BOOL autoGetRedEnv = [[WxAssistantConfig getValueForKey:AutoGetRedEnvKey] boolValue];
    BOOL noGetRedEnvSerial = [[WxAssistantConfig getValueForKey:NoGetRedEnvSerialKey] boolValue];
    
    //HongBaoReq
    NSString *parseRequestSign = nil;
    if ([NSStringFromClass([arg2 class]) isEqualToString:@"HongBaoReq"]) {
        HongBaoReq* hbReq = arg2;
        NSData *buffer2 = [[hbReq reqText] buffer];
        NSString *requestString = [[NSString alloc] initWithData:buffer2 encoding:NSUTF8StringEncoding];
        NSDictionary *requestDictionary = [objc_getClass("WCBizUtil") dictionaryWithDecodedComponets:requestString separator:@"&"];
        NSString *nativeUrl = [[requestDictionary stringForKey:@"nativeUrl"] stringByRemovingPercentEncoding];
        NSDictionary *nativeUrlDict = [objc_getClass("WCBizUtil") dictionaryWithDecodedComponets:nativeUrl separator:@"&"];
        parseRequestSign = [nativeUrlDict stringForKey:@"sign"];
    }
    
    //HongBaoRes
    if ([NSStringFromClass([arg1 class]) isEqualToString:@"HongBaoRes"]) {
        HongBaoRes *hbRes = (HongBaoRes *)arg1;
        //崩溃?!草，已经解决，用这个数据类型
        int cgiCmdid = (uintptr_t)[hbRes cgiCmdid];
        // 非参数查询请求
        if (cgiCmdid != 3) { return; }
        NSData* buffer1 = [[hbRes retText] buffer];
        NSDictionary *responseDict = [[[NSString alloc] initWithData:buffer1 encoding:NSUTF8StringEncoding] JSONDictionary];
        WeChatRedEnvelopParam *mgrParams = [[WxRedEnvelopParamQueue sharedQueue] dequeue];
        //判断是否可以发红包
        BOOL (^shouldReceiveRedEnvelop)() = ^BOOL() {
            // 手动抢红包
            if (!mgrParams) { return NO; }
            // 自己已经抢过
            if ([responseDict[@"receiveStatus"] integerValue] == 2) { return NO; }
            // 红包被抢完
            if ([responseDict[@"hbStatus"] integerValue] == 4) { return NO; }
            // 没有这个字段会被判定为使用外挂
            if (!responseDict[@"timingIdentifier"]) { return NO; }
            // 自己发红包的时候没有 sign 字段
            if (mgrParams.isGroupSender) {
                return autoGetRedEnv;
            } else {
                return [parseRequestSign isEqualToString:mgrParams.sign] && autoGetRedEnv;
            }
        };
        if (shouldReceiveRedEnvelop()) {
            mgrParams.timingIdentifier = responseDict[@"timingIdentifier"];
            WxReceiveRedEnvelopOperation *operation = [[WxReceiveRedEnvelopOperation alloc] initWithRedEnvelopParam:mgrParams delay:getDelaySecond()];
            if (noGetRedEnvSerial) {
                [[WxRedEnvelopTaskManager sharedManager] addSerialTask:operation];
            } else {
                [[WxRedEnvelopTaskManager sharedManager] addNormalTask:operation];
            }
        }
    }
}

//修改抢红包
//- (void)AsyncOnAddMsg:(NSString *)msg MsgWrap:(CMessageWrap *)wrap{}
CHMethod(2, void, CMessageMgr, AsyncOnAddMsg, id, arg1, MsgWrap, id, arg2) {
    CHSuper(2, CMessageMgr, AsyncOnAddMsg, arg1, MsgWrap, arg2);
    if([NSStringFromClass([arg2 class]) isEqualToString:@"CMessageWrap"]) {
        CMessageWrap *msgWrap = arg2;
        unsigned long m_uiMessageType = (unsigned long)[msgWrap m_uiMessageType];
        id m_nsFromUsr = [msgWrap m_nsFromUsr];
        id m_nsToUsr = [msgWrap m_nsToUsr];
        id m_nsContent = [msgWrap m_nsContent];
        switch(m_uiMessageType) {
            //49=红包
            case 49: {
                //是否为红包消息
                if ([m_nsContent rangeOfString:@"wxpay://"].location != NSNotFound) {
                    //红包时再用
                    id m_oWCPayInfoItem = [msgWrap m_oWCPayInfoItem];
                    //微信的服务中心
                    Method methodMMServiceCenter = class_getClassMethod(objc_getClass("MMServiceCenter"), @selector(defaultCenter));
                    IMP impMMSC = method_getImplementation(methodMMServiceCenter);
                    id MMServiceCenter = impMMSC(objc_getClass("MMServiceCenter"), @selector(defaultCenter));
                    //红包控制器
                    id logicMgr = ((id (*)(id, SEL, Class))objc_msgSend)(MMServiceCenter, @selector(getService:), objc_getClass("WCRedEnvelopesLogicMgr"));
                    //通讯录管理器
                    id contactManager = ((id (*)(id, SEL, Class))objc_msgSend)(MMServiceCenter, @selector(getService:),objc_getClass("CContactMgr"));
                    //获得自己的账号信息
                    Method methodGetSelfContact = class_getInstanceMethod(objc_getClass("CContactMgr"), @selector(getSelfContact));
                    IMP impGS = method_getImplementation(methodGetSelfContact);
                    id selfContact = impGS(contactManager, @selector(getSelfContact));
                    //获得自己的微信id
                    Ivar nsUsrNameIvar = class_getInstanceVariable([selfContact class], "m_nsUsrName");
                    id m_nsUsrName = object_getIvar(selfContact, nsUsrNameIvar);
                    
                    //是否是自己发的消息
                    BOOL (^isFromMeMsg)() = ^BOOL() {
                        return [m_nsFromUsr isEqualToString:m_nsUsrName];
                    };
                    //是否别人在群聊中发消息
//                    BOOL (^isGroupMsg)() = ^BOOL() {
//                        return [m_nsFromUsr rangeOfString:@"@chatroom"].location != NSNotFound;
//                    };
                    //是否自己在群聊中发消息
                    BOOL (^isGroupMsgFromMe)() = ^BOOL() {
                        return isFromMeMsg() && [m_nsToUsr rangeOfString:@"chatroom"].location != NSNotFound;
                    };
                    //是否在黑名单中
                    NSArray *blackList = [WxAssistantConfig getValueForKey:BlackListKey];
                    BOOL (^isGroupInBlackList)() = ^BOOL() {
                        if (blackList.count==0) {
                            return NO;
                        }
                        return [blackList containsObject:m_nsFromUsr];
                    };
                    //是否自动抢红包(只判定是否自动抢红包，是否抢某些群的红包)
                    BOOL autoGetRedEnv = [[WxAssistantConfig getValueForKey:AutoGetRedEnvKey] boolValue];
                    BOOL (^shouldReceiveRedEnvelop)() = ^BOOL() {
                        if (isGroupInBlackList()) { return NO; }
                        return autoGetRedEnv;
                    };
                    NSDictionary *(^parseNativeUrl)(NSString *nativeUrl) = ^(NSString *nativeUrl) {
                        nativeUrl = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];
                        return [objc_getClass("WCBizUtil") dictionaryWithDecodedComponets:nativeUrl separator:@"&"];
                    };
                    
                    /** 获取服务端验证参数 */
                    void (^queryRedEnvelopesReqeust)(NSDictionary *nativeUrlDict) = ^(NSDictionary *nativeUrlDict) {
                        NSMutableDictionary *params = [@{} mutableCopy];
                        params[@"agreeDuty"] = @"0";
                        params[@"channelId"] = [nativeUrlDict stringForKey:@"channelid"];
                        params[@"inWay"] = @"0";
                        params[@"msgType"] = [nativeUrlDict stringForKey:@"msgtype"];
                        params[@"nativeUrl"] = [m_oWCPayInfoItem m_c2cNativeUrl];
                        params[@"sendId"] = [nativeUrlDict stringForKey:@"sendid"];
                        [logicMgr ReceiverQueryRedEnvelopesRequest:params];
                    };
                    
                    /** 储存参数 */
                    void (^enqueueParam)(NSDictionary *nativeUrlDict) = ^(NSDictionary *nativeUrlDict) {
                        WeChatRedEnvelopParam *mgrParams = [[WeChatRedEnvelopParam alloc] init];
                        mgrParams.msgType = [nativeUrlDict stringForKey:@"msgtype"];
                        mgrParams.sendId = [nativeUrlDict stringForKey:@"sendid"];
                        mgrParams.channelId = [nativeUrlDict stringForKey:@"channelid"];
                        mgrParams.nickName = [selfContact getContactDisplayName];
                        mgrParams.headImg = [selfContact m_nsHeadImgUrl];
                        mgrParams.nativeUrl = [m_oWCPayInfoItem m_c2cNativeUrl];
                        mgrParams.sessionUserName = isGroupMsgFromMe() ? m_nsToUsr : m_nsFromUsr;
                        mgrParams.sign = [nativeUrlDict stringForKey:@"sign"];
                        mgrParams.isGroupSender = isGroupMsgFromMe();
                        [[WxRedEnvelopParamQueue sharedQueue] enqueue:mgrParams];
                    };
                    
                    if (shouldReceiveRedEnvelop()) {
                        NSString *nativeUrl = [m_oWCPayInfoItem m_c2cNativeUrl];
                        NSDictionary *nativeUrlDict = parseNativeUrl(nativeUrl);
                        queryRedEnvelopesReqeust(nativeUrlDict);
                        enqueueParam(nativeUrlDict);
                    }
                }
                break;
            }
            default: {
//                NSLog(@"非红包消息，m_uiMessageType->%lu", (unsigned long)m_uiMessageType);
            }
                break;
        }
    }
}

#pragma mark - 修改运动步数部分

//修改运动步数
//宏格式：参数的个数，返回值的类型，类的名称，selector的名称，selector的类型，selector对应的参数的变量名。
CHMethod(0, unsigned long, WCDeviceStepObject, m7StepCount) {
    BOOL modifyStepCount = [[WxAssistantConfig getValueForKey:ModifyStepCountKey] boolValue];
    unsigned long stepCount = [(NSNumber *)[WxAssistantConfig getValueForKey:StepCountKey] unsignedLongValue];
    if (!modifyStepCount || (stepCount==0)) {
        stepCount = CHSuper(0, WCDeviceStepObject, m7StepCount);
    }
    return stepCount;
}

//CHMethod(0, unsigned long, WCDeviceStepObject, hkStepCount) {
//    unsigned long stepCount = CHSuper(0, WCDeviceStepObject, hkStepCount);;
//    if (![WxAssistantConfig contentIsEmpty]) {
//        BOOL modifyStepCount = [[WxAssistantConfig getValueForKey:ModifyStepCountKey] boolValue];
//        if (modifyStepCount) {
//            if (stepCount > 0) {
//                return stepCount = ((NSNumber *)[WxAssistantConfig getValueForKey:StepCountKey]).unsignedLongValue;
//            }
//        }
//    }
//    return stepCount;
//}

#pragma mark - 修改当前位置部分

//修改经纬度
CHMethod3(void, MMLocationMgr, locationManager, id, arg1, didUpdateToLocation, id, arg2, fromLocation, id, arg3) {
    BOOL modifyLocation = [[WxAssistantConfig getValueForKey:ModifyLocationKey] boolValue];
    NSString *locationInfo = [WxAssistantConfig getValueForKey:LocationInfoKey];
    NSArray *locationInfoArr = [locationInfo componentsSeparatedByString:@"&"];
    NSArray *longitudeArr = [locationInfoArr[0] componentsSeparatedByString:@"="];
    NSArray *latitudeArr = [locationInfoArr[1] componentsSeparatedByString:@"="];
    double longitude = 113.663221;
    double latitude = 34.7568711;
    if ([longitudeArr[0] isEqualToString:@"longitude"]) {
        longitude = [longitudeArr[1] doubleValue];
    }
    if ([latitudeArr[0] isEqualToString:@"latitude"]) {
        latitude = [latitudeArr[1] doubleValue];
    }
    if (modifyLocation) {
        id toLocation = [[objc_getClass("CLLocation") alloc] initWithLatitude:latitude longitude:longitude];
        //        CLLocation *fromLocation = [[objc_getClass("CLLocation") alloc] initWithLatitude:34.7568711 longitude:113.663221];
        CHSuper3(MMLocationMgr, locationManager, arg1, didUpdateToLocation, toLocation, fromLocation, arg3);
    } else {
        CHSuper3(MMLocationMgr, locationManager, arg1, didUpdateToLocation, arg2, fromLocation, arg3);
    }
}

#pragma mark - 切换账号部分

//界面增加切换账号按钮
CHDeclareMethod0(void, WCAccountLoginLastUserViewController, viewDidLoad) {
    CHSuper0(WCAccountLoginLastUserViewController, viewDidLoad);
    CGFloat leftMargin = [UIScreen mainScreen].bounds.size.width - 96;
    UIButton *switchAccountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    switchAccountBtn.frame = CGRectMake(leftMargin, 40, 86, 34);
    [switchAccountBtn setTitle:@"切换账号" forState:UIControlStateNormal];
    [switchAccountBtn setTitleColor:[UIColor colorWithRed:23/255.0 green:180/255.0 blue:96/255.0 alpha:1.0] forState:UIControlStateNormal];
    switchAccountBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [switchAccountBtn addTarget:[WxAssistantConfig sharedInstance] action:@selector(switchAccount:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:switchAccountBtn];
}

//选择账号时在界面显示选择的账号信息
CHDeclareMethod1(void, WCAccountLoginLastUserViewController, setAccount, WxAccountInfo *, account) {
    Ivar labelUserName = class_getInstanceVariable(objc_getClass("WCAccountLoginLastUserViewController"), "m_labelUserName");
    UILabel *m_labelUserName = object_getIvar(self, labelUserName);
    [m_labelUserName setText:account.userAccount];
    Ivar textFieldPwdItem = class_getInstanceVariable(objc_getClass("WCAccountLoginLastUserViewController"), "m_textFieldPwdItem");
    WCBaseTextFieldItem *m_textFieldPwdItem = object_getIvar(self, textFieldPwdItem);
    [m_textFieldPwdItem setText:account.userPwd];
    Ivar delegate = class_getInstanceVariable(objc_getClass("WCAccountLoginLastUserViewController"), "m_delegate");
    WCAccountLoginControlLogic *m_delegate = object_getIvar(self, delegate);
    [m_delegate onLastUserLoginUserName:account.userAccount Pwd:account.userPwd];
}

//登录时保存账号信息(缓存登录界面)
CHDeclareMethod0(void, WCAccountLoginLastUserViewController, onNext) {
        CHSuper0(WCAccountLoginLastUserViewController, onNext);
    Ivar labelUserName = class_getInstanceVariable(objc_getClass("WCAccountLoginLastUserViewController"), "m_labelUserName");
    UILabel *m_labelUserName = object_getIvar(self, labelUserName);
    Ivar textFieldPwdItem = class_getInstanceVariable(objc_getClass("WCAccountLoginLastUserViewController"), "m_textFieldPwdItem");
    WCBaseTextFieldItem *m_textFieldPwdItem = object_getIvar(self, textFieldPwdItem);
    WxAccountInfo *ai = [[WxAccountInfo alloc] init];
    ai.userAccount = m_labelUserName.text;
    ai.userPwd = [m_textFieldPwdItem getValue];
    [WxAccountInfo updateAccount:ai];
}

//登录时保存账号信息(初始登录界面)
CHDeclareMethod0(void, WCAccountLoginFirstUserViewController, onNext) {
        CHSuper0(WCAccountLoginFirstUserViewController, onNext);
    Ivar textFieldUserNameItem = class_getInstanceVariable(objc_getClass("WCAccountLoginFirstUserViewController"), "m_textFieldUserNameItem");
    WCBaseTextFieldItem *m_textFieldUserNameItem = object_getIvar(self, textFieldUserNameItem);
    Ivar textFieldPwdItem = class_getInstanceVariable(objc_getClass("WCAccountLoginFirstUserViewController"), "m_textFieldPwdItem");
    WCBaseTextFieldItem *m_textFieldPwdItem = object_getIvar(self, textFieldPwdItem);
    WxAccountInfo *ai = [[WxAccountInfo alloc] init];
    ai.userAccount = [m_textFieldUserNameItem getValue];
    ai.userPwd = [m_textFieldPwdItem getValue];
    [WxAccountInfo updateAccount:ai];
}

#pragma mark - 入口部分

__attribute__((constructor)) static void entry()
{
    //在构造方法中替换方法
    //微信自动抢红包
    CHLoadLateClass(CMessageMgr);
    CHClassHook(2, CMessageMgr, AsyncOnAddMsg, MsgWrap);
    
    //抢红包功能防外挂检测部分
    CHLoadLateClass(WCRedEnvelopesLogicMgr);
    CHClassHook2(WCRedEnvelopesLogicMgr, OnWCToHongbaoCommonResponse, Request);
    
    //微信更新运动数据
    CHLoadLateClass(WCDeviceStepObject);
    CHClassHook(0, WCDeviceStepObject, m7StepCount);
//    CHClassHook(0, WCDeviceStepObject, hkStepCount);
    
    //修改定位
    CHLoadLateClass(MMLocationMgr);
    CHClassHook3(MMLocationMgr, locationManager, didUpdateToLocation, fromLocation);
}

