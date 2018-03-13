#pragma mark - Util

@interface WCBizUtil : NSObject

+ (id)dictionaryWithDecodedComponets:(id)arg1 separator:(id)arg2;

@end

@interface SKBuiltinBuffer_t : NSObject

@property(retain, nonatomic) NSData *buffer; // @dynamic buffer;

@end

#pragma mark - Message

@interface WCPayInfoItem: NSObject

@property(retain, nonatomic) NSString *m_c2cNativeUrl;

@end

@interface CMessageMgr : NSObject

- (void)AddLocalMsg:(id)arg1 MsgWrap:(id)arg2 fixTime:(_Bool)arg3 NewMsgArriveNotify:(_Bool)arg4;

@end

@interface CMessageWrap : NSObject

@property (retain, nonatomic) WCPayInfoItem *m_oWCPayInfoItem;
@property (assign, nonatomic) NSUInteger m_uiMesLocalID;
@property (retain, nonatomic) NSString* m_nsFromUsr;            ///< 发信人，可能是群或个人
@property (retain, nonatomic) NSString* m_nsToUsr;              ///< 收信人
@property (assign, nonatomic) NSUInteger m_uiStatus;
@property (retain, nonatomic) NSString* m_nsContent;            ///< 消息内容
@property (retain, nonatomic) NSString* m_nsRealChatUsr;        ///< 群消息的发信人，具体是群里的哪个人
@property (assign, nonatomic) NSUInteger m_uiMessageType;
@property (assign, nonatomic) long long m_n64MesSvrID;
@property (assign, nonatomic) NSUInteger m_uiCreateTime;
@property (retain, nonatomic) NSString *m_nsDesc;
@property (retain, nonatomic) NSString *m_nsAppExtInfo;
@property (assign, nonatomic) NSUInteger m_uiAppDataSize;
@property (assign, nonatomic) NSUInteger m_uiAppMsgInnerType;
@property (retain, nonatomic) NSString *m_nsShareOpenUrl;
@property (retain, nonatomic) NSString *m_nsShareOriginUrl;
@property (retain, nonatomic) NSString *m_nsJsAppId;
@property (retain, nonatomic) NSString *m_nsPrePublishId;
@property (retain, nonatomic) NSString *m_nsAppID;
@property (retain, nonatomic) NSString *m_nsAppName;
@property (retain, nonatomic) NSString *m_nsThumbUrl;
@property (retain, nonatomic) NSString *m_nsAppMediaUrl;
@property (retain, nonatomic) NSData *m_dtThumbnail;
@property (retain, nonatomic) NSString *m_nsTitle;
@property (retain, nonatomic) NSString *m_nsMsgSource;

- (id)initWithMsgType:(long long)arg1;
+ (_Bool)isSenderFromMsgWrap:(id)arg1;

@end

@interface MMServiceCenter : NSObject

+ (instancetype)defaultCenter;
- (id)getService:(Class)service;

@end

@interface MMLanguageMgr: NSObject

- (id)getStringForCurLanguage:(id)arg1 defaultTo:(id)arg2;


@end

#pragma mark - RedEnvelop

@interface WCRedEnvelopesControlData : NSObject

@property(retain, nonatomic) CMessageWrap *m_oSelectedMessageWrap;

@end

@interface WCRedEnvelopesLogicMgr: NSObject

- (void)OpenRedEnvelopesRequest:(id)params;
- (void)ReceiverQueryRedEnvelopesRequest:(id)arg1;
- (void)GetHongbaoBusinessRequest:(id)arg1 CMDID:(unsigned int)arg2 OutputType:(unsigned int)arg3;

/** Added Methods */
- (unsigned int)calculateDelaySeconds;

@end

@interface HongBaoRes : NSObject

@property(retain, nonatomic) SKBuiltinBuffer_t *retText; // @dynamic retText;
@property(nonatomic) int cgiCmdid; // @dynamic cgiCmdid;

- (id)init;

@end

@interface HongBaoReq : NSObject

@property(retain, nonatomic) SKBuiltinBuffer_t *reqText; // @dynamic reqText;
@property(nonatomic) unsigned int cgiCmd; // @dynamic cgiCmd;

@end

#pragma mark - Contact

@interface CContact: NSObject <NSCoding>

@property(retain, nonatomic) NSString *m_nsUsrName;
@property(retain, nonatomic) NSString *m_nsHeadImgUrl;
@property(retain, nonatomic) NSString *m_nsNickName;

- (id)getContactDisplayName;

@end

@interface CContactMgr : NSObject
- (id)getAllContactUserName;
- (id)getSelfContact;
- (id)getContactByName:(id)arg1;
- (id)getContactForSearchByName:(id)arg1;
- (_Bool)getContactsFromServer:(id)arg1;
- (_Bool)isInContactList:(id)arg1;
- (_Bool)addLocalContact:(id)arg1 listType:(unsigned int)arg2;

@end


#pragma mark - QRCode

