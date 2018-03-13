//
//  WxAssistantViewController.m
//  test
//
//  Created by tiger on 2017/6/6.
//
//

#import "WxAssistantViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "WeChatHeader.h"
#import "WxAssistantConfig.h"
#import "WxMultiSelectGroupsViewController.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface WxAssistantViewController() <MultiSelectGroupsViewControllerDelegate>
@property (nonatomic, strong) MMTableViewInfo *tableViewInfo;
@end

@implementation WxAssistantViewController

#pragma mark - 界面初始化部分

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _tableViewInfo = [[objc_getClass("MMTableViewInfo") alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavbar];
    [self addTableView];
    [self reloadTbData];
}

- (void)initNavbar {
    self.title = @"微信小助手";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    if (_isPresented) {
//        [self addCustomNavBar];
        UIBarButtonItem *leftBarButtonItem = [objc_getClass("MMUICommonUtil") getBarButtonWithTitle:@" 返回" target:self action:@selector(dismissVc) style:1];
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    }
}

/*
//如果是present的方式则添加一个自定义的导航栏
- (void)addCustomNavBar {
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 20, ScreenWidth, 44)];
    navBar.barTintColor = [UIColor colorWithRed:45/255.0 green:43/255.0 blue:50/255.0 alpha:1.0f];
    [navBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18.0], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"微信小助手"];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"  返回" style:UIBarButtonItemStylePlain target:self action:@selector(dismissVc)];
    [leftBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18.0], NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    navItem.leftBarButtonItem = leftBarButtonItem;
    leftBarButtonItem.tintColor = [UIColor whiteColor];
    [navBar pushNavigationItem:navItem animated:YES];
    [self.view addSubview:navBar];
}
*/

//添加(微信封装的)表格
- (void)addTableView {
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [self.view addSubview:tableView];
}

- (void)reloadTbData {
    [self.tableViewInfo clearAllSection];
    [self addEnvelopSection];
    [self addOtherSection];
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [tableView reloadData];
}

#pragma mark - 红包功能部分

//添加红包功能section
- (void)addEnvelopSection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"红包功能"];
    [sectionInfo addCell:[self autoGetRedEnvCell]];
    [sectionInfo addCell:[self delaySettingCell]];
    [sectionInfo addCell:[self noGetRedEnvSerialCell]];
    [sectionInfo addCell:[self blackListCell]];
    [self.tableViewInfo addSection:sectionInfo];
}

//是否自动抢红包控制cell
- (MMTableViewCellInfo *)autoGetRedEnvCell {
    BOOL autoGetRedEnv = [[WxAssistantConfig getValueForKey:AutoGetRedEnvKey] boolValue];
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(switchAutoGetRedEnv:) target:self title:@"自动抢红包" on:autoGetRedEnv];
}

//是否延迟抢红包cell
- (MMTableViewCellInfo *)delaySettingCell {
    BOOL autoGetRedEnv = [[WxAssistantConfig getValueForKey:AutoGetRedEnvKey] boolValue];
    float delaySecond = [[WxAssistantConfig getValueForKey:DelaySecondKey] floatValue];
    NSString *delayString = delaySecond == 0 ? @"不延迟" : [NSString stringWithFormat:@"%.1f 秒", delaySecond];
    MMTableViewCellInfo *cellInfo;
    if (autoGetRedEnv) {
        cellInfo = [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(setDelaySeconds) target:self title:@"延迟抢红包" rightValue:delayString accessoryType:1];
    } else {
        cellInfo = [objc_getClass("MMTableViewCellInfo") normalCellForTitle:@"延迟抢红包" rightValue:@"功能已关闭"];
    }
    return cellInfo;
}

//是否同时抢多个红包cell
- (MMTableViewCellInfo *)noGetRedEnvSerialCell {
    BOOL autoGetRedEnv = [[WxAssistantConfig getValueForKey:AutoGetRedEnvKey] boolValue];
    BOOL noGetRedEnvSerial = [[WxAssistantConfig getValueForKey:NoGetRedEnvSerialKey] boolValue];
    MMTableViewCellInfo *envCell;
    if (autoGetRedEnv) {
        envCell = [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(switchGetRedEnvSerial:) target:self title:@"防止同时抢多个红包" on:noGetRedEnvSerial];
    } else {
        envCell = [objc_getClass("MMTableViewCellInfo") normalCellForTitle:@"防止同时抢多个红包" rightValue:@"功能已关闭"];
    }
    return envCell;
}

