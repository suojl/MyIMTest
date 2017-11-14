//
//  ZCUIChatVC.m
//  SobotKit
//
//  Created by zhangxy on 16/8/1.
//  Copyright © 2016年 zhichi. All rights reserved.
//

#import "ZCUIChatVC.h"


#define BottomHeight       49
#define TableSectionHeight 34
#define DATA_PAGE_SIZE     20

#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"

#import "ZCChatBaseCell.h"
#import "ZCRichTextChatCell.h"
#import "ZCImageChatCell.h"
#import "ZCVoiceChatCell.h"
#import "ZCTipsChatCell.h"
#import "ZCGoodsCell.h"

#import "ZCUIChatKeyboard.h"
#import "ZCUIXHImageViewer.h"
#import "ZCUIConfigManager.h"
#import "ZCUIKitManager.h"

#import "ZCUILoading.h"
#import "ZCLibNetworkTools.h"
#import "ZCUIVoiceTools.h"

#import "ZCUICustomActionSheet.h"
#import "ZCActionSheet.h"
#import "ZCUILeaveMessageController.h"

#import "ZCUIWebController.h"

#import "ZCLibSkillSet.h"

#define cellRichTextIdentifier @"ZCRichTextChatCell"
#define cellImageIdentifier @"ZCImageChatCell"
#define cellVoiceIdentifier @"ZCVoiceChatCell"
#define cellTipsIdentifier @"ZCTipsChatCell"
#define cellGoodsIndentifier @"ZCGoodsCell"

#define VoiceLocalPath zcLibGetDocumentsFilePath(@"/sobot/")


typedef NS_ENUM(NSInteger, ButtonClickTag) {
    BUTTON_BACK   = 1, // 返回
    BUTTON_CLOSE  = 2, // 关闭
    BUTTON_UNREAD = 3, // 未读消息
    BUTTON_MORE   = 4, // 未读消息
};

typedef NS_ENUM(NSInteger,ExitType) {
    ISCOLSE         = 1,// 直接退出SDK
    ISNOCOLSE       = 2,// 不直接退出SDK
    ISBACKANDUPDATE = 3,// 仅人工模式 点击技能组上的留言按钮后,（返回上一页面 提交退出SDK）
    ISROBOT         = 4,// 机器人优先，点击技能组的留言按钮后，（返回技能组 提交和机器人会话）
    ISUSER          = 5,// 人工优先，点击技能组的留言按钮后，（返回技能组 提交机器人会话）
};

/**
 *  keyboardType ENUM
 */
typedef NS_ENUM(NSUInteger,keyboardType){
    /** 机器人键盘样式 */
    ROBOTSTATUS            = 1,
    /** 新会话键盘样式 */
    AGAINACCESSASTATUS     = 2,
    /** 仅人工，排队的键盘样式 */
    WAITSTATUS             = 3,
    /** 仅人工，客服不在线的键盘样式 */ 
    ONLYUSERNOLINESTATUS   = 4,
};

@interface ZCUIChatVC ()<UITableViewDelegate,UITableViewDataSource,ZCUIChatDelegate,ZCUIVoiceDelegate,ZCUIBackActionSheetDelegate,ZCActionSheetDelegate,ZCUIBackActionSheetDelegate,ZCChatCellDelegate>{
    CGFloat viewHeigth;
    CGFloat viewWidth;
    BOOL navBarHide;
   
    UIButton    *_newWorkStatusButton;  // 没有网络提醒button
    UIButton    *_goUnReadButton;
    
    
    int             pageSize;
    
    void (^PageClickBlock)(id object,ZCPageBlockType type);
    void (^LinkedClickBlock)(NSString *url);
    
    
    // 以下为新消息对象
    ZCLibMessage    *lineModel;
    
    // 播放临时model，用于停止播放状态改变
    ZCLibMessage    *playModel;
    
    UIImageView     *animateView;
    
    // 旋转时隐藏
    ZCUIXHImageViewer *xhObj;
    CGFloat           keyBoardHeight;

    NSString          *callURL;

    
}


@property (nonatomic,retain)  UIRefreshControl *refreshControl NS_AVAILABLE_IOS(6_0);
@property (nonatomic,assign)  BOOL             isInitLoading;
@property (nonatomic,strong)  ZCUIChatKeyboard *zcKeyboardView; // 键盘的View
@property (nonatomic ,assign) int             pageNum;
@property (nonatomic ,strong)  NSMutableArray  *listArray;
@property (nonatomic ,assign) BOOL            isNoMore;

@property (nonatomic ,strong)  ZCLibMessage *sendMessage;
/** 未知说辞计数*/
@property (nonatomic, assign) NSUInteger      unknownWordsCount;

@property (nonatomic, assign) BOOL     isTurnLoading;
@property (nonatomic, strong) ZCUIVoiceTools *voiceTools;


@property (nonatomic ,strong)  NSString       *receivedName;

@end

@implementation ZCUIChatVC


// 横竖屏切换
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait ||toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        
        CGFloat c = viewWidth;
        if(viewWidth > viewHeigth){
            viewWidth = viewHeigth;
            viewHeigth = c;
            
            [_listTable reloadRowsAtIndexPaths:_listTable.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
            
            if(xhObj){
                [xhObj tappedScrollView:nil];
            }
        }
        
    }else{
        
        CGFloat c = viewHeigth;
        if(viewWidth < viewHeigth){
            viewHeigth = viewWidth;
            viewWidth = c;
            
            
            [_listTable reloadRowsAtIndexPaths:_listTable.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
            
            if(xhObj){
                [xhObj tappedScrollView:nil];
            }
        }
    }
}


-(ZCUIConfigManager *)getShareMS{
    return [[ZCUIKitManager getZCKitManager] getZCUIConfigMS];
}

-(ZCLibServer *)getZCLibServer{
    return [[self getShareMS] getZCLibServer];
}

-(ZCLibConfig *) getZCLibConfig{
    return [self getShareMS].libConfig;
}