@interface ScanQRCodeLogicController: NSObject

@property(nonatomic) unsigned int fromScene;
- (id)initWithViewController:(id)arg1 CodeType:(int)arg2;
- (void)tryScanOnePicture:(id)arg1;
- (void)doScanQRCode:(id)arg1;
- (void)showScanResult;

@end

@interface NewQRCodeScanner: NSObject

- (id)initWithDelegate:(id)arg1 CodeType:(int)arg2;
- (void)notifyResult:(id)arg1 type:(id)arg2 version:(int)arg3;

@end

#pragma mark - MMTableView

@interface MMTableViewInfo

- (id)getTableView;
- (void)clearAllSection;
- (void)addSection:(id)arg1;
- (void)insertSection:(id)arg1 At:(unsigned int)arg2;

@end

@interface MMTableViewSectionInfo

+ (id)sectionInfoDefaut;
+ (id)sectionInfoHeader:(id)arg1;
+ (id)sectionInfoHeader:(id)arg1 Footer:(id)arg2;
- (void)addCell:(id)arg1;

@end

@interface MMTableViewCellInfo

+ (id)normalCellForTitle:(id)arg1 rightValue:(id)arg2;
+ (id)normalCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 accessoryType:(long long)arg4;
+ (id)normalCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 rightValue:(id)arg4 accessoryType:(long long)arg5;
+ (id)switchCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 on:(_Bool)arg4;
+ (id)editorCellForSel:(SEL)arg1 target:(id)arg2 title:(id)arg3 margin:(float)arg4 tip:(id)arg5 focus:(BOOL)arg6 text:(id)arg7;
+ (id)urlCellForTitle:(id)arg1 url:(id)arg2;

@end

@interface MMTableViewCell : UIView
@end

@interface MMTableView: UITableView
- (id)indexPathForCell:(id)cell;
@end

#pragma mark - UI
@interface MMUICommonUtil : NSObject

+ (id)getBarButtonWithTitle:(id)arg1 target:(id)arg2 action:(SEL)arg3 style:(int)arg4;

@end

@interface MMLoadingView : UIView

@property(retain, nonatomic) UILabel *m_label; // @synthesize m_label;
@property (assign, nonatomic) BOOL m_bIgnoringInteractionEventsWhenLoading; // @synthesize m_bIgnoringInteractionEventsWhenLoading;

- (void)setFitFrame:(long long)arg1;
- (void)startLoading;
- (void)stopLoading;
- (void)stopLoadingAndShowError:(id)arg1;
- (void)stopLoadingAndShowOK:(id)arg1;


@end

@interface MMWebViewController: NSObject

- (id)initWithURL:(id)arg1 presentModal:(_Bool)arg2 extraInfo:(id)arg3;

@end


@protocol ContactSelectViewDelegate <NSObject>
- (void)onSelectContact:(CContact *)arg1;
@end

@interface ContactSelectView : UIView

@property(nonatomic) unsigned int m_uiGroupScene; // @synthesize m_uiGroupScene;
@property(nonatomic) _Bool m_bMultiSelect; // @synthesize m_bMultiSelect;
@property(retain, nonatomic) NSMutableDictionary *m_dicMultiSelect; // @synthesize m_dicMultiSelect;

- (id)initWithFrame:(struct CGRect)arg1 delegate:(id)arg2;
- (void)initData:(unsigned int)arg1;
- (void)initView;
- (void)addSelect:(id)arg1;

@end

@interface ContactsDataLogic : NSObject
@property(nonatomic) unsigned int m_uiScene; // @synthesize m_uiScene;
@end

@interface MMUINavigationController : UINavigationController

@end

#pragma mark - UtilCategory

@interface NSMutableDictionary (SafeInsert)
- (void)safeSetObject:(id)arg1 forKey:(id)arg2;
@end

@interface NSDictionary (NSDictionary_SafeJSON)

- (id)arrayForKey:(id)arg1;
- (id)dictionaryForKey:(id)arg1;
- (double)doubleForKey:(id)arg1;
- (float)floatForKey:(id)arg1;
- (long long)int64ForKey:(id)arg1;
- (long long)integerForKey:(id)arg1;
- (id)stringForKey:(id)arg1;

@end

@interface NSString (NSString_SBJSON)

- (id)JSONArray;
- (id)JSONDictionary;
- (id)JSONValue;

@end

#pragma mark - UICategory

@interface UINavigationController (LogicController)

- (void)PushViewController:(id)arg1 animated:(_Bool)arg2;

@end

@interface MMUIViewController : UIViewController

- (void)startLoadingBlocked;
- (void)startLoadingNonBlock;
- (void)startLoadingWithText:(NSString *)text;
- (void)stopLoading;
- (void)stopLoadingWithFailText:(NSString *)text;
- (void)stopLoadingWithOKText:(NSString *)text;

@end

@interface NewSettingViewController: MMUIViewController
- (void)reloadTableData;
@end

