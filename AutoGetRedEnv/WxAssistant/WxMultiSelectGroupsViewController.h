//
//  WxMultiSelectGroupsViewController.h
//  WeChatRedEnvelop
//
//  Created by musk on 2017/6/12.
//  Copyright © 2017年 musk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MultiSelectGroupsViewControllerDelegate <NSObject>
- (void)onMultiSelectGroupReturn:(NSArray *)arg1;

@optional
- (void)onMultiSelectGroupCancel;
@end

@interface WxMultiSelectGroupsViewController : UIViewController

//- (instancetype)initWithBlackList:(NSArray *)blackList;
@property (strong, nonatomic) NSArray *blackList;

@property (nonatomic, assign) id<MultiSelectGroupsViewControllerDelegate> delegate;

@end