//是否抢群里的红包
- (MMTableViewCellInfo *)blackListCell {
    BOOL autoGetRedEnv = [[WxAssistantConfig getValueForKey:AutoGetRedEnvKey] boolValue];
    NSArray *blackList = [WxAssistantConfig getValueForKey:BlackListKey];
    if (autoGetRedEnv) {
        NSString *blRightValue = [NSString stringWithFormat:@"已选%lu个群", (unsigned long)blackList.count];
        return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(showBlackList) target:self title:@"不抢群里的红包" rightValue:blRightValue accessoryType:1];
    } else {
        return [objc_getClass("MMTableViewCellInfo") normalCellForTitle:@"不抢群里的红包" rightValue:@"功能已关闭"];
    }
}

- (void)switchAutoGetRedEnv:(UISwitch *)envSwitch {
    [WxAssistantConfig saveValue:[NSNumber numberWithBool:envSwitch.on] forKey:AutoGetRedEnvKey];
    [self reloadTbData];
}

- (void)setDelaySeconds {
    UIAlertView *alertV = [UIAlertView new];
    alertV.title = @"抢红包延迟时间(秒)";
    alertV.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertV.delegate = self;
    [alertV addButtonWithTitle:@"取消"];
    [alertV addButtonWithTitle:@"确定"];
    [alertV textFieldAtIndex:0].placeholder = @"请输入延迟时间";
    [alertV textFieldAtIndex:0].keyboardType = UIKeyboardTypeDecimalPad;
    alertV.tag = 12;//(第1组第2个cell)
    [alertV show];
}

- (void)switchGetRedEnvSerial:(UISwitch *)serialSwitch {
    [WxAssistantConfig saveValue:[NSNumber numberWithBool:serialSwitch.on] forKey:NoGetRedEnvSerialKey];
}

- (void)showBlackList {
    NSArray *blackList = [WxAssistantConfig getValueForKey:BlackListKey];
    WxMultiSelectGroupsViewController *contactsViewController = [[WxMultiSelectGroupsViewController alloc] init];
    contactsViewController.blackList = blackList;
    contactsViewController.delegate = self;
    MMUINavigationController *navigationController = [[objc_getClass("MMUINavigationController") alloc] initWithRootViewController:contactsViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - 其他功能部分

//添加其他功能section
- (void)addOtherSection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"其他功能"];
    [sectionInfo addCell:[self stepCountCell1]];
    [sectionInfo addCell:[self stepCountCell2]];
    [sectionInfo addCell:[self locationCell1]];
    [sectionInfo addCell:[self locationCell2]];
    [self.tableViewInfo addSection:sectionInfo];
}

//是否修改当前定位
- (MMTableViewCellInfo *)stepCountCell1 {
    BOOL modifyStepCount = [[WxAssistantConfig getValueForKey:ModifyStepCountKey] boolValue];
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(modifyStepCount:) target:self title:@"自定义运动步数" on:modifyStepCount];
}

//修改微信运动步数
- (MMTableViewCellInfo *)stepCountCell2 {
    BOOL modifyStepCount = [[WxAssistantConfig getValueForKey:ModifyStepCountKey] boolValue];
    MMTableViewCellInfo *cellInfo;
    if (modifyStepCount) {
        unsigned long stepCount = [((NSNumber *)[WxAssistantConfig getValueForKey:StepCountKey]) unsignedLongValue];
        cellInfo = [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(modifyStepCountInfo) target:self title:@"微信运动步数" rightValue:[NSString stringWithFormat:@"%lu", (unsigned long)stepCount] accessoryType:1];
    } else {
        cellInfo = [objc_getClass("MMTableViewCellInfo") normalCellForTitle:@"微信运动步数" rightValue:@"功能已关闭"];
    }
    return cellInfo;
}

//是否修改当前定位
- (MMTableViewCellInfo *)locationCell1 {
    BOOL modifyLocation = [[WxAssistantConfig getValueForKey:ModifyLocationKey] boolValue];
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(modifyLocation:) target:self title:@"自定义位置定位" on:modifyLocation];
}