#pragma mark 创建UI
-(void)createView{
    if(viewHeigth>0 && viewWidth>0){
        self.view.frame = CGRectMake(0, 0, viewWidth, viewHeigth);
    }else{
        viewWidth  = self.view.frame.size.width;
        viewHeigth = self.view.frame.size.height;
    }
    
    // 横竖屏问题
    
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    
    if(viewWidth>viewHeigth){
        viewWidth = viewHeigth;
        viewHeigth = self.view.frame.size.width;
        
        self.view.frame = CGRectMake(0, 0, viewWidth, viewHeigth);
    }
    
    self.view.clipsToBounds = YES;
    
    [self createTitleView];
    
    [self.backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if (self.zckitInfo.isKeepSession) {
        self.backButton.tag = BUTTON_BACK;
    }else{
        // 关闭
        [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_isClose"] forState:UIControlStateNormal];
        [self.backButton setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_isCloseSeleted"] forState:UIControlStateHighlighted];
        [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(15, 5, 10, 45)];
        [self.backButton setTitle:@"关闭" forState:UIControlStateNormal];
        [self.backButton setTitleEdgeInsets:UIEdgeInsetsMake(6, 3, 0, 0)];
        [self.backButton.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
        [self.backButton setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
        [self.backButton setFrame:CGRectMake(0, NavBarHeight-44, 70, 44)];
        [self.topView addSubview:self.backButton];
        self.backButton.tag = BUTTON_CLOSE;
    }
    // 关闭
    [self.closeButton setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_btnmore"] forState:UIControlStateNormal];
    [self.closeButton setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_btnmore_press"] forState:UIControlStateHighlighted];
    self.closeButton.tag = BUTTON_MORE;
    [self.closeButton setTitle:@"" forState:UIControlStateNormal];
    [self.closeButton setHidden:NO];
    [self.closeButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _listTable=[[UITableView alloc] initWithFrame:CGRectMake(0, NavBarHeight, viewWidth, viewHeigth-NavBarHeight-BottomHeight)];
    [_listTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _listTable.delegate=self;
    _listTable.dataSource=self;
    [_listTable registerClass:[ZCRichTextChatCell class] forCellReuseIdentifier:cellRichTextIdentifier];
    [_listTable registerClass:[ZCImageChatCell class] forCellReuseIdentifier:cellImageIdentifier];
    [_listTable registerClass:[ZCVoiceChatCell class] forCellReuseIdentifier:cellVoiceIdentifier];
    [_listTable registerClass:[ZCTipsChatCell class] forCellReuseIdentifier:cellTipsIdentifier];
    [_listTable registerClass:[ZCGoodsCell class] forCellReuseIdentifier:cellGoodsIndentifier];
    
    
    [_listTable setSeparatorColor:[UIColor clearColor]];
    [_listTable setBackgroundColor:[UIColor clearColor]];
    _listTable.clipsToBounds=NO;
    [self.view addSubview:_listTable];
    [self.view insertSubview:_listTable atIndex:0];
    
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [_listTable setTableFooterView:view];
    
    
    _newWorkStatusButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_newWorkStatusButton setFrame:CGRectMake(0, NavBarHeight, viewWidth, 40)];
    [_newWorkStatusButton setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_tag_nonet"] forState:UIControlStateNormal];
    [_newWorkStatusButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_newWorkStatusButton setBackgroundColor:[UIColor colorWithWhite:30 alpha:0.2]];
    [_newWorkStatusButton setTitle:[NSString stringWithFormat:@"  %@",NetWorkNotReachable] forState:UIControlStateNormal];
    [_newWorkStatusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_newWorkStatusButton.titleLabel setFont:[ZCUITools zcgetListKitDetailFont]];
    [self.view addSubview:_newWorkStatusButton];
    _newWorkStatusButton.hidden=YES;
    
    
    _goUnReadButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [_goUnReadButton setFrame:CGRectMake(viewWidth - 120, NavBarHeight+40, 140, 40)];
    [_goUnReadButton setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_tag_nonet"] forState:UIControlStateNormal];
    [_goUnReadButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_goUnReadButton setTitleColor:[ZCUITools zcgetDynamicColor] forState:UIControlStateNormal];
    [_goUnReadButton.titleLabel setFont:[ZCUITools zcgetListKitDetailFont]];
    [_goUnReadButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [_goUnReadButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    _goUnReadButton.layer.cornerRadius = 20;
    _goUnReadButton.layer.borderWidth = 0.75f;
    _goUnReadButton.layer.borderColor = [ZCUITools zcgetBackgroundBottomColor].CGColor;
    _goUnReadButton.layer.masksToBounds = YES;
    [_goUnReadButton setBackgroundColor:[UIColor whiteColor]];
    _goUnReadButton.tag = BUTTON_UNREAD;
    [_goUnReadButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_goUnReadButton];
    _goUnReadButton.hidden=YES;
    
    
    _zcKeyboardView = [[ZCUIChatKeyboard alloc] init];

    [_zcKeyboardView InitConfigView:self.view table:_listTable delegate:self];

    [[self getShareMS] setKeyboardView:_zcKeyboardView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [_zcKeyboardView handleKeyboard];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netWorkChanged:) name:ZCNotification_NetworkChange object:nil];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(!navBarHide){
        [self.navigationController setNavigationBarHidden:NO];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if(_voiceTools){
        [_voiceTools stopVoice];
    }
    self.navigationController.toolbarHidden = YES;
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    navBarHide=self.navigationController.navigationBarHidden;
    
    [self.navigationController setNavigationBarHidden:YES];
    
    // table 置顶
    if (iOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        // 设置页面不能使用边缘手势关闭
        if(self.navigationController!=nil){
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }
    
    
    [self createView];
    
    // 通知外部可以更新UI
    if(PageClickBlock){
        PageClickBlock(self,ZCPageBlockLoadFinish);
    }
    
    _listArray = [[NSMutableArray alloc] init];
    _pageNum    = 1;
    pageSize   = 30;
    [[self getZCLibServer] setHost:self.zckitInfo.apiHost];

    
    // 判断初始化信息
    [self createInitData];
    
    // 播放音频初始化
    _voiceTools = [[ZCUIVoiceTools alloc] init];
    _voiceTools.delegate = self;
    
    // 网络监听
    [ZCLibNetworkTools shareNetworkTools];
}

#pragma mark -- 根据初始化数据创建 （会话保持的参数的逻辑判定）

-(void) createInitData{
    
    BOOL isReConnectInit = NO;
    
    // 接入的技能组不相同，重新初始化
    NSString *groupId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserDefaultGroupID"];
    if(![@"" isEqual:zcLibConvertToString(self.zckitInfo.skillSetId)]){
        // 不相同，则重新初始化
        if(![zcLibConvertToString(groupId) isEqual:zcLibConvertToString(self.zckitInfo.skillSetId)]){
            [[NSUserDefaults standardUserDefaults] setObject:self.zckitInfo.skillSetId forKey:@"UserDefaultGroupID"];
            isReConnectInit = YES;
        }
    }
    
    if (![zcLibConvertToString(self.zckitInfo.info.sourceURL) isEqualToString:@""] && ![zcLibConvertToString(self.zckitInfo.info.sourceTitle) isEqualToString:@""]) {
        if([[[self getShareMS] sourceURL] isEqual:zcLibConvertToString(self.zckitInfo.info.sourceURL)] &&[[[self getShareMS] sourceTitle] isEqual:zcLibConvertToString(self.zckitInfo.info.sourceTitle)]){
            isReConnectInit = YES;
        }
        
    }
    [self getShareMS].sourceURL   = self.zckitInfo.info.sourceURL;
    [self getShareMS].sourceTitle = self.zckitInfo.info.sourceTitle;
    
    NSString *serviceMode = [NSString stringWithFormat:@"%zd",self.zckitInfo.info.serviceMode];
    NSString *modelType = [NSString stringWithFormat:@"%zd",[self getZCLibConfig].type ] ;
    // 会话已经保持，但是接入模式不相同,并且不是人工时  && ![self getZCLibConfig].isArtificial
    if([[self getShareMS] isBeKeepSession] && (serviceMode!= nil && [serviceMode intValue]!=0 && (![serviceMode isEqualToString:modelType])) && ![self getZCLibConfig].isArtificial ){
        isReConnectInit = YES;
    }
    if (![self.zckitInfo.info.userId isEqualToString:[self getShareMS].userId]) {
        isReConnectInit = YES;
        [self getShareMS].userId = self.zckitInfo.info.userId;
    }
    
    //没有会话保持， 或者保持的groupId不相同，重新初始化
    
    if(!self.zckitInfo.isKeepSession
       || ![[self getShareMS] isBeKeepSession]
       || isReConnectInit){
        
        // 还原所有设置
        [[self getShareMS]setIsEvaluationService:NO];
        [[self getShareMS]setIsEvaluationRobot:NO];
        
        // 展示智齿loading
        [[ZCUILoading shareZCUILoading] showAddToSuperView:self.view];
        // 初始化数据
        [self InitData:NO];
    }else{
        [[self getShareMS] reStartNewsCount];
        
        // 设置初始化页面
        [self setInitView];
        
        [self getShareMS].delegate  = self;
        
        // 添加新数据
        [_listArray addObjectsFromArray:[[self getShareMS] getHisttoryArray]];
        
        
        //  判断未读消息数
        int unReadNum = [[self getShareMS] getUnReadNum];
        
        if(unReadNum>=10){
            [_goUnReadButton setTitle:[NSString stringWithFormat:@" %d条未读消息",unReadNum] forState:UIControlStateNormal];
            _goUnReadButton.hidden = NO;
            
            lineModel = [self setNetDataToArr:ZCTipCellMessageNewMessage type:0 name:@"" face:@"" tips:2 content:nil];
            [_listArray insertObject:lineModel atIndex:_listArray.count+1 - unReadNum];
        }
        if([self getZCLibConfig].isArtificial){
            [self.titleLabel setText:[[self getShareMS] getPageTitle]];
        }
        
        // 仅人工 排队状态
        if ([self getZCLibConfig].type == 2) {
            if (_listArray != nil) {
                if ([[_listArray lastObject] tipStyle]  == ZCReceivedMessageWaiting) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [_zcKeyboardView setRobotViewStatusType:WAITSTATUS];
                    });
                    
                    [self.titleLabel setText:@"排队中..."];
                }
            }
            
        }
        
        if(_listArray!=nil && _listArray.count>0){
            int index = -1;
            for (int i = 0; i< _listArray.count; i++) {
                ZCLibMessage *libMassage = _listArray[i];
                // 删除上一次商品信息
                if(libMassage.tipStyle == ZCReceivedMessageUnKonw){
                    index = i;
                    break;
                }
            }
            
            if(index >= 0){
                [_listArray removeObjectAtIndex:index];
            }
        }
        
        if(_listArray.count == 0){
            _isNoMore = YES;
        }
        // 显示商品信息
        if(![@"" isEqual:zcLibConvertToString(self.zckitInfo.goodsTitle)] && ![@"" isEqual:zcLibConvertToString(self.zckitInfo.goodsSendText)] && [self getZCLibConfig].isArtificial ){
            [_listArray addObject:[self setNetDataToArr:ZCTipCellMessageNullMessage type:0 name:@"" face:@"" tips:ZCReceivedMessageUnKonw content:nil]];
        }
        
        
        [_listTable reloadData];
        [self scrollTableToBottom];
    }
}



-(void)InitData:(BOOL) isReConnect{
    [ZCLogUtils logHeader:LogHeader debug:@"初始化方法调用"];
    
    _isInitLoading = YES;
    _pageNum = 1;
    
    NSString *groupId = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserDefaultGroupID"];
    if(![@"" isEqual:zcLibConvertToString(groupId)]){
        groupId = self.zckitInfo.skillSetId;
    }
    self.zckitInfo.info.groupId = zcLibConvertToString(groupId);
    
    [[self getShareMS] setWaitModel:nil];
    [[self getShareMS] setZCKitInfo:self.zckitInfo];
    
    
    __weak ZCUIChatVC *safeSelf = self;
    
    [[[safeSelf getShareMS] getZCLibServer] initWithSysNum:safeSelf.zckitInfo.info success:^(ZCLibConfig *config) {
               [ZCLogUtils logHeader:LogHeader debug:@"%@",config];
               // 同步config到单例对象
               [safeSelf getShareMS].libConfig=config;
        

               // 同步是否是拉黑
               [[safeSelf getShareMS] setOfflineBeBlack:config.isblack];
               
               // 必须设置，不然收不到消息
               [safeSelf getShareMS].delegate = safeSelf;

               [safeSelf setInitView];
                // 智齿loading消失
               [[ZCUILoading shareZCUILoading] dismiss];
             
               // 没有链接过，并且当前模式是仅人工模式，人工客服不在线
               if((config.type != 2 && !isReConnect) || isReConnect){
           
                   [safeSelf refreshData];
               }
     
           } error:^(ZCStatusCode status) {
               [ZCLogUtils logHeader:LogHeader debug:@"也执行失败了%zd",status];
               if(isReConnect){
                   [safeSelf.zcKeyboardView setRobotViewStatusType:AGAINACCESSASTATUS];
               }else{
                   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                       [safeSelf goBack:YES];
                   });
               }
               safeSelf.isInitLoading=NO;
           } sysNumIncorrect:^(NSString *inEnterpriseId) {
               if(isReConnect){
                   [safeSelf.zcKeyboardView setRobotViewStatusType:AGAINACCESSASTATUS];
               }else{
                   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                       [safeSelf goBack:YES];
                   });
               }
               safeSelf.isInitLoading=NO;
           }];
}


#pragma mark 获取智齿消息监听
-(void)onReceivedMessage:(ZCLibMessage *)message nickName:(NSString *)receiceName{
    if(receiceName != nil){
        _receivedName = message.senderName;
        
        if ([self getZCLibConfig].type == 2 && [self.titleLabel.text isEqualToString:@"排队中..."] && ![self getZCLibConfig].isArtificial) {
            _receivedName = ZCSTLocalString(@"NoAccess");
        }
        [self.titleLabel setText:_receivedName];
    }
    
    
    
    // 排队
    if (message.tipStyle == ZCReceivedMessageWaiting) {
        if ([self getZCLibConfig].type == 2) {
            _receivedName = @"排队中...";
        }
        // 先清掉人工不在时的留言Tipcell
        if (_listArray !=nil && _listArray.count>0) {
            NSMutableArray *indexs = [[NSMutableArray alloc] init];
            for (int i = (int)_listArray.count-1; i>=0 ; i--) {
                ZCLibMessage *libMassage = _listArray[i];
                if ( [libMassage.sysTips hasSuffix:@"留言"]) {
                    [indexs addObject:[NSString stringWithFormat:@"%d",i]];
                }
                
            }
            if(indexs.count>0){
                for (NSString *index in indexs) {
                    [_listArray removeObjectAtIndex:[index intValue]];
                }
            }
            [indexs removeAllObjects];
        }
        
        
        if (_listArray!=nil && _listArray.count>0) {
            int index = -1;
            for (int i = ((int)_listArray.count-1); i >= 0 ; i--) {
                //注意 libMassage 和 message 之间的区别
                ZCLibMessage *libMassage = _listArray[i];
                if (libMassage.tipStyle == ZCReceivedMessageWaiting) {
                    
                    index = i;
                    break;
                }
            }
            if (index>=0) {
                [_listArray removeObjectAtIndex:index];
            }
            
        }
    }
    
    // 转人工成功之后清理掉所有的留言入口
    if (message.tipStyle == ZCReceivedMessageOnline) {
        
        if (_listArray !=nil) {
            NSString *indexs = @"";
            for (int i = (int)_listArray.count-1; i>=0; i--) {
                ZCLibMessage *libMassage = _listArray[i];
                
                // 删除上一条留言信息
                if ([libMassage.sysTips hasSuffix:@"留言"]) {
                    indexs = [indexs stringByAppendingFormat:@",%d",i];
                }else if(libMassage.tipStyle == ZCReceivedMessageUnKonw){
                    // 删除上一次商品信息
                    indexs = [indexs stringByAppendingFormat:@",%d",i];
                }
            }
            if(indexs.length>0){
                indexs = [indexs substringFromIndex:1];
                for (NSString *index in [indexs componentsSeparatedByString:@","]) {
                    [_listArray removeObjectAtIndex:[index intValue]];
                }
            }
        }
    }
    
    [_listArray addObject:message];
    
    
    /**
     *  <#Description#>
     */
    if(message.richModel!=nil && message.richModel.msgType == 0 && [message.richModel.msg isEqual:[self getZCLibConfig].adminHelloWord]){
        if(![@"" isEqual:zcLibConvertToString(self.zckitInfo.goodsTitle)] && ![@"" isEqual:zcLibConvertToString(self.zckitInfo.goodsSendText)]){
            [_listArray addObject:[self setNetDataToArr:ZCTipCellMessageNullMessage type:0 name:@"" face:@"" tips:ZCReceivedMessageUnKonw content:nil]];
        }
    }
    
    [_listTable reloadData];
    [self scrollTableToBottom];
}



// 接收链接状态
-(void)onConnectStatusChanged{
    if(self.navigationController){
        [[ZCUIToastTools shareToast] showToast:@"您打开了新窗口，本次会话结束" duration:1.0f view:self.view.window.rootViewController.view position:ZCToastPositionCenter];
    }else{
        [[ZCUIToastTools shareToast] showToast:@"您打开了新窗口，本次会话结束" duration:1.0f view:self.view position:ZCToastPositionCenter];
    }
}


#pragma mark -- 刷新
-(void)refreshData{
    
    NSString *t = nil;
    if(_listArray.count>0){
        //        ZCLibMessage *model=[_listArray objectAtIndex:0];
        
        for (int i = 0; i<_listArray.count ; i++) {
            ZCLibMessage *models = [_listArray objectAtIndex:i];
            if ([models.t length]> 10) {
                t = models.t;
                break;
            }
        }
        
    }
    
    BOOL isShowRobotHello = NO;
    if(![self getZCLibConfig].isArtificial && [self getZCLibConfig].type!=4 && [self getZCLibConfig].type !=2 && [self getZCLibConfig].ustatus!=1 && [self getZCLibConfig].ustatus!=-2){
        isShowRobotHello = YES;
    }
 
     __weak ZCUIChatVC *safeSelf = self;
    [[[safeSelf getShareMS] getZCLibServer] getHistoryMessages:t pageSize:pageSize config:[safeSelf getZCLibConfig] start:^{
        
    } success:^(NSMutableArray *messages, ZCNetWorkCode sendCode) {
        if([safeSelf.refreshControl isRefreshing]){
            [safeSelf.refreshControl endRefreshing];
        }
        
        if(messages && messages.count>0){
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:
                                    NSMakeRange(0,[messages count])];
            [safeSelf.listArray insertObjects:messages atIndexes:indexSet];
            
            [ZCLogUtils logHeader:LogHeader debug:@"当前页码：%d",safeSelf.pageNum];
            if(safeSelf.pageNum==1){
                
                // 第一次加载完成，添加问候语
                if(isShowRobotHello){
                    
                    [safeSelf setNetDataToArr:ZCTipCellMessageRobotHelloWord type:0 name:@"" face:@"" tips:0 content:nil];
                }else{
                    [safeSelf scrollTableToBottom];
                }
            }
            
            if(safeSelf.pageNum>1){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    CGRect  popoverRect = [safeSelf.listTable rectForRowAtIndexPath:[NSIndexPath indexPathForRow:messages.count inSection:0]];
                    [safeSelf.listTable setContentOffset:CGPointMake(0,popoverRect.origin.y-20) animated:NO];
                });
            }
        
            safeSelf.pageNum = safeSelf.pageNum+1;
        }else{
            safeSelf.isNoMore=YES;
            // 第一次加载完成，添加问候语
            if(safeSelf.pageNum==1 && isShowRobotHello){
                BOOL isHaveHello = NO;
                if([safeSelf.listArray lastObject]!=nil){
                    ZCLibMessage *lastModel  = [safeSelf.listArray lastObject];
                    if([lastModel.cid  isEqual:[safeSelf getZCLibConfig].cid]){
                        isHaveHello = YES;
                    }
                }
                if(!isHaveHello){
                    [safeSelf setNetDataToArr:ZCTipCellMessageRobotHelloWord type:0 name:[safeSelf getZCLibConfig].robotName face:[safeSelf getZCLibConfig].robotLogo tips:0 content:nil];
                }
            }
        }
        
        [safeSelf.listTable reloadData];
        
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        
        if([safeSelf.refreshControl isRefreshing]){
            [safeSelf.refreshControl endRefreshing];
        }
        
        // 第一次加载完成，添加问候语
        if(safeSelf.pageNum==1 && ![safeSelf getZCLibConfig].isArtificial && [safeSelf getZCLibConfig].type!=4 && [safeSelf getZCLibConfig].type !=2){
            [safeSelf setNetDataToArr:ZCTipCellMessageRobotHelloWord type:0 name:[safeSelf getZCLibConfig].robotName face:[safeSelf getZCLibConfig].robotLogo tips:0 content:nil];
        }
        
    }];
    
}

#pragma mark --setInitView 设置title和键盘样式
-(void)setInitView{
    
    ZCLibConfig * config = [self getZCLibConfig];
    if(config.type ==1 || config.type == 3 || (config.type == 4 && ![self getZCLibConfig].isArtificial)){
        _receivedName = config.robotName;
        [self.titleLabel setText:config.robotName];
    }
    
    // 启动计时器
    [[self getShareMS] startTipTimer];
    
    // 添加输入框
    [[self getShareMS]setInputListener:[self getChatTextView]];
    
    // 设置键盘样式
    [_zcKeyboardView setInitConfig:config];
    
     _isInitLoading=NO;
    
}

-(UITextView *)getChatTextView{
    return [_zcKeyboardView getChatTextView];
}

#pragma mark -- 页面滚动到底部
-(void)scrollTableToBottom{
    
    [ZCLogUtils logHeader:LogHeader debug:@"滚动到底部"];
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat ch=_listTable.contentSize.height;
        CGFloat h=_listTable.bounds.size.height;
        
        CGRect tf         = _listTable.frame;
        CGFloat x=tf.size.height-_listTable.contentSize.height;
        
        if(x > 0){
            if(x<keyBoardHeight){
                tf.origin.y = NavBarHeight - (keyBoardHeight - x);
            }
        }else{
            tf.origin.y   = NavBarHeight - keyBoardHeight;
        }
        _listTable.frame  = tf;
        
        if(ch > h){
            [_listTable setContentOffset:CGPointMake(0, ch-h) animated:NO];
        }else{
            [_listTable setContentOffset:CGPointMake(0, 0) animated:NO];
        }
    });
}



#pragma mark UITableView delegate Start
// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

// 返回section高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(_isNoMore){
        return TableSectionHeight;
    }
    return 0;
}

