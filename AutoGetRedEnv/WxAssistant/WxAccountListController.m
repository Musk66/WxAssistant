//
//  AccountListController.m
//  hkimmd
//
//  Created by msuk on 4/6/14.
//  Copyright (c) 2014 musk. All rights reserved.
//

#import "WxAccountListController.h"
#import "NSDictionary+Keychain.h"
#import "WxDesUtil.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
//用户信息加密密钥
#define WxUIDesKey @"Z3MgdXNlciBpbmZvIGRlcyBrZXk=aly"
//Keychain的key
#define WxUIKCKey @"WxAccountList"

@implementation WxAccountInfo

+ (NSMutableArray *)getAccountList {
    static NSMutableArray *accountList = nil;
    if (accountList == nil) {
        accountList = [[NSMutableArray alloc] init];
    }
    [accountList removeAllObjects];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryFromKeychainWithKey:WxUIKCKey]];
    if (dict) {
        NSArray *array = [dict objectForKey:@"WxUser"];
        for (NSInteger i=0; i<array.count; i++) {
            NSDictionary *dict2 = [array objectAtIndex:i];
            WxAccountInfo *ai = [[WxAccountInfo alloc] init];
//            NSLog(@"解密的结果%@--%@", [self decrypt:[dict2 objectForKey:@"UserAccount"]], [self decrypt:[dict2 objectForKey:@"UserPwd"]]);
            ai.userAccount = [self decrypt:[dict2 objectForKey:@"UserAccount"]];
            ai.userPwd = [self decrypt:[dict2 objectForKey:@"UserPwd"]];
            [accountList addObject:ai];
        }
    }
    return accountList;
}

+ (void)updateAccountList:(NSArray *)accountList andFlag:(BOOL)flag {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableArray *arrary = [NSMutableArray array];
    for (NSInteger i = 0; i < accountList.count; i++) {
        WxAccountInfo *ai = [accountList objectAtIndex:i];
        NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
//        NSLog(@"加密的结果%@--%@", [self encrypt:ai.userAccount], [self encrypt:ai.userPwd]);
        [dict2 setValue:[self encrypt:ai.userAccount] forKey:@"UserAccount"];
        [dict2 setValue:[self encrypt:ai.userPwd] forKey:@"UserPwd"];
        [arrary addObject:dict2];
        [dict setObject:arrary forKey:@"WxUser"];
    }
    if (flag) {
        //清空keychain
        [dict deleteFromKeychainWithKey:WxUIKCKey];
    } else {
        [dict storeToKeychainWithKey:WxUIKCKey];
    }
}

+ (void)updateAccount:(WxAccountInfo *)ai {
    NSMutableArray *accountList = [WxAccountInfo getAccountList];
    BOOL isFind = NO;
    for (NSInteger i=0; i<accountList.count; i++) {
        WxAccountInfo *ai2 = [accountList objectAtIndex:i];
        if ([ai2.userAccount isEqualToString:ai.userAccount]) {
            [accountList replaceObjectAtIndex:i withObject:ai];
            isFind = YES;
            break;
        }
    }
    if (isFind == NO) {
        [accountList addObject:ai];
        isFind = YES;
    }
    [WxAccountInfo updateAccountList:accountList andFlag:NO];
}

+ (NSString *)encrypt:(NSString *)string {
    return [WxDesUtil encrypt:string withKey:WxUIDesKey];
}

+ (NSString *)decrypt:(NSString *)string {
    return [WxDesUtil decrypt:string withKey:WxUIDesKey];
}

@end

@interface WxAccountListController()
@property (nonatomic, strong) NSMutableArray *accountList;
@property (nonatomic, strong) UILabel *bottomTip;
@end

@implementation WxAccountListController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"账号列表";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0], NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(closeAIVc)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清空账号" style:UIBarButtonItemStyleDone target:self action:@selector(cleanAccount)];
    self.accountList = [WxAccountInfo getAccountList];
    self.tableView.rowHeight = 50;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 6)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)deleteAccount:(NSInteger)idx {
    if (idx >= 0 && idx < self.accountList.count) {
        [self.accountList removeObjectAtIndex:idx];
        [WxAccountInfo updateAccountList:self.accountList andFlag:NO];
    }
}

- (void)setAccount:(NSInteger)idx {
    if (self.parent != nil && [self.parent respondsToSelector:@selector(setAccount:)]) {
        if (idx >= 0 && idx < self.accountList.count) {
            [self.parent performSelector:@selector(setAccount:) withObject:[self.accountList objectAtIndex:idx]];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.accountList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.textLabel.textColor = [UIColor blackColor];
    WxAccountInfo *ai = [self.accountList objectAtIndex:indexPath.row];
    cell.textLabel.text = ai.userAccount;
    cell.imageView.image = [UIImage imageNamed:@"Icon@2x.png"];
    CGSize itemSize = CGSizeMake(36, 36);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    cell.imageView.layer.cornerRadius = 18;
    cell.imageView.layer.masksToBounds = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.accountList.count>0) {
        WxAccountInfo *ai = [self.accountList objectAtIndex:indexPath.row];
        if ((ai.userAccount.length>0) && (ai.userPwd.length>0)) {
            [self setAccount:indexPath.row];
            [self closeAIVc];
        } else {
//            NSLog(@"账号或者密码为空:%@--%@", ai.userAccount, ai.userPwd);
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates];
        [self deleteAccount:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

//返回
- (void)closeAIVc {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//清空账号
- (void)cleanAccount {
    if (self.accountList.count>0) {
        [self.accountList removeAllObjects];
        [WxAccountInfo updateAccountList:self.accountList andFlag:YES];
        [self.tableView reloadData];
    } else {
//        NSLog(@"清空账号错误！");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