//修改当前定位
- (MMTableViewCellInfo *)locationCell2 {
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
    MMTableViewCellInfo *cellInfo;
    if (modifyLocation) {
        NSString *locationStr = [NSString stringWithFormat:@"经度%.2lf 纬度%.2lf", longitude, latitude];
        cellInfo = [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(modifyLocationInfo) target:self title:@"当前经纬度" rightValue:locationStr accessoryType:1];
    } else {
        cellInfo = [objc_getClass("MMTableViewCellInfo") normalCellForTitle:@"当前经纬度" rightValue:@"功能已关闭"];
    }
    return cellInfo;
}

- (void)modifyStepCount:(UISwitch *)stepCountSwitch {
    [WxAssistantConfig saveValue:[NSNumber numberWithBool:stepCountSwitch.on] forKey:ModifyStepCountKey];
    [self reloadTbData];
}

- (void)modifyStepCountInfo {
    UIAlertView *alertV = [UIAlertView new];
    alertV.title = @"微信运动步数";
    alertV.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertV.delegate = self;
    [alertV addButtonWithTitle:@"取消"];
    [alertV addButtonWithTitle:@"确定"];
    [alertV textFieldAtIndex:0].placeholder = @"请输入步数，最大值98800";
    [alertV textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    alertV.tag = 22;//(第2组第1个cell)
    [alertV show];
}

- (void)modifyLocation:(UISwitch *)locationSwitch {
    [WxAssistantConfig saveValue:[NSNumber numberWithBool:locationSwitch.on] forKey:ModifyLocationKey];
    [self reloadTbData];
}

- (void)modifyLocationInfo {
    UIAlertView *alertV = [UIAlertView new];
    alertV.title = @"微信当前位置";
    alertV.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    alertV.delegate = self;
    [alertV addButtonWithTitle:@"取消"];
    [alertV addButtonWithTitle:@"确定"];
    [alertV textFieldAtIndex:0].placeholder = @"请输入正确的经度";
    [alertV textFieldAtIndex:0].keyboardType = UIKeyboardTypeDecimalPad;
    [alertV textFieldAtIndex:1].placeholder = @"请输入正确的纬度";
    [alertV textFieldAtIndex:1].keyboardType = UIKeyboardTypeDecimalPad;
    [alertV textFieldAtIndex:1].secureTextEntry = NO;
    alertV.tag = 24;//(第2组第4个cell)
    [alertV show];
}

//alertView的代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ((alertView.tag == 12) && (buttonIndex == 1)) {
        float delaySeconds = [alertView textFieldAtIndex:0].text.floatValue;
        [WxAssistantConfig saveValue:[NSNumber numberWithFloat:delaySeconds] forKey:DelaySecondKey];
        [self reloadTbData];
    }
    if ((alertView.tag == 22) && (buttonIndex == 1)) {
        NSString *stepCountStr = [alertView textFieldAtIndex:0].text;
        if ([stepCountStr hasPrefix:@"-"]) {
            stepCountStr = @"0";
        }
        NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
        unsigned long stepCount = [[formatter numberFromString:stepCountStr] unsignedLongValue];
        //最大步数判定
        if (stepCount>98800) {
            stepCount = 98800;
        }
        [WxAssistantConfig saveValue:[NSNumber numberWithUnsignedInteger:stepCount] forKey:StepCountKey];
        [self reloadTbData];
    }
    if ((alertView.tag == 24) && (buttonIndex == 1)) {
        double longitude = [[alertView textFieldAtIndex:0].text doubleValue];
        double latitude = [[alertView textFieldAtIndex:1].text doubleValue];
        //经纬度范围判断
        if ((longitude < 0.0 || longitude > 180.0) || (latitude < 0.0 || latitude > 90.0)) {
            longitude = 113.663221;
            latitude = 34.7568711;
        }
        NSString *locationInfo = [NSString stringWithFormat:@"longitude=%.6lf&latitude=%.6lf", longitude, latitude];
        [WxAssistantConfig saveValue:locationInfo forKey:LocationInfoKey];
        [self reloadTbData];
    }
}

//当切换方式为present的时候关闭控制器
- (void)dismissVc {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MultiSelectGroupsViewControllerDelegate
- (void)onMultiSelectGroupCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onMultiSelectGroupReturn:(NSArray *)arg1 {
    [WxAssistantConfig saveValue:arg1 forKey:BlackListKey];
    [self reloadTbData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