// 返回section 的View
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(_isNoMore){
    
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, TableSectionHeight)];
        [view setBackgroundColor:[UIColor clearColor]];
        
        UILabel *lbl=[[UILabel alloc] initWithFrame:CGRectMake(20, 19, viewWidth-40, TableSectionHeight -19)];
        lbl.font=[ZCUITools zcgetListKitDetailFont];
        
        [lbl setTextAlignment:NSTextAlignmentCenter];
        // 没有更多记录的颜色
        [lbl setTextColor:[ZCUITools zcgetTimeTextColor]];
        [lbl setAutoresizesSubviews:YES];
        [lbl setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [lbl setText:Had_NO_MORE_DATA];
        [view addSubview:lbl];
        return view;
    }
    return nil;
}

// 返回section下得行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArray.count;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZCLibMessage *model=[_listArray objectAtIndex:indexPath.row];
    ZCChatBaseCell *cell=nil;
    // 设置内容
    if(model.tipStyle>0){
        cell = (ZCTipsChatCell*)[tableView dequeueReusableCellWithIdentifier:cellTipsIdentifier];
        if (cell == nil) {
            cell = [[ZCTipsChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellTipsIdentifier];
        }
        
    }else if(model.tipStyle == ZCReceivedMessageUnKonw){
        // 商品内容
        cell = (ZCGoodsCell*)[tableView dequeueReusableCellWithIdentifier:cellGoodsIndentifier];
        if (cell == nil) {
            cell = [[ZCGoodsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellGoodsIndentifier];
        }
    }else if(model.richModel.msgType==1){
        cell = (ZCImageChatCell*)[tableView dequeueReusableCellWithIdentifier:cellImageIdentifier];
        if (cell == nil) {
            cell = [[ZCImageChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellImageIdentifier];
        }
    }else if(model.richModel.msgType==0){
        cell = (ZCRichTextChatCell*)[tableView dequeueReusableCellWithIdentifier:cellRichTextIdentifier];
        if (cell == nil) {
            cell = [[ZCRichTextChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellRichTextIdentifier];
        }
    }else if(model.richModel.msgType==2){
        cell = (ZCVoiceChatCell*)[tableView dequeueReusableCellWithIdentifier:cellVoiceIdentifier];
        if (cell == nil) {
            cell = [[ZCVoiceChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellVoiceIdentifier];
        }
    }else{
        cell = (ZCRichTextChatCell*)[tableView dequeueReusableCellWithIdentifier:cellRichTextIdentifier];
        if (cell == nil) {
            cell = [[ZCRichTextChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellRichTextIdentifier];
        }
    }
    
    
    
    cell.viewWidth = viewWidth;
    cell.delegate = self;
    NSString *time=@"";
    NSString *format=@"MM-dd HH:mm";
    if([model.cid isEqual:[self getZCLibConfig].cid]){
        format=@"HH:mm";
    }
    
    if(indexPath.row>0){
        ZCLibMessage *lm=[_listArray objectAtIndex:(indexPath.row-1)];
        if(![model.cid isEqual:lm.cid]){
            //            time=intervalSinceNow(model.ts);
            time = zcLibDateTransformString(format, zcLibStringFormateDate(model.ts));
        }
        
        
        //        [ZCLogUtils logHeader:LogHeader debug:@"============\n%@\ncur=%@\nlast=%@\ntime=%@",model,model.cid,lm.cid,time];
    }else{
        time = zcLibDateTransformString(format, zcLibStringFormateDate(model.ts));
        //        time=intervalSinceNow(model.ts);
    }
    
    if([self getZCLibConfig].isArtificial){
        model.isHistory = YES;
    }
    
    [cell InitDataToView:model time:time];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return cell;
}

// table 行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    //    return cell.frame.size.height;
    ZCLibMessage *model =[_listArray objectAtIndex:indexPath.row];
    NSString *time=@"";
    NSString *format=@"MM-dd HH:mm";
//    if([model.cid isEqual:[self getZCLibConfig].cid]){
//        format=@"HH:mm";
//    }
    
    if(indexPath.row>0){
        ZCLibMessage *lm=[_listArray objectAtIndex:(indexPath.row-1)];
        if(![model.cid isEqual:lm.cid]){
            //            time=intervalSinceNow(model.ts);
            time = zcLibDateTransformString(format, zcLibStringFormateDate(model.ts));
        }
        
        
        //        [ZCLogUtils logHeader:LogHeader debug:@"============\n%@\ncur=%@\nlast=%@\ntime=%@",model,model.cid,lm.cid,time];
    }else{
        time = zcLibDateTransformString(format, zcLibStringFormateDate(model.ts));
        //        time=intervalSinceNow(model.ts);
    }
    CGFloat cellheight = 0;
    
    // 设置内容
    if(model.tipStyle>0){
        cellheight = [ZCTipsChatCell getCellHeight:model time:time viewWith:viewWidth];
    }else if(model.tipStyle == ZCReceivedMessageUnKonw){
        // 商品内容
        cellheight = [ZCGoodsCell getCellHeight:model time:time viewWith:viewWidth];
    }else if(model.richModel.msgType==1){
        cellheight = [ZCImageChatCell getCellHeight:model time:time viewWith:viewWidth];
    }else if(model.richModel.msgType==0){
        cellheight = [ZCRichTextChatCell getCellHeight:model time:time viewWith:viewWidth];
    }else if(model.richModel.msgType==2){
        cellheight = [ZCVoiceChatCell getCellHeight:model time:time viewWith:viewWidth];
        
    }else{
        cellheight = [ZCRichTextChatCell getCellHeight:model time:time viewWith:viewWidth];
    }
    
    if(cellheight!=cell.frame.size.height){
        //        NSLog(@"不相同：%zd--ch=%f;ch=%f\n%@",indexPath.row,cell.frame.size.height,cellheight,model.richModel.msg);
    }
    
    return cellheight;
}

// table 行的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -- 返回或者关闭
-(void)goBack:(BOOL) isClose{
    // 隐藏技能组
    [_zcKeyboardView dismisSkillsetView];
    
//    [[ZCUIKitManager getZCKitManager] destoryManager:!isClose];
    
    if(isClose || [[self getShareMS]isOfflineByCloseAndOfflineByAdmin] ){
        // 清理过期文件
        [self cleanVoicePathFile];
        
        // 清理参数
//        [[ZCUIKitManager getZCKitManager] destoryManager:NO];
        
        
    }else{
        if(lineModel!=nil){
            [_listArray removeObject:lineModel];
        }
        // 清理参数
//        [[ZCUIKitManager getZCKitManager] destoryManager:YES];
        
        [[self getShareMS] setNickName:self.titleLabel.text];
        [[self getShareMS] setArrayData:_listArray];
        
        
    }
    
    if(PageClickBlock){
        PageClickBlock(self,ZCPageBlockGoBack);
    }
    
    if(iOS7){
        // 设置页面不能使用边缘手势关闭
        if(self.navigationController!=nil){
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }
    
    if(self.navigationController != nil ){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    
    // 返回进入SDK之前navc的样式
    if(!navBarHide){
        [self.navigationController setNavigationBarHidden:NO];
    }
}

#pragma mark -- 清理过期文件
-(void) cleanVoicePathFile{
    dispatch_queue_t _ioQueue = dispatch_queue_create("com.sobot.cache", DISPATCH_QUEUE_SERIAL);
    dispatch_async(_ioQueue, ^{
        NSFileManager *_fileManager = [NSFileManager new];
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:VoiceLocalPath];
        
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [VoiceLocalPath stringByAppendingPathComponent:fileName];
            // 未过期，添加到排序列表
            if(![ZCUITools videoIsValid:filePath]){
                // 过期，直接删除
                [_fileManager removeItemAtPath:filePath error:nil];
            }
        }
    });
}


-(id)initWithInitInfo:(ZCKitInfo *)info{
    self=[super init];
    if(self){
        if(info !=nil && !zcLibIs_null(info.info) && !zcLibIs_null(info.info.enterpriseId)){
            self.zckitInfo=info;
        }else{
            self.zckitInfo=[ZCKitInfo new];
        }
    }
    return self;
}

-(id)initWithInitInfo:(ZCKitInfo *)info width:(CGFloat)width height:(CGFloat)h{
    viewWidth = width;
    viewHeigth = h;
    return [self initWithInitInfo:info];
}




#pragma mark -- 封装model
-(ZCLibMessage *)setNetDataToArr:(int) action type:(int)msgType name:(NSString *) uname face:(NSString *) face tips:(int) tipStyle content:(NSString *)count{
    
    if (action == ZCTipCellMessageRobotHelloWord) {
        if([self getShareMS].isRobotHello){
            return nil;
        }
        [self getShareMS].isRobotHello = YES;
    }
    
    
    ZCLibMessage *temModel=[[ZCLibMessage alloc] init];
    temModel.date         = zcLibDateTransformString(FormateTime, [NSDate date]);
    //    temModel.contentTemp  = text;
    temModel.cid          = [self getZCLibConfig].cid;
    temModel.action       = 0;
    temModel.sender       = [self getZCLibConfig].uid;
    temModel.senderName   = uname;
    temModel.senderFace   = face;
    
    NSString *msg ;
    
    if (action == ZCTipCellMessageRobotHelloWord) {
        msg = [self getZCLibConfig].robotHelloWord;
    }else if (action == ZCTipCellMessageUserTipWord){
        msg = [self getZCLibConfig].userTipWord;
    }else if (action == ZCTipCellMessageAdminTipWord){
        msg = [self getZCLibConfig].adminTipWord;
    }else if (action == ZCTipCellMessageUserOutWord){
        msg = [self getZCLibConfig].userOutWord;
    }else if (action == ZCTipCellMessageAdminHelloWord){
        msg = [self getZCLibConfig].adminHelloWord;
    }else{
        msg = [temModel getTipMsg:action Count:count isOpenLeave:[self getZCLibConfig].msgFlag];
    }
    
    if([self getZCLibConfig].isArtificial){
        // 都是人工客服
        temModel.senderType = 2;
        if([@"" isEqual:face]){
            temModel.senderFace = [self getZCLibConfig].senderFace;
        }
    }else{
        temModel.senderType = 1;
    }
    temModel.t=[NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]];
    temModel.ts           = zcLibDateTransformString(FormateTime, [NSDate date]);
    temModel.receiver     = [self getZCLibConfig].companyName;
    temModel.receiverName = [self getZCLibConfig].uid;
    temModel.offlineType  = @"1";
    temModel.receiverFace = @"";
    
    if(tipStyle>0){
        temModel.tipStyle=tipStyle;
        temModel.sysTips=msg;
        
    }else if(tipStyle == ZCReceivedMessageUnKonw){
        temModel.tipStyle = tipStyle;
    }else{
        // 人工回复时，等于7是富文本
        if(msgType==7){
            NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:[msg dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
            ZCLibRich *richModel=[[ZCLibRich alloc] initWithMyDict:@{@"answer":dict}];
            temModel.richModel=richModel;
        }else{
            ZCLibRich *richModel=[ZCLibRich new];
            richModel.msgType = msgType;
            richModel.msg = msg;
            temModel.richModel = richModel;
        }
    }
    
    // 以下为新消息
    if(tipStyle != 2 && tipStyle != ZCReceivedMessageUnKonw){
        [_listArray addObject:temModel];
        [_listTable reloadData];
        [self scrollTableToBottom];
    }
    return temModel;
}

#pragma mark -- button的点击事件
- (void)actionSheet:(ZCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        // 清空历史记录
        [_listArray removeAllObjects];
        [_listTable reloadData];
        
        __weak ZCUIChatVC *safeVC = self;
        [[safeVC getZCLibServer] cleanHistoryMessage:[safeVC getZCLibConfig].uid success:^(NSData *data) {
            [ZCLogUtils logHeader:LogHeader info:@"删除聊天记录：%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        } fail:^(ZCNetWorkCode errorCode) {
            
        }];
        
    }
}

// button点击事件
-(IBAction)buttonClick:(UIButton *) sender{
    if(sender.tag == BUTTON_MORE){
        
        ZCActionSheet *mysheet = [[ZCActionSheet alloc] initWithDelegate:self selectedColor:UIColorFromRGB(TextCleanMessageColor) CancelTitle:ZCSTLocalString(@"Cancel") OtherTitles:ZCSTLocalString(@"EmptyTheChatRecord"), nil];
        mysheet.selectIndex = 1;
        [mysheet show];
        
    }
    
    if(sender.tag == BUTTON_BACK){
        // 返回做会话保持不做评价
        [self goBack:!self.zckitInfo.isKeepSession];
    }
    
    if(sender.tag==BUTTON_CLOSE){
        // 还没有初始化成功，直接退出
        if([self getZCLibConfig]==nil){
            [self goBack:YES];
            return;
        }
        
        // 隐藏键盘
        [_zcKeyboardView hideKeyboard];
        
        // 如果用户开起关闭时显示评价的弹框
        if (self.zckitInfo.isShowEvaluate) {
            
            // 是否转接过人工   （人工的评价逻辑）
            if ([self getZCLibConfig].isArtificial || [[self getShareMS]isOfflineByCloseAndOfflineByAdmin]) {
                
                // 拉黑不能评价客服添加提示语(只有在评价人工的情景下，并且被拉黑，评价机器人不触发此条件)
                if ([[self getZCLibConfig] isblack]||[[self getShareMS] isOfflineBeBlack] || [[self getShareMS] getIsEvaluationService]) {
                    // 关闭时不弹满意度
                    ZCUICustomActionSheet *sheet = [[ZCUICustomActionSheet alloc] initActionSheet:[self getZCLibConfig].isArtificial config:[self getZCLibConfig] isEnd:YES cView:self.view isOnlyShowCannel:NO];
                    sheet.delegate=self;
                    [sheet showInView:self.view];
                    
                    return;
                }
                
                // 与客服说过话
                if ([[self getShareMS] isSendToUser]) {
                    // 必须评价
                    ZCUICustomActionSheet *sheet=[[ZCUICustomActionSheet alloc] initActionSheet:1 config:[self getZCLibConfig] isEnd:NO cView:self.view isOnlyShowCannel:NO];
                    sheet.delegate=self;
                    [sheet showInView:self.view];
                }else{
                    ZCUICustomActionSheet *sheet = [[ZCUICustomActionSheet alloc] initActionSheet:1 config:[self getZCLibConfig] isEnd:YES cView:self.view isOnlyShowCannel:NO];
                    sheet.delegate=self;
                    [sheet showInView:self.view];
                }
                
            }else{
                // 之前评价过机器人，提示已评价。（机器人的评价逻辑）
                if ([[self getShareMS] getIsEvaluationRobot]) {
                    // 关闭时不弹满意度
                    ZCUICustomActionSheet *sheet = [[ZCUICustomActionSheet alloc] initActionSheet:[self getZCLibConfig].isArtificial config:[self getZCLibConfig] isEnd:YES cView:self.view isOnlyShowCannel:NO];
                    sheet.delegate=self;
                    [sheet showInView:self.view];
                    return;
                }
                // 与机器人说过话
                if ([[self getShareMS] isSendToSobot]) {
                    // 必须评价
                    ZCUICustomActionSheet *sheet = [[ZCUICustomActionSheet alloc] initActionSheet:0 config:[self getZCLibConfig] isEnd:NO cView:self.view isOnlyShowCannel:NO];
                    sheet.delegate=self;
                    [sheet showInView:self.view];
                }else{
                    ZCUICustomActionSheet *sheet = [[ZCUICustomActionSheet alloc] initActionSheet:0 config:[self getZCLibConfig] isEnd:YES cView:self.view isOnlyShowCannel:NO];
                    sheet.delegate=self;
                    [sheet showInView:self.view];
                }
                
            }
            
        }else{
            // 关闭时不弹满意度
            ZCUICustomActionSheet *sheet = [[ZCUICustomActionSheet alloc] initActionSheet:[self getZCLibConfig].isArtificial config:[self getZCLibConfig] isEnd:YES cView:self.view isOnlyShowCannel:NO];
            sheet.delegate=self;
            [sheet showInView:self.view];
        }
        
        
    }
    
    // 未读消息数
    if(sender.tag == BUTTON_UNREAD){
        _goUnReadButton.hidden = YES;
        int unNum = [[self getShareMS] getUnReadNum];
        CGRect  popoverRect = [_listTable rectForRowAtIndexPath:[NSIndexPath indexPathForRow:(_listArray.count - unNum) inSection:0]];
        [_listTable setContentOffset:CGPointMake(0,popoverRect.origin.y-40) animated:NO];
        
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==1){
        if(buttonIndex==1){
            // 打电话
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callURL]];
        }
    } else if(alertView.tag==3){
        if(buttonIndex==1){
            // 打电话
            //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callURL]];
            [self openQQ:callURL];
            callURL=@"";
        }
    }
}

-(BOOL)openQQ:(NSString *)qq{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"mqq://im/chat?chat_type=wpa&uin=%@&version=1&src_type=web",qq]];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
        return NO;
    }
    else{
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://wpa.qq.com/msgrd?v=3&uin=%@&site=qq&menu=yes",qq]]];
        return YES;
    }
}