@interface ContactInfoViewController : MMUIViewController
@property(retain, nonatomic) CContact *m_contact; // @synthesize m_contact;
@end

@protocol MultiSelectContactsViewControllerDelegate <NSObject>
- (void)onMultiSelectContactReturn:(NSArray *)arg1;

@optional
- (int)getFTSCommonScene;
- (void)onMultiSelectContactCancelForSns;
- (void)onMultiSelectContactReturnForSns:(NSArray *)arg1;
@end

@interface MultiSelectContactsViewController : UIViewController

@property(nonatomic) _Bool m_bKeepCurViewAfterSelect; // @synthesize m_bKeepCurViewAfterSelect=_m_bKeepCurViewAfterSelect;
@property(nonatomic) unsigned int m_uiGroupScene; // @synthesize m_uiGroupScene;
@property(nonatomic, weak) id <MultiSelectContactsViewControllerDelegate> m_delegate; // @synthesize m_delegate;

@end

@interface JailBreakHelper : NSObject
- (BOOL)HasInstallJailbreakPlugin:(id)arg1;
- (BOOL)HasInstallJailbreakPluginInvalidIAPPurchase;
- (BOOL)IsJailBreak;
@end

@interface WCDataItem : NSObject
@property(nonatomic) BOOL isLikeUsersUnsafe; // @synthesize isLikeUsersUnsafe=m_isLikeUsersUnsafe;
@property(retain, nonatomic) NSString *username; // @synthesize username;
@property(retain, nonatomic) NSString *nickname; // @synthesize nickname;
@property(retain, nonatomic) NSMutableArray *likeUsers;
@end

/*
#pragma mark - 点赞部分

@interface FIFOFileQueue : NSObject
-(BOOL)push:(id)push;
-(id)getAll;
@end

@interface WCCommentUploadMgr : NSObject
-(void)tryStartNextTask;
-(void)pushBackTopTask;
-(void)popTopTask;
-(void)addComment:(id)comment;
-(void)addCommentToWCObjectCache:(id)wcobjectCache;
@end

@interface WCCommentItem : NSObject
@property(retain, nonatomic) NSString* clientID;
@property(assign, nonatomic) unsigned inQueueTime;
@property(assign, nonatomic) unsigned createTime;
@property(assign, nonatomic) int source;
@property(assign, nonatomic) int type;
@property(retain, nonatomic) NSString* content;
@property(retain, nonatomic) NSString* itemID;
@property(retain, nonatomic) NSString* toUserName;
@end

@interface WCAdvertiseInfo : NSObject
@end
//@class MMUIButton;
@interface WCDataItem : NSObject
@property(assign, nonatomic) BOOL likeFlag;
@property(retain, nonatomic) NSString* username;
@property(retain, nonatomic) NSString* tid;
@property(retain, nonatomic) WCAdvertiseInfo* advertiseInfo;
@property(retain, nonatomic) NSMutableArray *likeUsers;
-(id)itemID;
@end

@interface WCLikeButton : NSObject
@property(retain, nonatomic) WCDataItem* m_item;
//点赞取消触发方法
-(void)LikeBtnReduceEnd;
//用于初始化
-(id)initWithDataItem:(id)dataItem;
@end

@interface SettingUtil : NSObject
+(id)getCurUsrName;
@end

@interface WCFacade : NSObject
-(WCDataItem *)getTimelineDataItemOfIndex:(int)index;
//点赞内部调用,这里不用到
-(void)likeObject:(id)object ofUser:(id)user source:(int)source;
////点赞内部调用,这里不用到
-(BOOL)unLikeObject:(id)object ofUser:(id)user;
@end

@interface WCTimeLineViewController : NSObject
-(int)calcDataItemIndex:(int)index;
-(void)ccStartAutoLike;
-(void)ccUpdateDataItemsWithNumber:(int)number;
-(void)ccStartQueueToLike;
-(void)reloadTableView;
@end
*/

#pragma mark - 切换账号部分
//切换账号
@interface WCBaseTextFieldItem : NSObject
- (void)setText:(id)arg1;
- (NSString *)getValue;
@end

@interface WCAccountLoginControlLogic : NSObject
- (void)onLastUserLoginUserName:(id)arg1 Pwd:(id)arg2;
@end

@class NSString;
@protocol WCAccountLoginLastUserViewControllerDelegate <NSObject>
- (void)onLastUserChangeAccount;
- (void)onLastUserRegister;
- (void)onForgetPwd;
- (void)onLastUserLoginUserName:(NSString *)arg1 Pwd:(NSString *)arg2;
@end

@interface WCAccountLoginLastUserViewController : UIViewController
{
    UILabel *m_labelUserName;
    WCBaseTextFieldItem *m_textFieldPwdItem;
}
- (void)onNext;
@end

@interface WCAccountLoginFirstUserViewController : UIViewController
{
    WCBaseTextFieldItem *m_textFieldUserNameItem;
    WCBaseTextFieldItem *m_textFieldPwdItem;
}
- (void)onNext;
@end

