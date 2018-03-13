//
//  WxAccountListController.h
//  hkimmd
//
//  Created by musk on 4/6/14.
//  Copyright (c) 2014 musk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface WxAccountInfo : NSObject

//系统的username和自定义的不一样，微信系统的是wxid
@property (nonatomic, copy) NSString *userAccount;
@property (nonatomic, copy) NSString *userPwd;

+ (void)updateAccount:(WxAccountInfo *)ai;

@end

@interface WxAccountListController : UITableViewController

@property (nonatomic, assign) id parent;

@end