#pragma mark table cell delegate start
-(void)cellItemClick:(ZCLibMessage *)model type:(ZCChatCellClickType)type obj:(id)object{
    if(type == ZCChatCellClickTypeSendGoosText && ![self getZCLibConfig].isArtificial){
        return;
    }
    if (type == ZCChatCellClickTypeShowToast) {
        [[ZCUIToastTools shareToast] showToast:@"   复制成功！  " duration:1.0f view:self.view.window.rootViewController.view position:ZCToastPositionCenter Image:[ZCUITools zcuiGetBundleImage:@"ZCicon_successful"]];
        return;
    }
    
    // 点击满意度，调评价
    if (type == ZCChatCellClickTypeSatisfaction) {
        
    }
    
    if (type == ZCChatCellClickTypeLeaveMessage) {
        // 不直接退出SDK
        [self goLeaveMessageVC:ISNOCOLSE];
    }
    if(type==ZCChatCellClickTypeTouchImageYES){
        xhObj=object;
        [_zcKeyboardView hideKeyboard];
    }
    if(type==ZCChatCellClickTypeTouchImageNO){
        // 隐藏键盘
        xhObj=nil;
    }
    
    if(type==ZCChatCellClickTypeItemChecked){
        // 发送向导选项
        [self sendMessage:object type:ZCMessageTypeText duration:@""];
    }
    
    // 发送商品信息给客服
    if(type == ZCChatCellClickTypeSendGoosText){
        [self sendMessage:object type:ZCMessageTypeText duration:@""];
    }
    
    // 重新接入
    if(type==ZCChatCellClickTypeReConnected){
        [self keyboardItemClick:ZCKeyboardOnClickReConnectedUser object:nil];
    }
    
    // 重新发送
    if(type==ZCChatCellClickTypeReSend){
        
        __weak ZCUIChatVC *safeVC = self;
        [[safeVC getZCLibServer] sendMessage:model.richModel.msg msgType:model.richModel.msgType duration:model.richModel.duration config:[safeVC getZCLibConfig] start:^(ZCLibMessage *message) {
            model.sendStatus = 1;
            [safeVC.listTable reloadData];
        } success:^(ZCLibMessage *message, ZCMessageSendCode sendCode) {
            model.sendStatus = 0;
            if(![safeVC getZCLibConfig].isArtificial && sendCode==ZC_SENDMessage_New){
                [safeVC.listArray addObject:message];
                
                [safeVC.listTable reloadData];
                [safeVC scrollTableToBottom];
            }else{
                [safeVC.listTable reloadData];
            }
        } progress:^(ZCLibMessage *message) {
            model.progress = message.progress;
            [safeVC.listTable reloadData];
        } fail:^(ZCLibMessage *message, ZCMessageSendCode errorCode) {
            model.sendStatus = 2;
            [safeVC.listTable reloadData];
        }];
    }
    
    if(type==ZCChatCellClickTypePlayVoice){
        if(animateView){
            [animateView stopAnimating];
        }
        
        // 已经有播放的，关闭当前播放的
        if(_voiceTools){
            [_voiceTools stopVoice];
        }
        
        if(playModel){
            playModel.isPlaying=NO;
            playModel=nil;
        }
        if([object isEqual:animateView]){
            animateView=nil;
            return;
        }
        
        
        playModel=model;
        playModel.isPlaying=YES;
        
        animateView=object;
        
        [animateView startAnimating];
        
        // 本地文件
        if(zcLibCheckFileIsExsis(model.richModel.msg)){
            if(_voiceTools){
                [_voiceTools playAudio:[NSURL fileURLWithPath:model.richModel.msg] data:nil];
            }
        }else{
            NSString *voiceURL=model.richModel.msg;
            NSString *dataPath=VoiceLocalPath;
            // 创建目录
            zcLibCheckPathAndCreate(dataPath);
            
            // 拼接完整的地址
            dataPath=[dataPath stringByAppendingString:[NSString stringWithFormat:@"/%@.wav",zcLibMd5(voiceURL)]];
            if(zcLibCheckFileIsExsis(dataPath)){
                if(_voiceTools){
                    [_voiceTools playAudio:[NSURL fileURLWithPath:dataPath] data:nil];
                }
                
                return;
            }
            
            // 下载，播放网络声音
            [[self getZCLibServer] downFileWithURL:model.richModel.msg start:^{
                
            } success:^(NSData *data) {
                [data writeToFile:dataPath atomically:YES];
                if(_voiceTools){
                    [_voiceTools playAudio:[NSURL fileURLWithPath:dataPath] data:nil];
                }
            } progress:^(float progress) {
                
            } fail:^(ZCNetWorkCode errorCode) {
                
            }];
        }
    }
}

-(void)cellItemLinkClick:(NSString *)text type:(ZCChatCellClickType)type obj:(NSString *)linkURL{
    
    if(type==ZCChatCellClickTypeOpenURL){
        if(LinkedClickBlock){
            LinkedClickBlock(linkURL);
        }else{
            if([linkURL hasPrefix:@"tel:"] || zcLibValidateMobile(linkURL)){
                callURL=linkURL;
                
                //初始化AlertView
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:[linkURL stringByReplacingOccurrencesOfString:@"tel:" withString:@""]
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"呼叫",nil];
                alert.tag=1;
                [alert show];
            }else if([linkURL hasPrefix:@"mailto:"] || zcLibValidateEmail(linkURL)){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkURL]];
            }
            //            else if([linkURL hasPrefix:@"tencent://"]){
            //                //            callURL=text;
            //                //
            //                //            //初始化AlertView
            //                //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
            //                //                                                            message:text
            //                //                                                           delegate:self
            //                //                                                  cancelButtonTitle:@"取消"
            //                //                                                  otherButtonTitles:@"呼叫",nil];
            //                //            alert.tag=3;
            //                //            [alert show];
            //            }
            else{
                if (![linkURL hasPrefix:@"https"] && ![linkURL hasPrefix:@"http"]) {
                    linkURL = [@"http://" stringByAppendingString:linkURL];
                }
                ZCUIWebController *webPage=[[ZCUIWebController alloc] initWithURL:zcUrlEncodedString(linkURL)];
                if(self.navigationController != nil ){
                    [self.navigationController pushViewController:webPage animated:YES];
                }else{
                    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:webPage];
                    nav.navigationBarHidden=YES;
                    [self presentViewController:nav animated:YES completion:^{
                        
                    }];
                }
            }
        }
    }
}

#pragma mark -- 执行留言
-(void)goLeaveMessageVC:(ExitType) isExist{
    ZCUILeaveMessageController *leaveMessageVC = [[ZCUILeaveMessageController alloc]init];
    leaveMessageVC.exitType = isExist;
    [leaveMessageVC setCloseBlock:^{
        [self goBack:isExist];
        if (PageClickBlock) {
            PageClickBlock(self,ZCPageBlockGoBack);
        }
    }];
    
    
    if (self.navigationController != nil) {
        [self.navigationController pushViewController:leaveMessageVC animated:YES];
    }else{
        [self  presentViewController:leaveMessageVC animated:YES completion:^{
            
        }];
    }
    if (![self getZCLibConfig].isArtificial && [self getZCLibConfig].type ==2) {
        // 智齿loading消失
        //            [[ZCUILoading shareZCUILoading] dismiss];
    }
}


#pragma mark section 跟随table滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat sectionHeaderHeight = TableSectionHeight;
    //固定section 随着cell滚动而滚动
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        
    }
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [_zcKeyboardView hideKeyboard];
}

#pragma mark 打分代理
-(void)actionSheetClick:(BOOL)isComment{
    if(isComment){
        if(self.navigationController){
            [[ZCUIToastTools shareToast] showToast:@"感谢您的反馈^-^!" duration:1.0f view:self.view.window.rootViewController.view position:ZCToastPositionCenter];
        }else{
            
            [[ZCUIToastTools shareToast] showToast:@"感谢您的反馈^-^!" duration:1.0f view:self.presentingViewController.view position:ZCToastPositionCenter];
        }
    }
    [self goBack:YES];
}


#pragma mark 网络链接改变时会调用的方法
-(void)netWorkChanged:(NSNotification *)note
{
    BOOL isReachable=[ZCLibNetworkTools shareNetworkTools].isReachable;
    if(!isReachable){
        _newWorkStatusButton.hidden=NO;
        [_listTable setContentInset:UIEdgeInsetsMake(40, 0, 0, 0)];
        
        if([self getZCLibConfig]==nil){
            [[ZCUILoading shareZCUILoading] showAddToSuperView:self.view];
        }
        
    }else{
        _newWorkStatusButton.hidden=YES;
        [_listTable setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        // 初始化数据
        if([self getZCLibConfig]==nil && !_isInitLoading){
            [self InitData:NO];
        }
    }
}


#pragma mark 音频播放设置
-(void)voicePlayStatusChange:(ZCVoicePlayStatus)status{
    switch (status) {
        case ZCVoicePlayStatusReStart:
            if(animateView){
                [animateView startAnimating];
            }
            break;
        case ZCVoicePlayStatusPause:
            if(animateView){
                [animateView stopAnimating];
                
            }
            break;
        case ZCVoicePlayStatusStartError:
            if(animateView){
                [animateView stopAnimating];
            }
            break;
        case ZCVoicePlayStatusFinish:
        case ZCVoicePlayStatusError:
            if(animateView){
                [animateView stopAnimating];
                animateView=nil;
                
                playModel.isPlaying=NO;
                playModel=nil;
            }
            break;
        default:
            break;
    }
}


#pragma mark 页面代理
-(void)addMessageToList:(int)action type:(int)type name:(NSString *)senderName face:(NSString *)face source:(int)source content:(NSString *)count{
    
    [ZCLogUtils logHeader:LogHeader debug:@"========%d %d %@ %@ %d=========",action,type,senderName,face,source];
    
    if(source==1){
        senderName=_receivedName;
        
        [self setNetDataToArr:action type:type name:senderName face:@"" tips:0 content:count];
    }
    if(source==3){
        // 无客服在线
        if(type==2){
            // 设置标题
            [self.titleLabel setText:_receivedName];
            
            if ([self getZCLibConfig].isArtificial) {
                [self.titleLabel setText:[self getShareMS].serverName];
            }
            
        }
        
        if(_listArray.count>=1 && type == 2){
            int index = -1;
            for (int i = 0 ; i <_listArray.count; i++) {
                ZCLibMessage *model = _listArray[i];
                if ([model.sysTips hasPrefix:[self getZCLibConfig].adminNonelineTitle] && (action == ZCTipCellMessageUserNoAdmin)) {
                    index = i;
                    break;
                }
                
                if ([model.sysTips hasPrefix:@"您已完成评价"] && (action == ZCTipCellMessageEvaluationCompleted)) {
                    index = i;
                    break;
                }
                if([model.sysTips hasPrefix:@"咨询后才能评价服务质量"] && (action == ZCTipCellMessageAfterConsultingEvaluation)){
                    index = i;
                    break;
                }
                if ([model.sysTips hasPrefix:@"暂时无法转接人工客服"] && (action == ZCTipCellMessageIsBlock)) {
                    index = i;
                }
            }
            if(index>=0){
                [_listArray removeObjectAtIndex:index];
            }
        }
        
        [self setNetDataToArr:action type:type name:senderName face:@"" tips:1 content:count];
    }
}

#pragma mark Bottom delegate
// 执行发送消息
-(void)sendMessage:(NSString *)text type:(ZCMessageType)type duration:(NSString *)time{
    [[self getShareMS] cleanUserCount];
    [self getShareMS].isCustomerLastSend = NO;
    
    // 当前是 用户还是机器人发送的消息
    if([self getZCLibConfig].isArtificial){
        [self getShareMS].isSendToUser=YES;
    }else{
        [self getShareMS].isSendToSobot=YES;
    }
    
//    __block ZCLibMessage *sendMessage=nil;
    __weak ZCUIChatVC *safeView = self;
    [[safeView getZCLibServer] sendMessage:text msgType:type duration:time config:[safeView getZCLibConfig] start:^(ZCLibMessage *message) {
        safeView.sendMessage = message;
        safeView.sendMessage.sendStatus = 1;
//        sendMessage = message;
//        sendMessage.sendStatus=1;
        
        [safeView.listArray addObject:safeView.sendMessage];
        [safeView.listTable reloadData];
        
        [safeView scrollTableToBottom];
    } success:^(ZCLibMessage *message, ZCMessageSendCode sendCode) {
        if(sendCode==ZC_SENDMessage_New){
            if(message.richModel && (message.richModel.answerType==3||message.richModel.answerType==4) && !safeView.zckitInfo.isShowTansfer){
                safeView.unknownWordsCount ++;
                if([safeView.zckitInfo.unWordsCount integerValue]==0) {
                    safeView.zckitInfo.unWordsCount =@"1";
                }
                if (safeView.unknownWordsCount >= [safeView.zckitInfo.unWordsCount integerValue]) {
                    
                    // 仅机器人的模式不做处理
                    if ([safeView getZCLibConfig].type != 1) {
                        // 设置键盘的样式 （机器人，转人工按钮显示）
                        [safeView.zcKeyboardView setRobotViewStatusType:1];
                    }
                }
                
            }
            [safeView.listArray addObject:message];
            [safeView.listTable reloadData];
            [safeView scrollTableToBottom];
        }else if(sendCode==ZC_SENDMessage_Success){
            safeView.sendMessage.sendStatus=0;
            [safeView.listTable reloadData];
        }else{
            safeView.sendMessage.sendStatus=2;
            [safeView.listTable reloadData];
        }
    } progress:^(ZCLibMessage *message) {
        [ZCLogUtils logText:@"上传进度：%f",message.progress];
        safeView.sendMessage.progress = message.progress;
        [safeView.listTable reloadData];
    } fail:^(ZCLibMessage *message, ZCMessageSendCode errorCode) {
        safeView.sendMessage.sendStatus=2;
        [safeView.listTable reloadData];
    }];
}

// 键盘的高度
-(void) keyboardChanged:(CGFloat) height{
    keyBoardHeight=height;
}



#pragma mark -- 其他点击
// 其它点击
-(void) keyboardItemClick:(ZCKeyboardType ) type object:(id)obj{
    
    // 新会话
    if(type==ZCKeyboardOnClickReInit){
        [self againAccessInit];
        return;
    }
    
    // 和机器人会话提示留言
    if (type == ZCKeyboardOnClickAddLeavemeg) {
        _receivedName = [self getZCLibConfig].robotName;
        
        [self addMessageToList:ZCTipCellMessageUserNoAdmin type:2 name:@"" face:@"" source:3 content:[self getZCLibConfig].adminNonelineTitle];
        
        
        if ([self getZCLibConfig].type == 2 && [self getZCLibConfig].msgFlag == 1) {
            [_zcKeyboardView setRobotViewStatusType:ONLYUSERNOLINESTATUS];
            
            _receivedName = ZCSTLocalString(@"NoAccess");
            [self.titleLabel setText:_receivedName];
            return;
        }
        
        // 如果没有机器人欢迎语，添加机器人欢迎语
        if ([self getZCLibConfig].type !=2) {
            [self setNetDataToArr:ZCTipCellMessageRobotHelloWord type:0 name:[self getZCLibConfig].robotName face:[self getZCLibConfig].robotLogo tips:0 content:nil];
        }
        
        [self.titleLabel setText:_receivedName];
        [[self getShareMS] cleanUserCount];
        [[self getShareMS] cleanAdminCount];
        return;
    }
    
    // 留言
    if(type ==  ZCKeyboardOnClickLeavePage){
        if ([obj integerValue] == 2 && [self getZCLibConfig].type == 2 && [self getZCLibConfig].msgFlag == 1) {
            [_zcKeyboardView setRobotViewStatusType:ONLYUSERNOLINESTATUS];
            
            _receivedName = ZCSTLocalString(@"NoAccess");
        }else{
            // 是否直接退出SDK
            NSInteger isExit = [obj integerValue];
            [self goLeaveMessageVC:isExit];
        }
        
    }
    
    /**
     *  关闭技能组（取消按钮）选项，如果是仅人工模式和人工优先 退出
     */
    if(type == ZCKeyboardOnClickCloseSkillSet){
        if([self getZCLibConfig].type == 2 || [self getZCLibConfig].type == 4){
            [self  goBack:YES];
        }
    }
    
    // 转人工  
    if(type==ZCKeyboardOnClickTurnUser || type==ZCKeyboardOnClickReConnectedUser){
        if(_isTurnLoading){
            return;
        }
        
        _isTurnLoading = YES;
        
        __weak ZCUIChatVC *safeVC = self;
        NSString *groupId = [[safeVC getShareMS] getGroupId];
        NSString *groupName = [[safeVC getShareMS] getGroupName];        
        [[safeVC getZCLibServer] connectOnlineCustomer:groupId groupName:groupName config:[safeVC getZCLibConfig] start:^{
            [safeVC.zcKeyboardView getButtonEnable].enabled=NO;
        } result:^(NSDictionary *dict, ZCConnectUserStatusCode status) {
            safeVC.isTurnLoading = NO;
            safeVC.receivedName = [safeVC getZCLibConfig].robotName;
            [[ZCUIToastTools shareToast] dismisProgress];
            
            [safeVC.zcKeyboardView dismisSkillsetView];
            
            [ZCLogUtils logHeader:LogHeader debug:@"连接完成！状态：%zd %@",status,dict];
            
            [safeVC.zcKeyboardView getButtonEnable].enabled=YES;
            
            if([dict[@"data"][@"status"] intValue]==5){
                // 用户长时间没有说话，已经超时 （做机器人超时下线的操作显示新会话的键盘样式）
                return;
            }
            
            if([safeVC getZCLibConfig].isArtificial || type==ZCKeyboardOnClickReConnectedUser || status==ZCConnectUserOfWaiting){
                
                for(ZCLibMessage *item in safeVC.listArray){
                    if(item.tipStyle>0){
                        item.sysTips=[item.sysTips stringByReplacingOccurrencesOfString:@"您可以留言" withString:@""];
                    }
                }
                
            }
            
            if(status==ZCConnectUserSuccess){
                safeVC.receivedName = zcLibConvertToString(dict[@"data"][@"aname"]);
                [safeVC getShareMS].serverName = zcLibConvertToString(dict[@"data"][@"aname"]);
                ZCLibConfig *libConfig = [safeVC getZCLibConfig];
                libConfig.isArtificial = YES;
                [safeVC getShareMS].libConfig = libConfig;
                
                int messageType=ZCReceivedMessageNews;
                
                ZCLibMessage *message = [[safeVC getZCLibServer]  setLocalDataToArr:ZCTipCellMessageOnline type:messageType duration:@"" style:ZCReceivedMessageOnline send:NO name:safeVC.receivedName content:safeVC.receivedName config:libConfig];
                message.senderFace = zcLibConvertToString(dict[@"data"][@"aface"]);
                
                [[safeVC getShareMS] setWaitModel:nil];

//                // 是否设置语音开关
                [safeVC.zcKeyboardView setUserViewStatus:[ZCUITools zcgetOpenRecord]];
                
                [safeVC onReceivedMessage:message nickName:safeVC.receivedName];
                
                // 欢迎语客服
                message = [[safeVC getZCLibServer] setLocalDataToArr:ZCTipCellMessageAdminHelloWord type:0 duration:@"" style:0 send:NO name:safeVC.receivedName content:nil config:libConfig];
                message.senderFace = zcLibConvertToString(dict[@"data"][@"aface"]);
                
                [safeVC onReceivedMessage:message nickName:safeVC.receivedName];
                
                [safeVC getShareMS].isServerHello = YES;
                
                // 连接失败
   
            }else if(status==ZCConnectUserOfWaiting){
                int messageType = ZCReceivedMessageWaiting;
                if ([safeVC getZCLibConfig].type == 2) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [safeVC.zcKeyboardView setRobotViewStatusType:WAITSTATUS];
                    });
                }else{
                    safeVC.receivedName = zcLibConvertToString(dict[@"data"][@"aname"]);
                    [safeVC.zcKeyboardView setRobotViewStatusType:ROBOTSTATUS];
                }
                
                ZCLibMessage *message = [[safeVC getZCLibServer] setLocalDataToArr:ZCTipCellMessageWaiting type:ZCReceivedMessageWaiting duration:@"" style:messageType send:NO name:safeVC.receivedName content:zcLibConvertToString(dict[@"data"][@"count"]) config:[safeVC getZCLibConfig]];
                
                [safeVC onReceivedMessage:message nickName:safeVC.receivedName];
                
                [[safeVC getShareMS] setWaitModel:message];
                
                
                // 没有客服在线
            } else if(status==ZCConnectUserNoAdmin){
                // 仅人工模式 没有开启技能组或者技能组数量为1时，客服不在线,直接跳转都到留言
                // 仅人工 开启留言开关
                if ([safeVC getZCLibConfig].type == 2 && [safeVC getZCLibConfig].msgFlag == 0) {
                    
                    [safeVC goLeaveMessageVC:ISCOLSE];
                    
                }else{
                    
                    [safeVC addMessageToList:ZCTipCellMessageUserNoAdmin type:2 name:@"" face:@"" source:3 content:[safeVC getZCLibConfig].adminNonelineTitle];
                    if (safeVC.listArray.count != 0) {
                        int index = 0;
                        for (int i = 0; i< safeVC.listArray.count; i++) {
                            ZCLibMessage *libmeg = safeVC.listArray[i];
                            if ([libmeg.sysTips  isEqualToString:[safeVC getZCLibConfig].robotHelloWord]) {
                                index ++;
                            }
                            
                        }
                        if (index == 0) {
                            // 如果没有机器人欢迎语，添加机器人欢迎语 (只在转人工不成功的情况下添加) 仅人工模式不添加
                            if ([safeVC getZCLibConfig].type != 2 ) {
                                
                                [safeVC setNetDataToArr:ZCTipCellMessageRobotHelloWord type:0 name:[safeVC getZCLibConfig].robotName face:[safeVC getZCLibConfig].robotLogo tips:0 content:nil];
                            }
                            
                        }
                    }
                    
                    // 设置机器人的键盘样式
                    [safeVC.zcKeyboardView setRobotViewStatusType:1];
                }
                
                // 针对仅人工模式 是否开启留言并没有接入成功 设置 未接入 键盘的区别
                if ([safeVC getZCLibConfig].type == 2 && [safeVC getZCLibConfig].msgFlag == 0) {
                    //  设置新会话的键盘样式
                    [safeVC.zcKeyboardView setRobotViewStatusType:AGAINACCESSASTATUS];
                    safeVC.receivedName = ZCSTLocalString(@"NoAccess");
                    
                }else if ([safeVC getZCLibConfig].type ==2 && [safeVC getZCLibConfig].msgFlag == 1){
                    [safeVC.zcKeyboardView setRobotViewStatusType:ONLYUSERNOLINESTATUS];
                    safeVC.receivedName = ZCSTLocalString(@"NoAccess");
                }
            }

            [safeVC.titleLabel setText:safeVC.receivedName];
            [[safeVC getShareMS] cleanUserCount];
            [[safeVC getShareMS] cleanAdminCount];
            
        }];
        
        // 满意度评价
    }else if (type == ZCKeyboardOnClickSatisfaction){
        // 隐藏键盘
        [_zcKeyboardView hideKeyboard];
        
        BOOL isUser = [[self getShareMS] isSendToUser];
        
        BOOL isRobot = [[self getShareMS] isSendToSobot];
        
        [ZCLogUtils logHeader:LogHeader debug:@"当前发送状态：%d,%d",isUser,isRobot];
        
        
        /**
         1.只和机器人聊过天 评价机器人
         2.只和人工聊过天 评价人工
         3.机器人的评价和人工的评价做区分，互不相干。
         */
        
        // 是否转接过人工   （人工的评价逻辑）
        if ([self getZCLibConfig].isArtificial || [[self getShareMS]isOfflineByCloseAndOfflineByAdmin]) {
            
            
            // 拉黑不能评价客服添加提示语(只有在评价人工的情景下，并且被拉黑，评价机器人不触发此条件)
            if ([[self getZCLibConfig] isblack]||[[self getShareMS] isOfflineBeBlack]) {
                
                [self addMessageToList:ZCTipCellMessageTemporarilyUnableToEvaluate type:2 name:@"" face:@"" source:3 content:nil];
                return;
            }
            
            // 之前评价过人工，提示已评价过。
            if ([[self getShareMS] getIsEvaluationService]) {
                [self addMessageToList:ZCTipCellMessageEvaluationCompleted type:2 name:@"" face:@"" source:3 content:nil];
                return;
            }
            
            if (isUser) {
                ZCUICustomActionSheet *sheet=[[ZCUICustomActionSheet alloc] initActionSheet:1 config:[self getZCLibConfig] isEnd:NO cView:self.view isOnlyShowCannel:YES];
                sheet.delegate=self;
                [sheet showInView:self.view];
            }else{
                [[self getShareMS] setIsEvaluationService:NO];
                
                [self addMessageToList:ZCTipCellMessageAfterConsultingEvaluation type:2 name:@"" face:@"" source:3 content:nil];
            }
            
            
        }else{
            
            // 之前评价过机器人，提示已评价。（机器人的评价逻辑）
            if ([[self getShareMS] getIsEvaluationRobot]) {
                [self addMessageToList:ZCTipCellMessageEvaluationCompleted type:2 name:@"" face:@"" source:3 content:nil];
                return;
            }
            
            if (isRobot) {
                ZCUICustomActionSheet *sheet = [[ZCUICustomActionSheet alloc] initActionSheet:0 config:[self getZCLibConfig] isEnd:NO cView:self.view isOnlyShowCannel:YES];
                sheet.delegate=self;
                [sheet showInView:self.view];
            }else{
                [[self getShareMS] setIsEvaluationRobot:NO];
                [self addMessageToList:ZCTipCellMessageAfterConsultingEvaluation type:2 name:@"" face:@"" source:3 content:nil];
            }
        }
        
        
    }else if(type == ZCKeyboardOnClickDoWaiteWarning){
        
        ZCLibMessage *message = [[self getShareMS] getWaitModel];
        message.isRead = NO;
        [self onReceivedMessage:message nickName:_receivedName];
        
    }
    
    
}
// 感谢您的评价
-(void)thankFeedBack{
    if(self.navigationController){
        [[ZCUIToastTools shareToast] showToast:@"感谢您的反馈" duration:1.0f view:self.view.window.rootViewController.view position:ZCToastPositionCenter];
    }else{
        
        [[ZCUIToastTools shareToast] showToast:@"感谢您的反馈" duration:1.0f view:self.presentingViewController.view position:ZCToastPositionCenter];
    }
    
}

/**
 *  重新初始化
 */
- (void)againAccessInit{
    // 每次开始新会话都可以重新评价客服或者机器人
//    [[ZCUIKitManager getZCKitManager] destoryManager:YES];
    
    // 清理参数
    
    [_listArray removeAllObjects];
    
    [self cleanVoicePathFile];
    
    if ([self getZCLibConfig].type == 2) {
        
        [self getShareMS].isRobotHello = YES;
        [self InitData:NO];
    }else{
        [self getShareMS].isRobotHello = NO;
        [self InitData:YES];
    }
    
}


-(void)setPageBlock:(void (^)(ZCUIChatController *, ZCPageBlockType))pageClick messageLinkClick:(void (^)(NSString *))linkBlock{
    PageClickBlock=pageClick;
    LinkedClickBlock=linkBlock;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"release BlockLeakViewController");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
