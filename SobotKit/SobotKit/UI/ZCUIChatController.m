//
//  ZCUIChatController.m
//  SobotKit
//
//  Created by zhangxy on 15/11/11.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCUIChatController.h"
#import "ZCLibCommon.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCLibNetworkTools.h"
#import "ZCUIColorsDefine.h"
#import "ZCIMChat.h"

#import "ZCUITools.h"
#import "ZCUIXHImageViewer.h"
#import "ZCUILoading.h"
#import "ZCUIVoiceTools.h"
#import "ZCUICustomActionSheet.h"
#import "ZCUIChatKeyboard.h"


#import "ZCUIConfigManager.h"
#import "ZCUIWebController.h"
#import "ZCLibHttpManager.h"


#import "ZCChatBaseCell.h"
#import "ZCRichTextChatCell.h"
#import "ZCImageChatCell.h"
#import "ZCVoiceChatCell.h"
#import "ZCTipsChatCell.h"
#import "ZCGoodsCell.h"

#import "ZCActionSheet.h"

#import "ZCUILeaveMessageController.h"

#import "ZCLibSkillSet.h"

#import "ZCSobotCore.h"
#import "ZCStoreConfiguration.h"
#import "ZCUIImageView.h"

#import "ZCSatisfactionCell.h"

#import "KNBGoodsInfo.h"
#import "KNBGoodsCell.h"
#import "KNBOrderCell.h"
#import "YYModel.h"
#import "KNBOrderViewController.h"


#define cellRichTextIdentifier @"ZCRichTextChatCell"
#define cellImageIdentifier @"ZCImageChatCell"
#define cellVoiceIdentifier @"ZCVoiceChatCell"
#define cellTipsIdentifier @"ZCTipsChatCell"
#define cellGoodsIndentifier @"ZCGoodsCell"
#define cellSatisfactionIndentifier @"ZCSatisfactionCell"

#define kGoodsCellIndentifier @"KNBGoodsCell"
#define kOrderCellIndentifier @"KNBOrderCell"


#define BottomHeight       49
#define TableSectionHeight 34
#define DATA_PAGE_SIZE     20

/**
 *  ExitType  ENUM
 */
typedef NS_ENUM(NSInteger,ExitType) {
    /** 直接退出SDK */
    ISCOLSE         = 1,
    /** 不直接退出SDK*/
    ISNOCOLSE       = 2,
    /** 仅人工模式 点击技能组上的留言按钮后,（返回上一页面 提交退出SDK）*/
    ISBACKANDUPDATE = 3,
    /** 机器人优先，点击技能组的留言按钮后，（返回技能组 提交和机器人会话）*/
    ISROBOT         = 4,
    /** 人工优先，点击技能组的留言按钮后，（返回技能组 提交机器人会话）*/
    ISUSER          = 5,
};


@interface ZCUIChatController ()<UITableViewDataSource,UITableViewDelegate,ZCChatCellDelegate
,ZCUIVoiceDelegate,ZCUIBackActionSheetDelegate,ZCUIKeyboardDelegate,ZCMessageDelegate
,UIAlertViewDelegate,ZCActionSheetDelegate,ZCUIManagerDelegate,KNBOrderViewControllerDelegate>{
    
    // 页面加载生命周期
    void (^PageClickBlock)   (id object,ZCPageBlockType type);
    // 链接点击
    void (^LinkedClickBlock) (NSString *url);
    
    
    // 无网络提醒button
    UIButton                    *_newWorkStatusButton;
    // 查看未读消息
    UIButton                    *_goUnReadButton;
    
    //长连接显示情况
    UIButton                    *_socketStatusButton;
    
    // “以下为新消息”对象，方便移除
    ZCLibMessage                *lineModel;
    
    // 播放临时model，用于停止播放状态改变
    ZCLibMessage                *playModel;
    
    ZCLibMessage                *recordModel;
    
    // 播放时动画展示View
    UIImageView                 *animateView;
    
    // 旋转时隐藏查看大图功能
    ZCUIXHImageViewer           *xhObj;
    
    // 是否显示系统状态栏，退出时显示
    BOOL                        navBarHide;
    
    // 呼叫的电话号码
    NSString                    *callURL;
    
    // 屏幕宽高
    CGFloat                     viewWidth;
    CGFloat                     viewHeigth;
    
    // 记录评价页面消失
    BOOL                        _isDismissSheetPage;
    BOOL                        isStartConnectSockt;
    BOOL                        isComment;
    
//    NSMutableArray<NSNumber *> *_cellsHeight;

}

@property (nonatomic,strong) NSString *vcTitle;

/** 记录对接客服ID 之后掉接口返回6 再去转人工 */
@property (nonatomic,assign) BOOL  isDoConnectedUser;

/** 下拉刷新系统组件 */
@property (nonatomic,retain) UIRefreshControl  *refreshControl NS_AVAILABLE_IOS(6_0);

/** 声音播放对象 */
@property (nonatomic,strong) ZCUIVoiceTools    *voiceTools;

/** 网络监听对象 */
@property (nonatomic,strong) ZCLibNetworkTools *netWorkTools;

/** 是否正在初始化，网络变化时使用 */
@property (nonatomic,assign)  BOOL             isInitLoading;

/** 底部输入框键盘的View */
@property (nonatomic,strong)  ZCUIChatKeyboard *zcKeyboardView;

/** 消息数据 */
@property (nonatomic ,strong)  NSMutableArray  *listArray;

/** 是否已经没有更多数据了 */
@property (nonatomic ,assign) BOOL             isNoMore;

/**  是否加载过历史记录 */
@property (nonatomic ,assign) BOOL             isHadLoadHistory;

/** 是否清空历史记录 */
@property (nonatomic ,assign) BOOL             isClearnHistory;

/** 未知说辞计数*/
@property (nonatomic, assign) NSUInteger       unknownWordsCount;

/** 是否正在执行转人工 */
@property (nonatomic, assign) BOOL             isTurnLoading;

/** 对方的名称 */
@property (nonatomic ,strong)  NSString        *receivedName;

/** 当前查询的cid */
@property (nonatomic ,strong)  NSString        *currentCid;

/** 对方的名称 */
@property (nonatomic ,strong)  NSMutableArray  *cidsArr;

@property (nonatomic ,assign) BOOL             isLoadCids;

// 通告view
@property (nonatomic,strong)  UIView           *notifitionTopView;


// 评价完成之后是否要添加满意度cell(刷新客服主动邀请的cell)
@property (nonatomic,assign)  BOOL            isAddServerSatifaction;

@end


@implementation ZCUIChatController

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
    return [ZCUIConfigManager getInstance];
}

-(ZCLibServer *)getZCAPIServer{
    return [[self getShareMS] getZCAPIServer];
}

-(ZCLibConfig *) getZCLibConfig{
    return [ZCIMChat getZCIMChat].libConfig;
}


-(id)initWithInitInfo:(ZCKitInfo *)info{
    self=[super init];
    if(self){
        if(info !=nil && !zcLibIs_null([ZCLibClient getZCLibClient].libInitInfo) && !zcLibIs_null([ZCLibClient getZCLibClient].libInitInfo.appKey)){
            self.zckitInfo=info;
        }else{
            self.zckitInfo=[ZCKitInfo new];
        }
        [ZCUIConfigManager getInstance].kitInfo = info;
    }
    return self;
}

-(id)initWithInitInfo:(ZCKitInfo *)info width:(CGFloat)width height:(CGFloat)h{
    viewWidth = width;
    viewHeigth = h;
    return [self initWithInitInfo:info];
}

-(void)setPageBlock:(void (^)(ZCUIChatController *, ZCPageBlockType))pageClick messageLinkClick:(void (^)(NSString *))linkBlock{
    PageClickBlock=pageClick;
    LinkedClickBlock=linkBlock;
}


#pragma mark 创建UI


-(UITableView *)createTable{
    if(!_listTable){
        CGFloat TH = BottomHeight;
        if (ZC_iPhoneX) {
            TH = BottomHeight + 34;
        }
        _listTable=[[UITableView alloc] initWithFrame:CGRectMake(0, NavBarHeight , viewWidth, viewHeigth-NavBarHeight- TH)];
        
        [_listTable setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
        [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _listTable.delegate=self;
        _listTable.dataSource=self;
        [_listTable registerClass:[ZCRichTextChatCell class] forCellReuseIdentifier:cellRichTextIdentifier];
        [_listTable registerClass:[ZCImageChatCell class] forCellReuseIdentifier:cellImageIdentifier];
        [_listTable registerClass:[ZCVoiceChatCell class] forCellReuseIdentifier:cellVoiceIdentifier];
        [_listTable registerClass:[ZCTipsChatCell class] forCellReuseIdentifier:cellTipsIdentifier];
        [_listTable registerClass:[ZCGoodsCell class] forCellReuseIdentifier:cellGoodsIndentifier];
        [_listTable registerClass:[KNBGoodsCell class] forCellReuseIdentifier:kGoodsCellIndentifier];
        [_listTable registerClass:[KNBOrderCell class] forCellReuseIdentifier:kOrderCellIndentifier];
//
//        [_listTable registerNib:[UINib nibWithNibName:@"KNBGoodsCell" bundle:nil] forCellReuseIdentifier:kGoodsCellIndentifier];



        [_listTable registerClass:[ZCSatisfactionCell class] forCellReuseIdentifier:cellSatisfactionIndentifier];
        [_listTable setSeparatorColor:[UIColor clearColor]];
        [_listTable setBackgroundColor:[UIColor clearColor]];
        _listTable.clipsToBounds=NO;
        [self.view addSubview:_listTable];
        [self.view insertSubview:_listTable atIndex:0];
        
        UIView *view =[ [UIView alloc]init];
        view.backgroundColor = [UIColor clearColor];
        [_listTable setTableFooterView:view];
        
        self.refreshControl = [[UIRefreshControl alloc]init];
        //    self.refreshControl.tintColor = [UIColor redColor];
        //    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
        self.refreshControl.attributedTitle = nil;
        [self.refreshControl addTarget:self action:@selector(getHistoryMessage) forControlEvents:UIControlEventValueChanged];
        [_listTable addSubview:_refreshControl];
        
//        if (@available(iOS 11.0, *)) {
//              _listTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;//UIScrollView也适用
//        }else {
//            self.automaticallyAdjustsScrollViewInsets = NO;
//        }
    }
    return _listTable;
}


// 通告栏 eg: “国庆大酬宾。
- (UIView *)notifitionTopViewWithisShowTopView:(BOOL) isShow  Title:(NSString *) title  addressUrl:(NSString *)url iconUrl:(NSString *)icoUrl{

    if (!_notifitionTopView && isShow && ![@"" isEqual:zcLibConvertToString(title)]) {
        _notifitionTopView = [[UIView alloc]init];
        _notifitionTopView.frame = CGRectMake(0, NavBarHeight, viewWidth, 40);
        _notifitionTopView.backgroundColor = [ZCUITools getNotifitionTopViewBgColor];
        _notifitionTopView.alpha = 0.8;
        
        UITapGestureRecognizer * tapAction = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(jumpWebView:)];
        
       
        // icon
        ZCUIImageView * icon = [[ZCUIImageView alloc]initWithFrame:CGRectMake(10, 11, 18,18)];
        if (![@"" isEqual:zcLibConvertToString(icoUrl)]) {
           [icon loadWithURL:[NSURL URLWithString:zcUrlEncodedString(icoUrl)] placeholer:[ZCUITools zcuiGetBundleImage:@"ZCIcon_notification_Speak"] showActivityIndicatorView:NO];
        }else{
            [icon setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_notification_Speak"]];
        }
        
        icon.contentMode = UIViewContentModeScaleAspectFill;
        [icon setBackgroundColor:[UIColor clearColor]];
        [icon addGestureRecognizer:tapAction];
        [_notifitionTopView addSubview:icon];
        
        
        // title
        UILabel * titleLab = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(icon.frame) +10, 12, viewWidth - 30- 10-10 - icon.frame.size.width, 16)];
        titleLab.font = [ZCUITools zcgetNotifitionTopViewFont];
        titleLab.textColor = [ZCUITools getNotifitionTopViewLabelColor];
        titleLab.text = title;
        [titleLab addGestureRecognizer:tapAction];
        [_notifitionTopView addSubview:titleLab];
        
        if (![@"" isEqual:zcLibConvertToString(url)]) {
            // arraw
            UIImageView * arrawIcon = [[UIImageView alloc]initWithFrame:CGRectMake(viewWidth - 30, 11, 18, 18)];
            arrawIcon.backgroundColor = [UIColor clearColor];
            [arrawIcon setImage:[ZCUITools zcuiGetBundleImage:@"ZCicon_web_back_disabled"]];
            arrawIcon.transform = CGAffineTransformMakeRotation(M_PI);
            arrawIcon.contentMode = UIViewContentModeScaleAspectFill;
            [arrawIcon addGestureRecognizer:tapAction];
            [_notifitionTopView addSubview:arrawIcon];
            
        }
        [_notifitionTopView addGestureRecognizer:tapAction];
        [self.view addSubview:_notifitionTopView];
        _notifitionTopView.hidden = !isShow;
    }
    return _notifitionTopView;
}

- (void)jumpWebView:(UITapGestureRecognizer*)tap{
//    NSLog(@"跳转到web");
    // 目前PC 没有设置点击通告之后关闭通告的地方，所以取消这个设置。
//    if ([self getZCLibConfig].announceClickFlag == 1) {
//        [self.notifitionTopView removeFromSuperview];
//        self.notifitionTopView = nil;
//    }
    if ([self getZCLibConfig].announceClickFlag == 1 && ![@"" isEqual:[self getZCLibConfig].announceClickUrl] ) {
        [self cellItemLinkClick:nil type:ZCChatCellClickTypeOpenURL obj:[self getZCLibConfig].announceClickUrl];
    }
}


-(UIButton *)newWorkStatusButton{
    if(!_newWorkStatusButton){
        _newWorkStatusButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [_newWorkStatusButton setFrame:CGRectMake(0, NavBarHeight, viewWidth, 40)];
        [_newWorkStatusButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        [_newWorkStatusButton setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_tag_nonet"] forState:UIControlStateNormal];
        [_newWorkStatusButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_newWorkStatusButton setBackgroundColor:UIColorFromRGBAlpha(BgNetworkFailColor, 0.8)];
        [_newWorkStatusButton setTitle:[NSString stringWithFormat:@" %@",ZCSTLocalString(@"当前网络不可用，请检查您的网络设置")] forState:UIControlStateNormal];
        [_newWorkStatusButton setTitleColor:UIColorFromRGB(TextNetworkTipColor) forState:UIControlStateNormal];
        [_newWorkStatusButton.titleLabel setFont:[ZCUITools zcgetVoiceButtonFont]];
        [_newWorkStatusButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        [self.view addSubview:_newWorkStatusButton];
        
        _newWorkStatusButton.hidden=YES;
    }
    return _newWorkStatusButton;
}

-(UIButton *)goUnReadButton{
    if(!_goUnReadButton){
        _goUnReadButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [_goUnReadButton setFrame:CGRectMake(viewWidth - 120, NavBarHeight+40, 140, 40)];
        [_goUnReadButton setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_NewMessages"] forState:UIControlStateNormal];
        [_goUnReadButton setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_NewMessages"] forState:UIControlStateHighlighted];

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
    }
    return _goUnReadButton;
}

-(UIButton *)socketStatusButton{
    if(!_socketStatusButton){
        _socketStatusButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [_socketStatusButton setFrame:CGRectMake(60, NavBarHeight-44, viewWidth-120, 44)];
        [_socketStatusButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_socketStatusButton setBackgroundColor:[UIColor clearColor]];
        [_socketStatusButton setTitle:[NSString stringWithFormat:@"  %@",ZCSTLocalString(@"收取中...")] forState:UIControlStateNormal];
        [_socketStatusButton setTitleColor:[ZCUITools zcgetsocketStatusButtonTitleColor] forState:UIControlStateNormal];
        [_socketStatusButton.titleLabel setFont:[ZCUITools zcgetTitleFont]];
        [_socketStatusButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [self.view addSubview:_socketStatusButton];
        _socketStatusButton.hidden=YES;
        
        UIActivityIndicatorView *_activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityView.hidden=YES;
        _activityView.tag = 1;
        _activityView.center = CGPointMake(_socketStatusButton.frame.size.width/2 - 50, 22);
        [_socketStatusButton addSubview:_activityView];
    }
    return _socketStatusButton;

    
}

-(void)createChatView{
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
    
    // 评价关闭按钮会被截掉
    self.view.clipsToBounds = YES;
    
    // 创建顶部导航
    [self createTitleView];
    
    // 创建table
    [self createTable];
    
    // 创建底部输入框键盘的View
    _zcKeyboardView = [ZCUIChatKeyboard initWihtConfigView:self.view table:_listTable delegate:self];
    
    // 评价页面是否消失
    _isDismissSheetPage = YES;
    
    if (ZC_iPhoneX) {
        UIView * botView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 34, ScreenWidth, 34)];
        botView.backgroundColor = [ZCUITools zcgetBackgroundBottomColor];
        [self.view addSubview:botView];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    navBarHide=self.navigationController.navigationBarHidden;
//    _cellsHeight = [[NSMutableArray alloc] init];

//    KNBOrderViewController *orderVC = [[KNBOrderViewController alloc] init];
//    [self addChildViewController:orderVC];
    // table 置顶
    if (iOS7) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        // 设置页面不能使用边缘手势关闭
        if(self.navigationController!=nil){
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }
    
    // 创建页面UI
    [self createChatView];
    
    // 通知外部可以更新UI
    if(PageClickBlock){
        PageClickBlock(self,ZCPageBlockLoadFinish);
    }
    
    _listArray = [[NSMutableArray alloc] init];
    [[self getZCAPIServer] setHost:self.zckitInfo.apiHost];
    
    // 判断初始化信息
    [self checkInitAction];
    
    // 播放音频初始化
    _voiceTools = [[ZCUIVoiceTools alloc] init];
    _voiceTools.delegate  = self;
    
    // 网络监听
    _netWorkTools = [[ZCLibNetworkTools alloc] init];
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // 由于没有使用系统nav，所以需要隐藏
    [self.navigationController setNavigationBarHidden:YES];
    
    [_zcKeyboardView handleKeyboard];
    
    // 通道保护
    if([self getZCLibConfig] && [self getZCLibConfig].isArtificial){
        [[ZCIMChat getZCIMChat] checkConnected];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netWorkChanged:) name:ZCNotification_NetworkChange object:nil];
    
    
    [[ZCIMChat getZCIMChat] setChatPageState:ZCChatPageStateActive];
    
   
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // 还原客户的设置
    if(!navBarHide){
        [self.navigationController setNavigationBarHidden:navBarHide];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[ZCIMChat getZCIMChat] setChatPageState:ZCChatPageStateBack];
    
}


#pragma mark --  判断初始化条件

-(void) checkInitAction{
    [[ZCIMChat getZCIMChat] setChatPageState:ZCChatPageStateActive];
   
    
    // 判断是否需要重新初始化
    if([ZCSobotCore checkInitParameterChanged]){
        
        // 初始化记录传入的技能组
        [[NSUserDefaults standardUserDefaults] setObject:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.skillSetId) forKey:@"UserDefaultGroupID"];
        [[NSUserDefaults standardUserDefaults] setObject:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.skillSetName) forKey:@"UserDefaultGroupName"];
        
        
        // 展示智齿loading
        [[ZCUILoading shareZCUILoading] showAddToSuperView:self.view];
        
        //设置初始化页面动画效果
        [self showSoketConentStatus:201];
        
        // 历史记录重复问题,NO 改为YES
        [self initConfigData:YES];
    }else{
        /**
         *  设置初始化页面动画效果
         */
        [self configInitView];
        
        // 必须设置，不然收不到消息
        [ZCIMChat getZCIMChat].delegate = nil;
        [ZCIMChat getZCIMChat].delegate = self;
   
        /**
         *  添加新数据
         */
        if([ZCIMChat getZCIMChat].messageArr!=nil && [ZCIMChat getZCIMChat].messageArr.count > 0){
            [_listArray addObjectsFromArray:[ZCIMChat getZCIMChat].messageArr];
        }
        
        
        _cidsArr = [self getShareMS].cidsArray;
        if(_cidsArr !=nil && _cidsArr.count>0){
            _currentCid = [_cidsArr lastObject];
            [_cidsArr removeAllObjects];
        }else{
            _isNoMore = YES;
            _currentCid = nil;
        }
        
        _isHadLoadHistory = YES;
        _isLoadCids = YES;
        
        
        if([self getZCLibConfig].isArtificial){
            // 设置昵称
            [self setTitleName:[ZCIMChat getZCIMChat].libConfig.senderName];
            _receivedName = [ZCIMChat getZCIMChat].libConfig.senderName;
        }
        
        int index = -1;
        if(_listArray!=nil && _listArray.count>0){
            // 仅人工 排队状态
            if ([self getZCLibConfig].type == 2 && [[_listArray lastObject] tipStyle]  == ZCReceivedMessageWaiting) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [_zcKeyboardView setKeyBoardStatus:WAITSTATUS];
                });
                [self setTitleName:ZCSTLocalString(@"排队中...")];
            }
            
            
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
            [_listTable reloadData];
        }else{
            // 显示到顶了，没有更多
            _isNoMore = YES;
        }
        
        
        
        /**
         *  todo 判断未读消息数
         */
        // 此处需要在 ZCUIKitManager类中处理标记，解决ZCUIConfigManager中为空的问题  先清理掉原来的商品信息，在添加未读消息数
        int unReadNum = [[ZCIMChat getZCIMChat] getUnReadNum];
        
        if (unReadNum >=1 && _listArray.count >= unReadNum) {
            lineModel = [self createMessageToArrayByAction:ZCTipCellMessageNewMessage type:0 name:@"" face:@"" tips:2 content:nil];
            
            [_listArray insertObject:lineModel atIndex:_listArray.count - unReadNum];
        }
        if(unReadNum >= 10){
            [self.goUnReadButton setTitle:[NSString stringWithFormat:@" %d%@",unReadNum,[NSString stringWithFormat:@"%@",ZCSTLocalString(@"条未读消息")]] forState:UIControlStateNormal];
            self.goUnReadButton.hidden = NO;
        }
        
        
        // 显示商品信息
        if(self.zckitInfo.productInfo!=nil && [self getZCLibConfig].isArtificial  && ![@"" isEqualToString:self.zckitInfo.productInfo.title] && ![@"" isEqualToString:self.zckitInfo.productInfo.link]){
            [_listArray addObject:[self createMessageToArrayByAction:ZCTipCellMessageNullMessage type:0 name:@"" face:@"" tips:ZCReceivedMessageUnKonw content:nil]];
        }

        [_listTable reloadData];
        
        [self scrollTableToBottom];
    }
}



/**
 初始化页面数据

 @param isFrist 是否第一次初始化
 @param
 */
-(void)initConfigData:(BOOL) isFrist{
    
    [ZCLogUtils logHeader:LogHeader debug:@"初始化方法调用"];
    
    _isInitLoading=YES;
    
    self.isDoConnectedUser = NO;
    
    // 清理参数
    [[ZCUIConfigManager getInstance] cleanObjectMenorery];
    
    if(!isFrist){
        // 清理参数
        _isClearnHistory = NO;
        _isNoMore = NO;
    }
    
    if ([self getZCLibConfig].type == 2) {
        [ZCStoreConfiguration setZCParamter:KEY_ZCISROBOTHELLO value:@"1"];
    }else{
        [ZCStoreConfiguration setZCParamter:KEY_ZCISROBOTHELLO value:@"0"];
    }
    
  
#pragma mark ---TODO   排队的model的存储
    [ZCIMChat getZCIMChat].waitMessage = nil;
 
    [ZCUIConfigManager getInstance].kitInfo = self.zckitInfo;
    
    __weak ZCUIChatController *safeSelf = self;
    
    [[[ZCUIConfigManager getInstance] getZCAPIServer] initSobotSDK:^(ZCLibConfig *config) {
        [safeSelf showSoketConentStatus:200];
        [ZCLogUtils logHeader:LogHeader debug:@"%@",config];
        
        NSString *isblack = @"0";
        if (config.isblack == YES) {
            isblack = @"1";
        }
        [ZCStoreConfiguration setZCParamter:KEY_ZCISOFFLINEBEBLACK value:isblack];
                
        // 必须设置，不然收不到消息
        [ZCIMChat getZCIMChat].delegate = nil;
        [ZCIMChat getZCIMChat].delegate = safeSelf;
        
        
        
        [safeSelf configInitView];
        
        // 此处为赋值设备ID 为未读消息数做处理
        [ZCLibClient getZCLibClient].libInitInfo = config.zcinitInfo;
        
        // 智齿loading消失
        [[ZCUILoading shareZCUILoading] dismiss];
        
        _currentCid = config.cid;
        
        if (isFrist) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 获取历史记录
                [safeSelf getHistoryMessage];
                // 获取cid列表
                [safeSelf getHistoryCids];
            });
        }
        
        
        
    } error:^(ZCNetWorkCode status) {
        [self showSoketConentStatus:2000];
        if(!isFrist){
//            [safeSelf.zcKeyboardView setRobotViewStatusType:AGAINACCESSASTATUS];
            [safeSelf.zcKeyboardView setKeyBoardStatus:NEWSESSION_KEYBOARD_STATUS];
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[self getShareMS] destoryConfigManager];
                [safeSelf goBackIsKeep];
            });
        }
        safeSelf.isInitLoading=NO;
    } appIdIncorrect:^(NSString *appId) {
        if(!isFrist){
//            [safeSelf.zcKeyboardView setRobotViewStatusType:AGAINACCESSASTATUS];
            [safeSelf.zcKeyboardView setKeyBoardStatus:NEWSESSION_KEYBOARD_STATUS];
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[self getShareMS] destoryConfigManager];
                [safeSelf goBackIsKeep];
            });
        }
        safeSelf.isInitLoading=NO;
    }];
}


/**
 根据初始化结构，设置页面

 isStartTipTime 是否启动页面定时器
 */
-(void)configInitView{
    
    ZCLibConfig * config = [self getZCLibConfig];
    if(config.type ==1 || config.type == 3 || (config.type == 4 && ![self getZCLibConfig].isArtificial)){
        _receivedName = config.robotName;
        // 设置昵称
        [self setTitleName:_receivedName];
    }
    
    // 启动计时器
    [[self getShareMS] startTipTimer];
    
    // 添加页面代理
    [[self getShareMS] setDelegate:self];
    // 添加输入框
    [[self getShareMS]setInputListener:_zcKeyboardView.zc_chatTextView];
    _isInitLoading = NO;
    
    // 设置键盘样式
    [_zcKeyboardView setInitConfig:config];
    
    // 设置仅人工，人工不在线，并且是在黑名单中。
    if (config.type == 2  && config.isblack) {
        
        // 手动添加，无需修改业务逻辑。
        [self addTipsListenerMessage:ZCTipCellMessageIsBlock];
        // 设置昵称
        [self setTitleName:ZCSTLocalString(@"暂无客服在线")];
    }
    
    BOOL isShowNotifion = NO;
    if ([self getZCLibConfig].announceMsgFlag == 1) {
        isShowNotifion = YES;
    }
    // 初始化结束后添加通告
    [self notifitionTopViewWithisShowTopView:isShowNotifion
                                       Title:[self getZCLibConfig].announceMsg
                                  addressUrl:[self getZCLibConfig].announceClickUrl
                                     iconUrl:[ZCLibClient getZCLibClient].libInitInfo.notifitionIconUrl];
}



// 清空聊天记录代理
- (void)actionSheet:(ZCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        // 清空历史记录
        [_listArray removeAllObjects];
        _isNoMore = NO;
        [_listTable reloadData];
        _isClearnHistory = YES;
        
//        __weak ZCUIChatController *safeVC = self;
        [[self getZCAPIServer] cleanHistoryMessage:[self getZCLibConfig].uid success:^(NSData *data) {
//            [ZCLogUtils logHeader:LogHeader info:@"删除聊天记录：%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
//            safeVC.isNoMore = NO;
//            [_listTable reloadData];
            
        } fail:^(ZCNetWorkCode errorCode) {
            
        }];
        
    }
}


// 页面点击事件
-(IBAction)buttonClick:(UIButton *) sender{
    [super buttonClick:sender];
    
    // 父类已经实现，子类不需要
    if(sender.tag == BUTTON_MORE){
//        // 隐藏键盘
        [_zcKeyboardView hideKeyboard];
//
//        [super buttonClick:sender];
    }
    
    if(sender.tag == BUTTON_BACK){
        // 隐藏键盘
        [_zcKeyboardView hideKeyboard];
   
        // 如果用户开起关闭时显示评价的弹框
        if (self.zckitInfo.isOpenEvaluation) {
            
             //  1.是否转接过人工   （人工的评价逻辑）
             //  2.本次会话没有评价过人工
             //  3.没有被拉黑过
             //  4.和人工讲过话
             //  5.仅人工模式，不能评价机器人
             
            if (([self getZCLibConfig].isArtificial || [ZCStoreConfiguration getZCIntParamter:KEY_ZCISOFFLINE] == 1)
                && [ZCStoreConfiguration getZCIntParamter:KEY_ZCISEVALUATIONSERVICE] != 1
                && [ZCStoreConfiguration getZCIntParamter:KEY_ZCISSENDTOUSER] == 1
                && !([[self getZCLibConfig] isblack]||[ZCStoreConfiguration getZCIntParamter:KEY_ZCISOFFLINEBEBLACK] == 1)) {
                
                // 必须评价
                [self showCustomActionSheet:ServerSatisfcationBackType andDoBack:YES isInvitation:1 Rating:5 IsResolved:0];
                
            }else if([ZCStoreConfiguration getZCIntParamter:KEY_ZCISEVALUATIONROBOT] != 1
                     && [ZCStoreConfiguration getZCIntParamter:KEY_ZCISSENDTOROBOT] ==1
                     && [ZCStoreConfiguration getZCIntParamter:KEY_ZCISOFFLINE] == 0
                     && [self getZCLibConfig].type !=2
                     && ![self getZCLibConfig].isArtificial){
                // 必须评价
                [self showCustomActionSheet:RobotSatisfcationBackType andDoBack:YES isInvitation:1 Rating:5 IsResolved:0];
            }else{
                // [self.zcKeyboardView getKeyBoardViewStatus] == AGAINACCESSASTATUS
                if ([self.zcKeyboardView getKeyBoardViewStatus] == NEWSESSION_KEYBOARD_STATUS) {
                    [_listArray removeAllObjects];
                }
                [_listTable reloadData];
                [self goBackIsKeep];
            }
            
        }else{
            // [self.zcKeyboardView getKeyBoardViewStatus] == AGAINACCESSASTATUS
            if ([self.zcKeyboardView getKeyBoardViewStatus] == NEWSESSION_KEYBOARD_STATUS) {
                [_listArray removeAllObjects];
            }
            [self goBackIsKeep];
        }
        
    }
    
    // 未读消息数
    if(sender.tag == BUTTON_UNREAD){
        self.goUnReadButton.hidden = YES;
        int unNum = [[ZCIMChat getZCIMChat] getUnReadNum];
        if(unNum<=_listArray.count){
            CGRect  popoverRect = [_listTable rectForRowAtIndexPath:[NSIndexPath indexPathForRow:(_listArray.count - unNum) inSection:0]];
            [_listTable setContentOffset:CGPointMake(0,popoverRect.origin.y-40) animated:NO];
        }

    }
}


#pragma mark --  显示评价窗口
-(void)showCustomActionSheet:(int) sheetType andDoBack:(BOOL) isBack isInvitation:(int) invitationType Rating:(int)rating IsResolved:(int)isResolve{
    
    if (_isDismissSheetPage) {
        [_zcKeyboardView hideKeyboard];
        ZCUICustomActionSheet *sheet = [[ZCUICustomActionSheet alloc] initActionSheet:sheetType Name:_receivedName Cofig:[self getZCLibConfig] cView:self.view IsBack:isBack isInvitation:invitationType WithUid:[self getZCLibConfig].uid IsCloseAfterEvaluation:self.zckitInfo.isCloseAfterEvaluation Rating:rating IsResolved:isResolve IsAddServerSatifaction: _isAddServerSatifaction];

        sheet.delegate=self;
        [sheet showInView:self.view];
        
        _isDismissSheetPage = NO;
    }
}



// 执行返回操作
-(void)goBackIsKeep{
    [[ZCIMChat getZCIMChat] setChatPageState:ZCChatPageStateBack];
    
    
    // 返回或者到启动页面之后 将键盘的delegate和键盘的类清掉 不对其类中的方法做调用（会崩）
    if(_zcKeyboardView){
        // 隐藏技能组
        [_zcKeyboardView dismisSkillsetView];
        
        [_zcKeyboardView removeKeyboardObserver];
        
        _zcKeyboardView.delegate = nil;
        _zcKeyboardView = nil;
    }
    
    if (animateView) {
        [animateView stopAnimating];
    }
    if (_voiceTools) {
        [_voiceTools stopVoice];
        _voiceTools.delegate = nil;
        _voiceTools  = nil;
    }
    if (playModel) {
        playModel.isPlaying = NO;
    }
    
    if(_netWorkTools){
        [_netWorkTools removeNetworkObserver];
        _netWorkTools = nil;
    }
        
    if(lineModel!=nil){
        [_listArray removeObject:lineModel];
    }
    
    // 清理参数 会话保持
    [[ZCUIConfigManager getInstance] cleanObjectMenorery];
    
    // 如果通道没有建立成功，则清空数据，下次重新初始化
    if(!isStartConnectSockt){
        [[self getShareMS] setCidsArray:_cidsArr];
        
        if ([ZCIMChat getZCIMChat].messageArr) {
            [[ZCIMChat getZCIMChat].messageArr removeAllObjects];
        }else{
            [ZCIMChat getZCIMChat].messageArr = [[NSMutableArray alloc] init];
        }
        
        [[ZCIMChat getZCIMChat].messageArr addObjectsFromArray:_listArray];
        [_listArray removeAllObjects];
        _listArray = nil;
        
        
        [ZCIMChat getZCIMChat].delegate   = self;
        
    }
    
    // 返回进入SDK之前navc的样式
    if(!navBarHide){
        [self.navigationController setNavigationBarHidden:NO];
    }
    
    if(iOS7){
        // 设置页面不能使用边缘手势关闭
        if(self.navigationController!=nil){
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }
    
    if(PageClickBlock){
        PageClickBlock(self,ZCPageBlockGoBack);
    }
    
    
    if(self.navigationController != nil ){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}


/**
 根据当前条件类型，封装消息实体，并添加到当前集合中展现

 @param action 提示类型
 @param msgType 消息类型
 @param uname 当前发送名称
 @param face 头像
 @param tipStyle 是不是提醒，不是0都是提示语
 @param messageText 消息内容
 @return ZCLibMessage对象
 */
-(ZCLibMessage *)createMessageToArrayByAction:(ZCTipCellMessageType) action type:(int)msgType name:(NSString *) uname face:(NSString *) face tips:(int) tipStyle content:(NSString *)messageText{
    
    if (action == ZCTipCellMessageRobotHelloWord) {
        if([[ZCStoreConfiguration getZCParamter:KEY_ZCISROBOTHELLO] intValue] == 1){
            return nil;
        }
        [ZCStoreConfiguration setZCParamter:KEY_ZCISROBOTHELLO value:@"1"];
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
    }else if (action == ZCTipCellMessageUserNoAdmin){
        msg = [temModel getTipMsg:action content:[self getZCLibConfig].adminNonelineTitle isOpenLeave:[self getZCLibConfig].msgFlag];
    }else{
        msg = [temModel getTipMsg:action content:messageText isOpenLeave:[self getZCLibConfig].msgFlag];
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
    
    if(tipStyle==2){
        temModel.cid = @"";
    }
    // 排除以下为新消息
    if(tipStyle != 2 && tipStyle != ZCReceivedMessageUnKonw){
        [_listArray addObject:temModel];
        [_listTable reloadData];
        [self scrollTableToBottom];
        
    }
    return temModel;
}


#pragma mark 实现UIManager监听(定时器监听)
-(void)onTimerListener:(NSTimerListenerType)type{
    if(type == NSTimerListenerTypeAdminTimeOut){
        if([self getZCLibConfig].serviceOutTimeFlag){
           [self addTipsListenerMessage:ZCTipCellMessageAdminTipWord];
        }
    }
    else if(type == NSTimerListenerTypeUserTimeOut){
        if ([self getZCLibConfig].customOutTimeFlag) {
           [self addTipsListenerMessage:ZCTipCellMessageUserTipWord];
        }
    }
}


#pragma mark 实现智齿消息监听

/**
 收到消息时调用

 @param message 收到的消息对象
 @param num 未读消息数量
 @param obj 收到的JSON对象
 @param type 下推消息类型
 */
-(void)onReceivedMessage:(ZCLibMessage *)message unReaded:(int)num object:(id)obj showType:(ZCReceivedMessageType)type{
    self.vcTitle = self.titleLabel.text;
    
    [[ZCUIConfigManager getInstance] cleanAdminCount];
    //[_zcKeyboardView getKeyBoardViewStatus] == AGAINACCESSASTATUS
    if([_zcKeyboardView getKeyBoardViewStatus] == NEWSESSION_KEYBOARD_STATUS){
        return;
    }
    
    if(type==ZCReceivedMessageUnKonw){
        return;
    }
    
    _receivedName = message.senderName;

    [self setTitleName:_receivedName];

    if ([self getZCLibConfig].type == 2 && [self.titleLabel.text isEqualToString:ZCSTLocalString(@"排队中...")] && ![self getZCLibConfig].isArtificial) {
        // 设置昵称
        [self setTitleName:ZCSTLocalString(@"暂无客服在线")];
    }
    
    if(type == ZCReceivedMessageTansfer){
        return;
    }

    
    if(type==ZCReceivedMessageOnline){
        // 转人工成功
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [_zcKeyboardView setUserViewStatus:[ZCUITools zcgetOpenRecord]];
            [_zcKeyboardView setKeyBoardStatus:SERVERV_KEYBOARD_STATUS];
            
        });
        
    }
   
    if(type==ZCReceivedMessageOfflineBeBlack ||
              type==ZCReceivedMessageOfflineByAdmin ||
              type==ZCReceivedMessageOfflineByClose ||
              type== ZCReceivedMessageOfflineToLong ||
              type == ZCReceivedMessageToNewWindow){
         [self setTitleName:self.vcTitle];
        // 设置重新接入时键盘样式
//        [_zcKeyboardView  setRobotViewStatusType:AGAINACCESSASTATUS];
        [_zcKeyboardView setKeyBoardStatus:NEWSESSION_KEYBOARD_STATUS];
        if ( obj !=nil && [obj isKindOfClass:[NSNumber class]] && ![obj boolValue]) {
            // 记录新会话之前是否是人工的状态  和人工超下线
            [ZCStoreConfiguration setZCParamter:KEY_ZCISOFFLINE value:@"0"];
        }else{
            [ZCStoreConfiguration setZCParamter:KEY_ZCISOFFLINE value:@"1"];
        }
        
        // 拉黑
        if (type == ZCReceivedMessageOfflineBeBlack) {
            [ZCStoreConfiguration setZCParamter:KEY_ZCISOFFLINEBEBLACK value:@"1"];
        }
        for(ZCLibMessage *item in [ZCIMChat getZCIMChat].messageArr){
            if(item.tipStyle>0){
                item.sysTips=[item.sysTips stringByReplacingOccurrencesOfString:@"重新接入" withString:@""];
            }
        }
       
    }
    
    if (type == ZCReceivedMessageEvaluation){
        BOOL isUser = NO;
        if ([[ZCStoreConfiguration getZCParamter:KEY_ZCISSENDTOUSER] intValue] == 1) {
            isUser = YES;
        }
        
        [ZCLogUtils logHeader:LogHeader debug:@"当前发送状态：%d",isUser];
        // 是否转接过人工  或者当前是否是人工 （人工的评价逻辑）
        if (([ZCStoreConfiguration getZCIntParamter:KEY_ZCISOFFLINE] == 1
             || [self getZCLibConfig].isArtificial)
            && isUser
            && ![ZCStoreConfiguration getZCIntParamter:KEY_ZCISEVALUATIONSERVICE]) {
//            [self showCustomActionSheet:1 andDoBack:NO isInvitation:0];
            // 209 客服主动邀请评价
            _isAddServerSatifaction = YES;
        }else{
            return;
        }
        
    }
    
    [self addReceivedNameMessageToList:message];
    
}


/**
 添加消息到列表

 @param message 当前要添加的消息
 */
-(void)addReceivedNameMessageToList:(ZCLibMessage *) message{
    if(message==nil){
        return;
    }
    // 排队 和  接入人工成功
    if (message.tipStyle == ZCReceivedMessageWaiting) {
        if([ZCIMChat getZCIMChat].libConfig.isArtificial){
            _receivedName = [ZCIMChat getZCIMChat].libConfig.robotName;
//            [_zcKeyboardView setRobotViewStatusType:ROBOTSTATUS];
            [_zcKeyboardView setKeyBoardStatus:ROBOT_KEYBOARD_STATUS];
            [ZCIMChat getZCIMChat].libConfig.isArtificial = NO;
        }
        
        if ([self getZCLibConfig].type == 2 && ![self getZCLibConfig].isArtificial) {
            // 设置昵称
            _receivedName = ZCSTLocalString(@"排队中...");
        }
        // 先清掉人工不在时的留言Tipcell
        if (_listArray !=nil && _listArray.count>0 && ![self getZCLibConfig].isArtificial) {
            NSMutableArray *indexs = [[NSMutableArray alloc] init];
            for (int i = (int)_listArray.count-1; i>=0 ; i--) {
                ZCLibMessage *libMassage = _listArray[i];
                if ( [libMassage.sysTips hasSuffix:ZCSTLocalString(@"留言")] || [libMassage.sysTips hasPrefix:ZCSTLocalString(@"排队中，您在队伍中")] ) {
                    [indexs addObject:[NSString stringWithFormat:@"%d",i]];
                }
                
            }
            if(indexs.count>0){
                for (NSString *index in indexs) {
                    [_listArray removeObjectAtIndex:[index intValue]];
                }
                [_listTable reloadData];
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
                [_listTable reloadData];
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
                if ([libMassage.sysTips hasSuffix:ZCSTLocalString(@"留言")] || [libMassage.sysTips isEqualToString:[self getZCLibConfig].adminNonelineTitle]) {
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
                [_listTable reloadData];
            }
        }
        
    }
    
    
    // 过滤多余的满意度cell
    if (message.tipStyle == ZCReceivedMessageEvaluation) {
        if (_listArray !=nil && _listArray.count>0 ) {
            NSMutableArray *indexs = [[NSMutableArray alloc] init];
            for (int i = (int)_listArray.count-1; i>=0 ; i--) {
                ZCLibMessage *libMassage = _listArray[i];
                if ( libMassage.tipStyle == ZCReceivedMessageEvaluation) {
                    [indexs addObject:[NSString stringWithFormat:@"%d",i]];
                }
                
            }
            if(indexs.count>0){
                for (NSString *index in indexs) {
                    [_listArray removeObjectAtIndex:[index intValue]];
                }
                [_listTable reloadData];
            }
            [indexs removeAllObjects];
        }
    }
     [_listArray addObject:message];
    
    // 是否添加商品信息
    if(message.richModel!=nil && message.richModel.msgType == 0 && [message.richModel.msg isEqual:[self getZCLibConfig].adminHelloWord]){
        if(self.zckitInfo.productInfo!=nil && ![@"" isEqualToString:self.zckitInfo.productInfo.title] && ![@"" isEqualToString:self.zckitInfo.productInfo.link]){
            [_listArray addObject:[self createMessageToArrayByAction:ZCTipCellMessageEvaluation type:0 name:@"" face:@"" tips:ZCReceivedMessageUnKonw content:nil]];
        }
    }

    
    [_listTable reloadData];
    [self scrollTableToBottom];
}

// 接收链接改变
-(void)onConnectStatusChanged:(ZCConnectStatusCode)status{
    
    if(status == ZC_CONNECT_KICKED_OFFLINE_BY_OTHER_CLIENT){
        if(self.navigationController){
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"您打开了新窗口，本次会话结束") duration:1.0f view:self.view.window.rootViewController.view position:ZCToastPositionCenter];
        }else{
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"您打开了新窗口，本次会话结束") duration:1.0f view:self.view position:ZCToastPositionCenter];
        }
    }else{
        [self showSoketConentStatus:status];
    }
}



// 长连接通道发生变化时显示连接状态
-(void)showSoketConentStatus:(ZCConnectStatusCode ) status{
    // 连接中
    if(status == ZC_CONNECT_START){
        UIButton *btn = [self socketStatusButton];
        [btn setTitle:[NSString stringWithFormat:@"  %@",ZCSTLocalString(@"收取中...")] forState:UIControlStateNormal];
        UIActivityIndicatorView *activityView  = [btn viewWithTag:1];
        btn.hidden = NO;
        activityView.hidden = NO;
        [activityView startAnimating];
        
        isStartConnectSockt = YES;
        
    }else{
        isStartConnectSockt = NO;
        
        UIButton *btn = [self socketStatusButton];
        UIActivityIndicatorView *activityView  = [btn viewWithTag:1];
        [activityView stopAnimating];
        activityView.hidden = YES;
        
        if(status == ZC_CONNECT_SUCCESS){
            btn.hidden = YES;
        }else{
            [btn setTitle:[NSString stringWithFormat:@"%@",ZCSTLocalString(@"未连接")] forState:UIControlStateNormal];
        }
    }
}


/**
 获取会话编号列表
 */
-(void)getHistoryCids{
    if(_cidsArr==nil){
        _cidsArr  = [[NSMutableArray alloc] init];
    }else{
        [_cidsArr removeAllObjects];
    }
    
    _isLoadCids = NO;
    
    
    [[self getZCAPIServer] getChatUserCids:[ZCLibClient getZCLibClient].libInitInfo.scopeTime config:[self getZCLibConfig] start:^{
        
    } success:^(NSDictionary *dict, ZCNetWorkCode sendCode) {
        _isLoadCids = YES;
//        NSLog(@"获取的cid列表字典 == %@",dict);
        NSArray *arr = dict[@"data"][@"cids"];
        if(zcLibIs_null(arr)  || arr.count == 0){
            _isNoMore = YES;
        }else{
            for (NSString *itemCid in arr) {
                [_cidsArr addObject:itemCid];
            }
        }
    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        
    }];
}



/**
 是否第一次加载

 @param isLoadMessage YES，第一次加载不判断是否已经存在
 */
-(void)getHistoryMessage{
    if(_isHadLoadHistory && _listArray.count > 0){
        // 清除过历史记录
        if (_isClearnHistory) {
            if([_refreshControl isRefreshing]){
                [_refreshControl endRefreshing];
            }

            _isClearnHistory = NO;
            _isNoMore = YES;
            // 记得刷新（否则页面无变化）
            [_listTable reloadData];
            return;
            
        }
      
        // 没有更多
        if(_isNoMore){
            if([_refreshControl isRefreshing]){
                [_refreshControl endRefreshing];
            }
            _isNoMore = YES;
            [_listTable reloadData];
            return;
        }
    }
    
    if(_currentCid == nil){
        if([_refreshControl isRefreshing]){
            [_refreshControl endRefreshing];
        }
        return;
    }
    
    BOOL isShowRobotHello = NO;
    
    // 判断是否显示机器人欢迎语
    // 不是人工、不是人工优先，不是仅人工、不是在线状态、不是排队状态、没显示过欢迎语
    if(![self getZCLibConfig].isArtificial
       && [self getZCLibConfig].type!=4
       && [self getZCLibConfig].type !=2
       && [self getZCLibConfig].ustatus!=1
       && [self getZCLibConfig].ustatus!=-2
       && [[ZCStoreConfiguration getZCParamter:KEY_ZCISROBOTHELLO] intValue] != 1){
        isShowRobotHello = YES;
    }
    
    __weak ZCUIChatController *safeVC = self;
    
    
    [[self getZCAPIServer] getHistoryMessages:_currentCid withUid:[self getZCLibConfig].uid  start:^{
        
    } success:^(NSMutableArray *messages, ZCNetWorkCode sendCode) {
        if([safeVC.refreshControl isRefreshing]){
            [safeVC.refreshControl endRefreshing];
        }
        
        // 判断是否第一次加载
        BOOL isFirst = !_isHadLoadHistory;
        _isHadLoadHistory = YES;
        
        if(safeVC.isLoadCids && _cidsArr!=nil && _cidsArr.count == 0){
            safeVC.isNoMore=YES;
        }
        
        if(messages && messages.count>0){
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:
                                    NSMakeRange(0,[messages count])];
            
            [safeVC.listArray insertObjects:messages atIndexes:indexSet];

            
            // 有离线消息数的情况下加入未读消息数，一定在欢迎语之前添加。
            /**
             *  todo 判断未读消息数
             */
            // 此处需要在 ZCUIKitManager类中处理标记，解决ZCUIConfigManager中为空的问题
            if (isFirst) {
                int unReadNum = [[ZCIMChat getZCIMChat] getUnReadNum];
                if(unReadNum>0 && safeVC.listArray.count > unReadNum){
                    if (unReadNum >=1 && safeVC.listArray.count > unReadNum) {
                        lineModel = [safeVC createMessageToArrayByAction:ZCTipCellMessageNewMessage type:0 name:@"" face:@"" tips:2 content:nil];
                        
                        [safeVC.listArray insertObject:lineModel atIndex:safeVC.listArray.count - unReadNum];
                    }
                    
                    if(unReadNum >= 10){
                        [safeVC.goUnReadButton setTitle:[NSString stringWithFormat:@" %d%@",unReadNum,[NSString stringWithFormat:@"%@",ZCSTLocalString(@"条未读消息")]] forState:UIControlStateNormal];
                        safeVC.goUnReadButton.hidden = NO;
                        
                    }
                }
            }
            

            
            [ZCLogUtils logHeader:LogHeader debug:ZCSTLocalString(@"当前页码：%d"),isFirst];
             // 第一次加载完成，添加问候语
            if(isShowRobotHello){
                [safeVC showRobotHello];
            }else{
                if(!isFirst){
                    [safeVC.listTable reloadData];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        CGRect  popoverRect = [safeVC.listTable rectForRowAtIndexPath:[NSIndexPath indexPathForRow:messages.count inSection:0]];
                        [safeVC.listTable setContentOffset:CGPointMake(0,popoverRect.origin.y-20) animated:NO];
                    });
                }else{
                    [safeVC.listTable reloadData];
                    [safeVC scrollTableToBottom];
                }
            }
            
            if(_cidsArr!=nil && _cidsArr.count>0){
                NSString *lastCid = [_cidsArr lastObject];
                if([_currentCid isEqual:lastCid]){
                    [_cidsArr removeLastObject];
                }
                _currentCid = [_cidsArr lastObject];
                [_cidsArr removeLastObject];
            }else{
                _currentCid = nil;
            }
            
        }else{
            if(safeVC.isLoadCids && _cidsArr!=nil && _cidsArr.count>0){
                NSString *lastCid = [_cidsArr lastObject];
                if([_currentCid isEqual:lastCid]){
                    [_cidsArr removeLastObject];
                }
                _currentCid = [_cidsArr lastObject];
                [_cidsArr removeLastObject];
                
                [self getHistoryMessage];
            }else{
                // 第一次加载完成，添加问候语
                if(isShowRobotHello){
                    [safeVC showRobotHello];
                }else{
                    [safeVC.listTable reloadData];
                }
            }
        }

    } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
        
        if([safeVC.refreshControl isRefreshing]){
            [safeVC.refreshControl endRefreshing];
        }
        
        // 第一次加载完成，添加问候语
        if(isShowRobotHello){
           [safeVC showRobotHello];
        }
    }];
}


// 添加机器人欢迎语
-(void)showRobotHello{
    ZCLibMessage *msg = [self createMessageToArrayByAction:ZCTipCellMessageRobotHelloWord type:0 name:[self getZCLibConfig].robotName face:[self getZCLibConfig].robotLogo tips:0 content:nil];
    
    // 返回空说明已经显示过了
    if(msg == nil){
//        NSLog(@"已经显示过了不在显示机器人欢迎语");
        return ;
    }
    
    // 获取机器人欢迎语引导语
    if([self getZCLibConfig].guideFlag == 1){
        __weak ZCUIChatController *safeVC = self;
        [[self getZCAPIServer] getRobotGuide:[self getZCLibConfig] robotFlag:[ZCLibClient getZCLibClient].libInitInfo.robotId start:^(ZCLibMessage *message) {
            
        } success:^(ZCLibMessage *message, ZCMessageSendCode sendCode) {
            
            [safeVC.listArray addObject:message];
            [safeVC.listTable reloadData];
            [safeVC scrollTableToBottom];
        } fail:^(ZCLibMessage *message, ZCMessageSendCode errorCode) {
            
        }];
    }
}




#pragma mark- UITableView delegate Start 聊天消息代理方法
// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

// 返回section高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(_isNoMore && section == 0){
        return TableSectionHeight;
    }
    if(section == 1 && _zcKeyboardView && !_zcKeyboardView.vioceTipLabel.hidden){
        return 40;
    }
    return 0;
}

// 返回section 的View
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(_isNoMore && section == 0){
    
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, TableSectionHeight)];
        [view setBackgroundColor:[UIColor clearColor]];
        
        UILabel *lbl=[[UILabel alloc] initWithFrame:CGRectMake(20, 19, viewWidth-40, TableSectionHeight -19)];
        lbl.font=[ZCUITools zcgetListKitDetailFont];
        lbl.backgroundColor = [UIColor clearColor];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        // 没有更多记录的颜色
        [lbl setTextColor:[ZCUITools zcgetTimeTextColor]];
        [lbl setAutoresizesSubviews:YES];
        [lbl setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
//        [lbl setText:Had_NO_MORE_DATA];
        [lbl setText:ZCSTLocalString(@"到顶了，没有更多")];
        [view addSubview:lbl];
        return view;
    }
    
    if(section == 1){
        
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 40)];
        [view setBackgroundColor:[UIColor clearColor]];
        return view;
    }
    
    return nil;
}

// 返回section下得行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 1){
        return 0;
    }
//    _cellsHeight = nil;
//    _cellsHeight = [[NSMutableArray alloc] initWithCapacity:_listArray.count];
    return _listArray.count;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    ZCLibMessage *model=[_listArray objectAtIndex:indexPath.row];
    ZCChatBaseCell *cell=nil;
    
    // 设置内容
    if(model.tipStyle>0){
        if (model.tipStyle == ZCReceivedMessageEvaluation) {
            cell = (ZCSatisfactionCell *)[tableView dequeueReusableCellWithIdentifier:cellSatisfactionIndentifier];
            if (cell == nil) {
                cell = [[ZCSatisfactionCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellSatisfactionIndentifier];
            }
        }else{
            // 聊天提示信息cell
            cell = (ZCTipsChatCell*)[tableView dequeueReusableCellWithIdentifier:cellTipsIdentifier];
            if (cell == nil) {
                cell = [[ZCTipsChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellTipsIdentifier];
            }
        }
    }else if(model.tipStyle == ZCReceivedMessageUnKonw){
        // 商品 或 订单
        NSString *goodsType = [ZCUIConfigManager getInstance].kitInfo.orderGoodsInfo.cardType;
        if ([@"商品" isEqualToString:goodsType]) {
            KNBGoodsCell *goodsCell = (KNBGoodsCell*)[tableView dequeueReusableCellWithIdentifier:kGoodsCellIndentifier];
            if (goodsCell == nil) {
                goodsCell = [[KNBGoodsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kGoodsCellIndentifier];
            }
            goodsCell.goodsInfo = nil;
            [goodsCell.btnSendGoods setHidden:NO];
            cell = goodsCell;
        }else{
            KNBOrderCell *goodsCell = (KNBOrderCell*)[tableView dequeueReusableCellWithIdentifier:kOrderCellIndentifier];
            if (goodsCell == nil) {
                goodsCell = [[KNBOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kOrderCellIndentifier];
            }
            goodsCell.goodsInfo = nil;
            [goodsCell.btnSendGoods setHidden:NO];
            cell = goodsCell;
        }
    }else if(model.richModel.msgType==1){
        cell = (ZCImageChatCell*)[tableView dequeueReusableCellWithIdentifier:cellImageIdentifier];
        if (cell == nil) {
            cell = [[ZCImageChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellImageIdentifier];
        }
    }else if(model.richModel.msgType==0){
        NSString *message = model.richModel.msg;
        // 判断是否为订单/商品信息
        KNBGoodsInfo *goodsInfo = nil;
        if ((goodsInfo = [self isJSONtoModel:message])){
            NSString *goodsType = goodsInfo.cardType;
            if ([@"商品" isEqualToString:goodsType]) {
                KNBGoodsCell *goodsCell = [tableView dequeueReusableCellWithIdentifier:kGoodsCellIndentifier];
                if (goodsCell == nil) {
                    goodsCell = [[KNBGoodsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kGoodsCellIndentifier];
                }
                goodsCell.goodsInfo = goodsInfo;
                [goodsCell.btnSendGoods setHidden:YES];
                cell = goodsCell;
            }else{
                KNBOrderCell *goodsCell = [tableView dequeueReusableCellWithIdentifier:kOrderCellIndentifier];
                if (goodsCell == nil) {
                    goodsCell = [[KNBOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kOrderCellIndentifier];
                }
                goodsCell.goodsInfo = goodsInfo;
                [goodsCell.btnSendGoods setHidden:YES];
                cell = goodsCell;
            }
        }else{ // 普通聊天文本
            cell = (ZCRichTextChatCell*)[tableView dequeueReusableCellWithIdentifier:cellRichTextIdentifier];
            if (cell == nil) {
                cell = [[ZCRichTextChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellRichTextIdentifier];
            }
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
    cell.delegate=self;
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
    }else{
        time = zcLibDateTransformString(format, zcLibStringFormateDate(model.ts));
    }
    
    if([self getZCLibConfig].isArtificial){
        model.isHistory = YES;
    }
    
    if(model.tipStyle == 2){
        time = @"";
    }
    
    [cell InitDataToView:model time:time];
//    [_cellsHeight addObject:[NSNumber numberWithFloat:cellHeight]];
//    _cellsHeight[indexPath.row] = [NSNumber numberWithFloat:cellHeight];
//    [_cellsHeight setObject:[NSNumber numberWithFloat:cellHeight] atIndexedSubscript:indexPath.row];

    [cell setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;

    return cell;
}

// table 行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

//    if (indexPath.row < _cellsHeight.count) {
//        CGFloat cellheight = [[_cellsHeight objectAtIndex:indexPath.row] floatValue];
//        NSLog(@"---row: %ld-----height: %lf",(long)indexPath.row,cellheight);
//        return cellheight;
//    }

    ZCLibMessage *model =[_listArray objectAtIndex:indexPath.row];
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

    if(model.tipStyle == 2){
        time = @"";
    }

    CGFloat cellheight = 0;

    // 设置内容
    if(model.tipStyle>0){

        if(model.tipStyle == ZCReceivedMessageEvaluation){
            // 评价cell的高度
            cellheight = [ZCSatisfactionCell getCellHeight:model time:time viewWith:viewWidth];
        }else{
            // 提示cell的高度
           cellheight = [ZCTipsChatCell getCellHeight:model time:time viewWith:viewWidth];
        }

    }else if(model.tipStyle == ZCReceivedMessageUnKonw){
        // 商品内容
//        cellheight = [ZCGoodsCell getCellHeight:model time:time viewWith:viewWidth];
        NSString *goodsType = [ZCUIConfigManager getInstance].kitInfo.orderGoodsInfo.cardType;
        if ([@"商品" isEqualToString:goodsType]) {
            KNBGoodsCell *goodsCell = (KNBGoodsCell*)[tableView dequeueReusableCellWithIdentifier:kGoodsCellIndentifier];
            if (goodsCell == nil) {
                goodsCell = [[KNBGoodsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kGoodsCellIndentifier];
            }
            goodsCell.goodsInfo = nil;
            [goodsCell.btnSendGoods setHidden:NO];
            cellheight = [goodsCell InitDataToView:model time:time];
        }else{

            KNBOrderCell *goodsCell = [tableView dequeueReusableCellWithIdentifier:kOrderCellIndentifier];
            if (goodsCell == nil) {
                goodsCell = [[KNBOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kOrderCellIndentifier];
            }
            goodsCell.goodsInfo = nil;
            [goodsCell.btnSendGoods setHidden:NO];
            cellheight = [goodsCell InitDataToView:model time:time];
        }
//        DLog(@"------%lf",cellheight);

    }else if(model.richModel.msgType==1){
        cellheight = [ZCImageChatCell getCellHeight:model time:time viewWith:viewWidth];
    }else if(model.richModel.msgType==0){
        // 判断是否为商品信息
        KNBGoodsInfo *goodsInfo = nil;
        if ((goodsInfo = [self isJSONtoModel:model.richModel.msg])){
            // 商品内容
            NSString *goodsType = goodsInfo.cardType;
            if ([@"商品" isEqualToString:goodsType]) {
                KNBGoodsCell *goodsCell = [tableView dequeueReusableCellWithIdentifier:kGoodsCellIndentifier];
                if (goodsCell == nil) {
                    goodsCell = [[KNBGoodsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kGoodsCellIndentifier];
                }
                goodsCell.goodsInfo = goodsInfo;
                [goodsCell.btnSendGoods setHidden:YES];
                cellheight = [goodsCell InitDataToView:model time:time];
            }else{
                KNBOrderCell *goodsCell = [tableView dequeueReusableCellWithIdentifier:kOrderCellIndentifier];
                if (goodsCell == nil) {
                    goodsCell = [[KNBOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kOrderCellIndentifier];
                }
                goodsCell.goodsInfo = goodsInfo;
                [goodsCell.btnSendGoods setHidden:YES];
                cellheight = [goodsCell InitDataToView:model time:time];
            }
        }else{
            cellheight = [ZCRichTextChatCell getCellHeight:model time:time viewWith:viewWidth];
        }
    }else if(model.richModel.msgType==2){
        cellheight = [ZCVoiceChatCell getCellHeight:model time:time viewWith:viewWidth];

    }else{
        cellheight = [ZCRichTextChatCell getCellHeight:model time:time viewWith:viewWidth];
    }
//    _cellsHeight[indexPath.row] = [NSNumber numberWithFloat:cellheight];
    return cellheight;
}

// table 行的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark- table cell delegate start
-(void)cellItemClick:(ZCLibMessage *)model type:(ZCChatCellClickType)type obj:(id)object{
    
    // 提醒本次会话已结束
    // [_zcKeyboardView getKeyBoardViewStatus] == AGAINACCESSASTATUS
    if ([_zcKeyboardView getKeyBoardViewStatus] == NEWSESSION_KEYBOARD_STATUS && type == ZCChatCellClickTypeItemChecked) {
        [self addTipsListenerMessage:ZCTipCellMessageOverWord];
        return;
    }
    
    if(type == ZCChatCellClickTypeSendGoosText && ![self getZCLibConfig].isArtificial){
        return;
    }
    if (type == ZCChatCellClickTypeShowToast) {
        [[ZCUIToastTools shareToast] showToast:[NSString stringWithFormat:@"   %@  ",ZCSTLocalString(@"复制成功！")] duration:1.0f view:self.view.window.rootViewController.view position:ZCToastPositionCenter Image:[ZCUITools zcuiGetBundleImage:@"ZCicon_successful"]];
        return;
    }
    
    // 点击满意度，调评价
    if (type == ZCChatCellClickTypeSatisfaction) {
        
        // 客服主动邀请评价
//       [self showCustomActionSheet:ServerSatisfcationNolType andDoBack:NO isInvitation:0 Rating:5 IsResolved:0];
    }
    
    if (type == ZCChatCellClickTypeLeaveMessage) {
        // 不直接退出SDK
        [self goLeaveMessageVC:ISNOCOLSE isShowToat:NO tipMsg:@""];
    }
    if(type==ZCChatCellClickTypeTouchImageYES){
        xhObj=object;
        [_zcKeyboardView hideKeyboard];
    }
    if(type==ZCChatCellClickTypeTouchImageNO){
        // 隐藏大图查看
        xhObj=nil;
    }
    
    if(type==ZCChatCellClickTypeItemChecked){
        // 向导内容
        NSDictionary *dict = model.richModel.suggestionArr[[object intValue]];
        if(dict==nil || dict[@"question"]==nil){
            return;
        }
        [self sendMessage:[NSString stringWithFormat:@"%d、%@",[object intValue]+1,dict[@"question"]] questionId:dict[@"docId"] type:ZCMessageTypeText duration:@""];
    }
    
    // 发送商品信息给客服
    if(type == ZCChatCellClickTypeSendGoosText){
        [self sendMessage:object questionId:@"" type:ZCMessageTypeText duration:@""];
    }
    
    // 重新发送
    if(type==ZCChatCellClickTypeReSend){
        // 当前的键盘样式是新会话的样式，重新发送的消息不在发送  （用户超时下线提示和会话结束提示）
//        [self.zcKeyboardView getKeyBoardViewStatus] == AGAINACCESSASTATUS
        if ([self.zcKeyboardView getKeyBoardViewStatus] == NEWSESSION_KEYBOARD_STATUS) {
            [_listTable reloadData];
            return;
        }
        
        
        [[self getZCAPIServer] sendMessage:model.richModel.msg questionId:@"" msgType:model.richModel.msgType duration:model.richModel.duration config:[self getZCLibConfig] robotFlag:[ZCLibClient getZCLibClient].libInitInfo.robotId start:^(ZCLibMessage *message) {
            model.sendStatus = 1;
            [_listTable reloadData];
        } success:^(ZCLibMessage *message, ZCMessageSendCode sendCode) {
            if(![self getZCLibConfig].isArtificial && sendCode==ZC_SENDMessage_New){
                NSInteger index = [_listArray indexOfObject:message];
                [_listArray insertObject:message atIndex:index+1];
                [_listTable reloadData];
                [self scrollTableToBottom];
            }else if(sendCode == ZC_SENDMessage_Success){
                model.sendStatus = 0;
                model.richModel.msgtranslation = message.richModel.msgtranslation;

                [_listTable reloadData];
            }else{
                model.sendStatus = 2;
                [_listTable reloadData];
            }
        } progress:^(ZCLibMessage *message) {
            model.progress = message.progress;
            [_listTable reloadData];
        } fail:^(ZCLibMessage *message, ZCMessageSendCode errorCode) {
            model.sendStatus = 2;
            [_listTable reloadData];
            
        }];
       
    }
    
    
        
    if(type==ZCChatCellClickTypePlayVoice  || type == ZCChatCellClickTypeReceiverPlayVoice){
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
            [[self getZCAPIServer] downFileWithURL:model.richModel.msg start:^{
                
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
    
    // 转人工
    if(type == ZCChatCellClickTypeConnectUser){
        [_zcKeyboardView turnUserServer:NO];
    }
    // 踩/顶   -1踩   1顶
    if(type == ZCChatCellClickTypeStepOn || type == ZCChatCellClickTypeTheTop){
        int status = (type == ZCChatCellClickTypeStepOn)?-1:1;
        
        [[self getZCAPIServer] rbAnswerComment:[self getZCLibConfig] message:model status:status start:^{
        
        } success:^(ZCNetWorkCode code) {
            if(status== -1){
                model.commentType = 3;
            }else{
                model.commentType = 2;
            }
            [_listTable  reloadData];
            
        } fail:^(ZCNetWorkCode errorCode) {
            
        }];
    }
}

-(void)cellItemLinkClick:(NSString *)text type:(ZCChatCellClickType)type obj:(NSString *)linkURL{
    
    if(type==ZCChatCellClickTypeOpenURL){
        if(LinkedClickBlock){
            LinkedClickBlock(linkURL);
        }else{
            if([linkURL hasPrefix:@"tel:"] || zcLibValidateMobile(linkURL)){
                callURL=linkURL;
                
                if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_9_x_Max) {
                    //初始化AlertView
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:[linkURL stringByReplacingOccurrencesOfString:@"tel:" withString:@""]
                                                                   delegate:self
                                                          cancelButtonTitle:ZCSTLocalString(@"取消")
                                                          otherButtonTitles:ZCSTLocalString(@"呼叫"),nil];
                    alert.tag=1;
                    [alert show];
                }else{
                    // 打电话
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callURL]];
                }
                
            }else if([linkURL hasPrefix:@"mailto:"] || zcLibValidateEmail(linkURL)){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkURL]];
            }else{
                if (![linkURL hasPrefix:@"https"] && ![linkURL hasPrefix:@"http"]) {
                    linkURL = [@"https://" stringByAppendingString:linkURL];
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


/**
 前往留言页面

 @param isExist 是否留言完毕直接退出
 */
-(void)goLeaveMessageVC:(ExitType) isExist  isShowToat:(BOOL) isShow  tipMsg:(NSString *)msg{
    
    
    if (self.chatDelegate && [_chatDelegate respondsToSelector:@selector(openLeaveMsgClick:)]) {
        [_chatDelegate openLeaveMsgClick:msg];
        return;
    }
    
    
    ZCUILeaveMessageController *leaveMessageVC = [[ZCUILeaveMessageController alloc]init];
    leaveMessageVC.exitType = isExist;
    leaveMessageVC.isShowToat = isShow;
    __weak ZCUIChatController * safeVC = self;
    leaveMessageVC.tipMsg = msg;
    [leaveMessageVC setCloseBlock:^{
        
        [safeVC goBackIsKeep];
    }];
    
    if (self.navigationController) {
        leaveMessageVC.isNavOpen = YES;
        [self.navigationController pushViewController:leaveMessageVC animated:YES];
    }else{
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:leaveMessageVC];
        
        [self  presentViewController:nav animated:YES completion:^{
            
        }];
   
    }

}


/**
 显示消息到TableView上
 */
-(void)scrollTableToBottom{
    
    [ZCLogUtils logHeader:LogHeader debug:@"滚动到底部"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat ch=_listTable.contentSize.height;
            CGFloat h=_listTable.bounds.size.height;
            
            CGRect tf         = _listTable.frame;
            CGFloat x = tf.size.height-_listTable.contentSize.height;
            
            CGFloat keyBoardHeight = viewHeigth - _zcKeyboardView.zc_bottomView.frame.origin.y-BottomHeight;
            if(x > 0){
                if(x<keyBoardHeight){
                    tf.origin.y = NavBarHeight - (keyBoardHeight - x);
                }
            }else{
                CGFloat barHight = 34;
                if (!ZC_iPhoneX) {
                    barHight = 0;
                }
                tf.origin.y   = NavBarHeight - keyBoardHeight  + barHight;
            }
            _listTable.frame  = tf;
            
            if(ch > h){
                [_listTable setContentOffset:CGPointMake(0, ch-h) animated:NO];
            }else{
                [_listTable setContentOffset:CGPointMake(0, 0) animated:NO];
            }
        });

    });
    
}


// 显示打电话
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==1){
        if(buttonIndex==1){
//            [alertView dismissWithClickedButtonIndex:1 animated:YES];
            // 打电话
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callURL]];
            
        }
    } else if(alertView.tag==3){
        if(buttonIndex==1){
            // 打开QQ
            [self openQQ:callURL];
            callURL=@"";
        }
    }
}

// 打开QQ，未使用
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
#pragma mark 聊天气泡代理方法结束



#pragma mark- section 跟随table滚动
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
    [[NSNotificationCenter defaultCenter] postNotificationName:UIMenuControllerDidHideMenuNotification object:nil];
    
}




#pragma mark 网络链接改变时会调用的方法
-(void)netWorkChanged:(NSNotification *)note
{
    BOOL isReachable = _netWorkTools.isReachable;
    if(!isReachable){
        self.newWorkStatusButton.hidden=NO;
        [_listTable setContentInset:UIEdgeInsetsMake(40, 0, 0, 0)];
        
        if([self getZCLibConfig]==nil){
            [[ZCUILoading shareZCUILoading] showAddToSuperView:self.view];
        }
        [self.view insertSubview:_newWorkStatusButton aboveSubview:_notifitionTopView];
    }else{
        self.newWorkStatusButton.hidden=YES;
        [_listTable setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        // 初始化数据
        if([self getZCLibConfig]==nil && [@"" isEqual:zcLibConvertToString([self getZCLibConfig].cid)] && !_isInitLoading){
            [self initConfigData:YES];
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


/**
 *  会话页面公用代理
 *
 *  @param action  消息触发条件
 */
-(void)addTipsListenerMessage:(int)action{
    
    [ZCLogUtils logHeader:LogHeader debug:@"========%d ========",action];
    
    if(action == ZCTipCellMessageUserTipWord || action == ZCTipCellMessageAdminTipWord){
        if ([self getZCLibConfig].isArtificial) {
            // 当前人工客服的昵称(在会话保持的模式下，返回再进入SDK ，昵称变成机器人昵称的问题)
            _receivedName = [ZCIMChat getZCIMChat].libConfig.senderName;
        }
        [self createMessageToArrayByAction:action type:0 name:_receivedName face:@"" tips:0 content:@""];
    }else{
        
        // 设置昵称
        [self setTitleName:_receivedName];
        
        // 转人工成功之后清理掉所有的留言入口
        if (_listArray.count>=1) {
            
            if (_listArray !=nil) {
                NSString *indexs = @"";
                for (int i = (int)_listArray.count-1; i>=0; i--) {
                    ZCLibMessage *model = _listArray[i];
                    
                    // 删除上一条留言信息
                    if ([model.sysTips hasPrefix:zcLibConvertToString([self getZCLibConfig].adminNonelineTitle)] && (action == ZCTipCellMessageUserNoAdmin)) {
                        indexs = [indexs stringByAppendingFormat:@",%d",i];
                    }else if([model.sysTips hasPrefix:ZCSTLocalString(@"您已完成评价")] && (action == ZCTipCellMessageEvaluationCompleted)){
                        // 删除上一次商品信息
                        indexs = [indexs stringByAppendingFormat:@",%d",i];
                    }else if ([model.sysTips hasPrefix:ZCSTLocalString(@"咨询后才能评价服务质量")] && (action == ZCTipCellMessageAfterConsultingEvaluation)){
                        indexs = [indexs stringByAppendingFormat:@",%d",i];
                    }else if ([model.sysTips hasPrefix:ZCSTLocalString(@"暂时无法转接人工客服")] && (action == ZCTipCellMessageIsBlock)){
                        indexs = [indexs stringByAppendingFormat:@",%d",i];
                    }else if ([model.richModel.msg isEqual:[self getZCLibConfig].robotHelloWord] && [self getZCLibConfig].type !=2){
                        [ZCStoreConfiguration setZCParamter:KEY_ZCISROBOTHELLO value:@"1"];
                    }else if ([model.sysTips hasPrefix:ZCSTLocalString(@"您好,本次会话已结束")] && (action == ZCTipCellMessageOverWord)){
                        indexs = [indexs stringByAppendingFormat:@",%d",i];
                    }
                }
                if(indexs.length>0){
                    indexs = [indexs substringFromIndex:1];
                    for (NSString *index in [indexs componentsSeparatedByString:@","]) {
                        [_listArray removeObjectAtIndex:[index intValue]];
                    }
                    [_listTable reloadData];
                }
            }
            
            
        }
        
        [self createMessageToArrayByAction:action type:2 name:_receivedName face:@"" tips:1 content:@""];
    }
}




#pragma mark 键盘事件 delegate

// 执行发送消息

/**
 执行发送消息

 @param text 消息体
 @param question 引导的问题ID
 @param type 消息体类型
 @param time 声音长度
 */
-(void) sendMessage:(NSString *)text questionId:(NSString*)question type:(ZCMessageType) type duration:(NSString *) time{
    // 发送空的录音样式
    DLog(@"发送的聊天信息=== text:%@, question:%@, type:%ld, time:%@",text,question,(long)type,time);
    if (type == ZCMessagetypeStartSound) {
        if(recordModel == nil){
            recordModel = [[self getZCAPIServer]  setLocalDataToArr:0 type:2 duration:@"0" style:0 send:NO name:[self getZCLibConfig].zcinitInfo.nickName content:@"" config:[self getZCLibConfig]];
            
            recordModel.progress     = 0;
            recordModel.sendStatus   = 0;
            recordModel.senderType   = 0;
            
            NSString *msg = @"";
            // 封装消息数据
            ZCLibRich *richModel=[ZCLibRich new];
            richModel.msg = msg;
            richModel.msgType = 2;
            richModel.duration = @"0";
            recordModel.richModel=richModel;
            [_listArray addObject:recordModel];
            // 回到主线程刷新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [_listTable reloadData];
                // 滑动到底部
                [self scrollTableToBottom];
            });
        }
        return;
    }

    if (type == ZCMessagetypeCancelSound) {
        if(recordModel!=nil){
            [_listArray removeObject:recordModel];
            recordModel = nil;
        }
        
        [_listTable reloadData];
        [self scrollTableToBottom];
        return;
    }
    
    if(type == ZCMessageTypeSound){
        if(recordModel!=nil){
            [_listArray removeObject:recordModel];
            recordModel = nil;
        }
    }
    
    
    
    // 发送完成再计数
    [[self getShareMS] cleanUserCount];
    
    
    /** 正在发送的消息对象，方便更新状态 */
    __block ZCLibMessage    *sendMessage;
    
    __weak ZCUIChatController *safeVC = self;

    [[self getZCAPIServer] sendMessage:text questionId:question msgType:type duration:time config:[self getZCLibConfig] robotFlag:[ZCLibClient getZCLibClient].libInitInfo.robotId start:^(ZCLibMessage *message) {
        DLog(@"-----%@",message)
//        message
        sendMessage  = message;
        sendMessage.sendStatus=1;
        
        [safeVC.listArray addObject:sendMessage];
        [safeVC.listTable reloadData];
        [safeVC scrollTableToBottom];
       
    } success:^(ZCLibMessage *message, ZCMessageSendCode sendCode) {
        DLog(@"-----%@",message)
        if([self getZCLibConfig].isArtificial){
            [ZCStoreConfiguration setZCParamter:KEY_ZCISSENDTOUSER value:@"1"];
            [ZCStoreConfiguration setZCParamter:KEY_ZCISSENDTOROBOT value:@"0"];
        }else{
            [ZCStoreConfiguration setZCParamter:KEY_ZCISSENDTOROBOT value:@"1"];
            [ZCStoreConfiguration setZCParamter:KEY_ZCISSENDTOUSER value:@"0"];
        }
        
        if(sendCode==ZC_SENDMessage_New){
            if(message.richModel
               && (message.richModel.answerType==3
                   ||message.richModel.answerType==4)
               && !safeVC.zckitInfo.isShowTansfer
               && ![ZCLibClient getZCLibClient].isShowTurnBtn){
                safeVC.unknownWordsCount ++;
                if([safeVC.zckitInfo.unWordsCount integerValue]==0) {
                    safeVC.zckitInfo.unWordsCount =@"1";
                }
                if (safeVC.unknownWordsCount >= [safeVC.zckitInfo.unWordsCount integerValue]) {
                    
                    // 仅机器人的模式不做处理
                    if ([safeVC getZCLibConfig].type != 1) {
                        // 设置键盘的样式 （机器人，转人工按钮显示）
                        //                        [safeVC.zcKeyboardView setRobotViewStatusType:ROBOTSTATUS];
                        [safeVC.zcKeyboardView setKeyBoardStatus:ROBOT_KEYBOARD_STATUS];
                        
                        // 保存在本次有效的会话中显示转人工按钮
                        [ZCLibClient getZCLibClient].isShowTurnBtn = YES;
                    }
                }
                
            }
            
            NSInteger index = [_listArray indexOfObject:sendMessage];
            [_listArray insertObject:message atIndex:index+1];
            [safeVC.listTable reloadData];
            [safeVC scrollTableToBottom];
        }else if(sendCode==ZC_SENDMessage_Success){
            sendMessage.sendStatus=0;
            sendMessage.richModel.msgtranslation = message.richModel.msgtranslation;
            [safeVC.listTable reloadData];
        }else {
            sendMessage.sendStatus=2;
            [safeVC.listTable reloadData];
            if(sendCode == ZC__SENDMessage_FAIL_STATUS){
                /**
                 *   给人工发消息没有成功，说明当前已经离线
                 *   1.回收键盘
                 *   2.添加结束语
                 *   3.添加新会话键盘样式
                 *   4.中断计时
                 *
                 **/
                [[self getShareMS] cleanUserCount];
                [[self getShareMS] cleanAdminCount];
                [_zcKeyboardView hideKeyboard];
                //                [_zcKeyboardView setRobotViewStatusType:AGAINACCESSASTATUS];
                [_zcKeyboardView setKeyBoardStatus:NEWSESSION_KEYBOARD_STATUS];
                [self addTipsListenerMessage:ZCTipCellMessageOverWord];
            }
        }
    } progress:^(ZCLibMessage *message) {
        if([self getZCLibConfig].isArtificial){
            [ZCStoreConfiguration setZCParamter:KEY_ZCISSENDTOUSER value:@"1"];
            [ZCStoreConfiguration setZCParamter:KEY_ZCISSENDTOROBOT value:@"0"];
        }else{
            [ZCStoreConfiguration setZCParamter:KEY_ZCISSENDTOROBOT value:@"1"];
            [ZCStoreConfiguration setZCParamter:KEY_ZCISSENDTOUSER value:@"0"];
        }
        
        [ZCLogUtils logText:@"上传进度：%f",message.progress];
        sendMessage.progress = message.progress;
        [safeVC.listTable reloadData];
    } fail:^(ZCLibMessage *message, ZCMessageSendCode errorCode) {
        if([self getZCLibConfig].isArtificial){
            [ZCStoreConfiguration setZCParamter:KEY_ZCISSENDTOUSER value:@"1"];
            [ZCStoreConfiguration setZCParamter:KEY_ZCISSENDTOROBOT value:@"0"];
        }else{
            [ZCStoreConfiguration setZCParamter:KEY_ZCISSENDTOROBOT value:@"1"];
            [ZCStoreConfiguration setZCParamter:KEY_ZCISSENDTOUSER value:@"0"];
        }
        
        sendMessage.sendStatus=2;
        [safeVC.listTable reloadData];
    }];
}

#pragma mark -- 键盘其他点击事件

//键盘其它点击事件
-(void) keyboardItemClick:(ZCKeyboardType ) type object:(id)obj{
    
    // 新会话
    if(type == ZCKeyboardOnClickReInit){
        // 新的会话要将上一次的数据清空全部初始化在重新拉取
        [_listArray removeAllObjects];
        [_listTable reloadData];
        // 重新赋值技能组ID和昵称（初始化传入字段）
        [ZCLibClient getZCLibClient].libInitInfo.skillSetId = zcLibConvertToString([[NSUserDefaults standardUserDefaults] valueForKey:@"UserDefaultGroupID"]);
        [ZCLibClient getZCLibClient].libInitInfo.skillSetName = zcLibConvertToString([[NSUserDefaults standardUserDefaults] valueForKey:@"UserDefaultGroupName"]);
        
        // 重新设置判定参数
        [ZCStoreConfiguration setZCParamter:KEY_ZCISSENDTOUSER value:@"0"];
        [ZCStoreConfiguration setZCParamter:KEY_ZCISSENDTOROBOT value:@"0"];
        [ZCStoreConfiguration setZCParamter:KEY_ZCISEVALUATIONSERVICE value:@"0"];
        [ZCStoreConfiguration setZCParamter:KEY_ZCISEVALUATIONROBOT value:@"0"];
        [ZCStoreConfiguration setZCParamter:KEY_ZCISROBOTHELLO value:@"0"];
        _isHadLoadHistory = NO;
        _isNoMore = NO;
        // 重新加载数据
        [self initConfigData:YES];
        [ZCLibClient getZCLibClient].isShowTurnBtn = NO;
        return;
    }
    
    // 和机器人会话提示留言
    if (type == ZCKeyboardOnClickAddLeavemeg) {
        // 设置昵称
        _receivedName = [self getZCLibConfig].robotName;
        
        // 暂无客服在线
        [self addTipsListenerMessage:ZCTipCellMessageUserNoAdmin];
        
        // 仅人工，客服不在线直接提示
        if ([self getZCLibConfig].type == 2){
            // 设置昵称
            _receivedName = ZCSTLocalString(@"暂无客服在线");
            [self setTitleName:_receivedName];
//            [_zcKeyboardView setRobotViewStatusType:ONLYUSERNOLINETOFIRST];
            [_zcKeyboardView setKeyBoardStatus:NEWSESSION_KEYBOARD_STATUS];
            return;
        }
        
        // 如果没有机器人欢迎语，添加机器人欢迎语
        if ([self getZCLibConfig].type !=2) {
            [self showRobotHello];
        }
        
        if ([self getZCLibConfig].type == 4 && ![self getZCLibConfig].isArtificial ) {
//            [_zcKeyboardView setRobotViewStatusType:ROBOTSTATUS];
            [_zcKeyboardView setKeyBoardStatus: ROBOT_KEYBOARD_STATUS];
        }
        
        // 设置昵称
        [self setTitleName:_receivedName];
        
        [[self getShareMS] cleanUserCount];
        [[self getShareMS] cleanAdminCount];
        return;
    }
    
    // 留言
    if(type ==  ZCKeyboardOnClickLeavePage){
        if ([obj integerValue] == 2 && [self getZCLibConfig].type == 2 && [self getZCLibConfig].msgFlag == 1) {
//            [_zcKeyboardView setRobotViewStatusType:ONLYUSERNOLINESTATUS];
            [_zcKeyboardView setKeyBoardStatus:NEWSESSION_KEYBOARD_STATUS];
            
            // 设置昵称
            _receivedName = ZCSTLocalString(@"暂无客服在线");
            
            [self setTitleName:_receivedName];
        }else{
            // 是否直接退出SDK
            NSInteger isExit = [obj integerValue];
            [self goLeaveMessageVC:isExit isShowToat:NO tipMsg:@""];
        }
        
    }
    
    // 关闭技能组（取消按钮）选项，如果是仅人工模式和人工优先 退出
    if(type == ZCKeyboardOnClickCloseSkillSet){
        if([self getZCLibConfig].type == 2 || [self getZCLibConfig].type == 4){
            [self  goBackIsKeep];
        }
    }
    
    // 转人工
    if(type==ZCKeyboardOnClickTurnUser){
        if(_isTurnLoading){
            return;
        }
        
        _isTurnLoading = YES;
        __weak ZCUIChatController *safeVC = self;
        NSString *groupId = zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.skillSetId);
        NSString *groupName = zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.skillSetName);
        
        NSString  *aid = [ZCLibClient getZCLibClient].libInitInfo.receptionistId ;
        
        // 如果指定客服，客服不在线是否还要继续往下转，tranFlag=0往下转，默认为0
        int  tranFlag = [ZCLibClient getZCLibClient].libInitInfo.tranReceptionistFlag;
        if (self.isDoConnectedUser) {
            aid = @"";
            tranFlag = 0;
            self.isDoConnectedUser = NO;
        }
        
        BOOL isWaiting = NO;
        if([ZCIMChat getZCIMChat].waitMessage!=nil &&  [[self getZCLibConfig].cid isEqual:[ZCIMChat getZCIMChat].waitMessage.cid]){
            isWaiting = YES;
        }
    
        
        _zcKeyboardView.isConnectioning = YES;
    
        [[safeVC getZCAPIServer] connectOnlineCustomer:groupId groupName:groupName config:[safeVC getZCLibConfig] Aid:aid TranFlag:tranFlag current:isWaiting start:^{
            safeVC.zcKeyboardView.zc_turnButton.enabled=NO;
        } result:^(NSDictionary *dict, ZCConnectUserStatusCode status) {
            
            
            _zcKeyboardView.isConnectioning = NO;
            safeVC.isTurnLoading = NO;
            safeVC.zcKeyboardView.zc_turnButton.enabled=YES;
            
            [safeVC.zcKeyboardView dismisSkillsetView];
            
            [[ZCUIToastTools shareToast] dismisProgress];
            
            safeVC.receivedName = [safeVC getZCLibConfig].robotName;
            
            
            [[self getShareMS] cleanUserCount];
            [[self getShareMS] cleanAdminCount];
            
            [ZCLogUtils logHeader:LogHeader debug:@"连接完成！状态：%zd %@",status,dict];
            [safeVC configConnectedResult:dict code:status];
            
            
        }];
       
    }else if (type == ZCKeyboardOnClickAddRobotHelloWolrd){
        // 添加机器人欢迎语
        [self showRobotHello];
        // 满意度评价
    }else if (type == ZCKeyboardOnClickSatisfaction){
        // 隐藏键盘
        [_zcKeyboardView hideKeyboard];
    
        BOOL isUser = NO;
        if ([[ZCStoreConfiguration getZCParamter:KEY_ZCISSENDTOUSER] intValue] == 1) {
            isUser = YES;
        }
        
        BOOL isRobot = NO;
        if ([[ZCStoreConfiguration getZCParamter:KEY_ZCISSENDTOROBOT] intValue] == 1) {
            isRobot = YES;
        }
        
        [ZCLogUtils logHeader:LogHeader debug:@"当前发送状态：%d,%d",isUser,isRobot];
      
        
        
         //1.只和机器人聊过天 评价机器人
         //2.只和人工聊过天 评价人工
         //3.机器人的评价和人工的评价做区分，互不相干。
        
        // 是否转接过人工  或者当前是否是人工 （人工的评价逻辑）
        if ([[ZCStoreConfiguration getZCParamter:KEY_ZCISOFFLINE] intValue] == 1 || [self getZCLibConfig].isArtificial) {
            
            
            // 拉黑不能评价客服添加提示语(只有在评价人工的情景下，并且被拉黑，评价机器人不触发此条件)
            if ([[self getZCLibConfig] isblack]||[[ZCStoreConfiguration getZCParamter:KEY_ZCISOFFLINEBEBLACK] intValue] == 1) {
                
                [self addTipsListenerMessage:ZCTipCellMessageTemporarilyUnableToEvaluate];
                return;
            }
            
            // 之前评价过人工，提示已评价过。
            if ([[ZCStoreConfiguration getZCParamter:KEY_ZCISEVALUATIONSERVICE] intValue] == 1) {
                [self addTipsListenerMessage:ZCTipCellMessageEvaluationCompleted];
                return;
            }
            
            if (isUser) {
                [self showCustomActionSheet:ServerSatisfcationNolType andDoBack:NO isInvitation:1 Rating:5 IsResolved:0];
            }else{
                [ZCStoreConfiguration setZCParamter:KEY_ZCISEVALUATIONSERVICE value:@"0"];
                [self addTipsListenerMessage:ZCTipCellMessageAfterConsultingEvaluation];
            }

        }else{
            // 之前评价过机器人，提示已评价。（机器人的评价逻辑）
            if ([[ZCStoreConfiguration getZCParamter:KEY_ZCISEVALUATIONROBOT] intValue] == 1) {
                [self addTipsListenerMessage:ZCTipCellMessageEvaluationCompleted];
                return;
            }
            
            if (isRobot) {
                [self showCustomActionSheet:RobotSatisfcationNolType andDoBack:NO isInvitation:1 Rating:5 IsResolved:0];
            }else{
                [ZCStoreConfiguration setZCParamter:KEY_ZCISEVALUATIONROBOT value:@"0"];
                [self addTipsListenerMessage:ZCTipCellMessageAfterConsultingEvaluation];
            }
        }
            
      
    }else if(type == ZCKeyboardOnClickDoWaiteWarning){
        // 已经在排队，再次点击转人工
        ZCLibMessage *message = [ZCIMChat getZCIMChat].waitMessage;
        if(message!=nil){
            message.isRead = NO;
            [self addReceivedNameMessageToList:message];
        }
    }else if(type == ZCKeyboardOnClickAddBlockTipCell){
        [self addTipsListenerMessage:ZCTipCellMessageIsBlock];
    }else if(type == ZCKeyboardOnClickQueryOrderForGoods){
        // 查询订单的点击事件
        [_zcKeyboardView hideKeyboard];
        KNBOrderViewController *orderVC = [[KNBOrderViewController alloc] init];
        orderVC.vcDelegate = self;
        [self presentViewController:orderVC animated:YES completion:nil];
    }
}

-(void)configConnectedResult:(NSDictionary *) dict code:(ZCConnectUserStatusCode) status{
    if([dict[@"data"][@"status"] intValue]==5){
        // 用户长时间没有说话，已经超时 （做机器人超时下线的操作显示新会话的键盘样式）
        return;
    }
    
    // status = 6 说明当前对接的客服转人工没有成功
    if ([dict[@"data"][@"status"] intValue] == 6) {
        self.isDoConnectedUser = YES;
        // 执行转人工的操作
        [_zcKeyboardView turnUserServer:YES];
        return;
    }
    //[dict[@"data"][@"status"] intValue] == 7   status == ZCConnectUserWaitingThreshold
    if (status == ZCConnectUserWaitingThreshold) {
        [ZCLibClient getZCLibClient].libInitInfo.skillSetId = @"";
        // 排队达到阀值
        // 1.留言开关是否开启
        // 2.各种接待模式
        // 3.键盘的切换
        // 4.添加提示语
        // 5.设置键盘样式
        
        if ([self getZCLibConfig].type ==2){
//            [_zcKeyboardView setRobotViewStatusType:ONLYUSERNOSATISFACTION];
            [_zcKeyboardView setKeyBoardStatus:NEWSESSION_KEYBOARD_STATUS];
            // 设置昵称
            self.receivedName =ZCSTLocalString(@"排队已满");
        }
        // 设置昵称
        [self setTitleName:_receivedName];
        
        // 添加提示语
        if ([self getZCLibConfig].msgFlag == 0) {
            //  跳转到留言不直接退出SDK
            [self goLeaveMessageVC:ISNOCOLSE isShowToat:YES tipMsg:zcLibConvertToString(dict[@"msg"])];
        }
        return;
    }
    
    // 排队
    if([self getZCLibConfig].isArtificial || status==ZCConnectUserOfWaiting){
        for(ZCLibMessage *item in self.listArray){
            if(item.tipStyle>0){
                item.sysTips=[item.sysTips stringByReplacingOccurrencesOfString:ZCSTLocalString(@"您可以留言") withString:@""];
            }
        }
        [_listTable reloadData];
    }
    
    // 转人工成功或者已经是人工状态
    if(status == ZCConnectUserBeBlock){// 说明当前用户是黑名单用户
         [self addTipsListenerMessage:ZCTipCellMessageIsBlock];
        
    }else if(status==ZCConnectUserSuccess || status == ZCConnectUserBeConnected){
        self.receivedName = zcLibConvertToString(dict[@"data"][@"aname"]);
        ZCLibConfig *libConfig = [self getZCLibConfig];
        libConfig.isArtificial = YES;
        libConfig.senderFace = zcLibConvertToString(dict[@"data"][@"aface"]);
        libConfig.senderName = self.receivedName;
        
        int messageType=ZCReceivedMessageNews;
        
        ZCLibMessage *message = [[self getZCAPIServer]  setLocalDataToArr:ZCTipCellMessageOnline type:messageType duration:@"" style:ZCReceivedMessageOnline send:NO name:_receivedName content:_receivedName config:libConfig];
        message.senderFace = zcLibConvertToString(dict[@"data"][@"aface"]);
        
        // 是否设置语音开关
//        [self.zcKeyboardView setUserViewStatus:[ZCUITools zcgetOpenRecord]];
        [self.zcKeyboardView setKeyBoardStatus:SERVERV_KEYBOARD_STATUS];
        
        // 添加上线消息
        [self addReceivedNameMessageToList:message];
        
        // 欢迎语客服
        message = [[self getZCAPIServer] setLocalDataToArr:ZCTipCellMessageAdminHelloWord type:0 duration:@"" style:0 send:NO name:self.receivedName content:nil config:libConfig];
        message.senderFace = zcLibConvertToString(dict[@"data"][@"aface"]);
        
        [self addReceivedNameMessageToList:message];
        // 连接失败
    }else if(status==ZCConnectUserOfWaiting){
        int messageType = ZCReceivedMessageWaiting;
        if ([self getZCLibConfig].type == 2) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self.zcKeyboardView setRobotViewStatusType:WAITSTATUS];
                [self.zcKeyboardView setKeyBoardStatus:WAITSTATUS];
            });
        }else{
            self.receivedName = zcLibConvertToString(dict[@"data"][@"aname"]);
//            [self.zcKeyboardView setRobotViewStatusType:ROBOTSTATUS];
            [self.zcKeyboardView setKeyBoardStatus:ROBOT_KEYBOARD_STATUS];
        }
        
        ZCLibMessage *message = [[self getZCAPIServer] setLocalDataToArr:ZCTipCellMessageWaiting type:ZCReceivedMessageWaiting duration:@"" style:messageType send:NO name:self.receivedName content:zcLibConvertToString(dict[@"data"][@"count"]) config:[self getZCLibConfig]];
        [self addReceivedNameMessageToList:message];
        [ZCIMChat getZCIMChat].waitMessage = message;
        
        // 如果没有机器人欢迎语，添加机器人欢迎语 (只在转人工不成功的情况下添加) 仅人工模式不添加
        if ([self getZCLibConfig].type != 2 ) {
            // 添加机器人欢迎语
            [self showRobotHello];
        }
        
        // 没有客服在线
    } else if(status==ZCConnectUserNoAdmin){
       
        if (self.listArray.count != 0) {
            int index = 0;
            for (int i = 0; i< self.listArray.count; i++) {
                ZCLibMessage *libmeg = self.listArray[i];
                if ([[self getZCLibConfig].robotHelloWord isEqual:libmeg.sysTips] || [[self getZCLibConfig].robotHelloWord isEqual:libmeg.richModel.msg]) {
                    index ++;
                }
            }
            if (index == 0) {
                // 如果没有机器人欢迎语，添加机器人欢迎语 (只在转人工不成功的情况下添加) 仅人工模式不添加
                if ([self getZCLibConfig].type != 2 ) {
                    // 添加机器人欢迎语
                    [self showRobotHello];
                }
            }
        }

        // 设置机器人的键盘样式
//        [self.zcKeyboardView setRobotViewStatusType:ROBOTSTATUS];
        [self.zcKeyboardView setKeyBoardStatus:ROBOT_KEYBOARD_STATUS];
        
#pragma mark -- 刷新的问题 太快键盘没有刷新状态
        // 添加暂无客服在线说辞
        [self addTipsListenerMessage:ZCTipCellMessageUserNoAdmin];
        
        // 针对仅人工模式 是否开启留言并没有接入成功 设置 未接入 键盘的区别
        if ([self getZCLibConfig].type ==2){
            if([self getZCLibConfig].msgFlag == 1){
                
//                [self.zcKeyboardView setRobotViewStatusType:ONLYUSERNOLINESTATUS];
                [self.zcKeyboardView setKeyBoardStatus:NEWSESSION_KEYBOARD_STATUS];
            }else if([self getZCLibConfig].msgFlag == 0){
//                [self.zcKeyboardView setRobotViewStatusType: ONLYUSERNOLINETOFIRST];
                [self.zcKeyboardView setKeyBoardStatus:NEWSESSION_KEYBOARD_STATUS];
            }
            // 设置昵称
            self.receivedName = ZCSTLocalString(@"暂无客服在线");
        }
    }else if(status == ZCConnectUserServerFailed){
        // status == -1 重连
        if ([self getZCLibConfig].type ==2){
            // 添加暂无客服在线说辞
            [self addTipsListenerMessage:ZCTipCellMessageUserNoAdmin];
            if([self getZCLibConfig].msgFlag == 1){
//                [self.zcKeyboardView setRobotViewStatusType:ONLYUSERNOLINESTATUS];
                [self.zcKeyboardView setKeyBoardStatus:NEWSESSION_KEYBOARD_STATUS];
            }else if([self getZCLibConfig].msgFlag == 0){
//                [self.zcKeyboardView setRobotViewStatusType: ONLYUSERNOLINETOFIRST];
                [self.zcKeyboardView setKeyBoardStatus:NEWSESSION_KEYBOARD_STATUS];
            }
            // 设置昵称
            self.receivedName = ZCSTLocalString(@"暂无客服在线");
        }
        
    }

    
    // 设置昵称
    [self setTitleName:_receivedName];
}


#pragma mark 评价代理
- (void)cellItemClick:(int)satifactionType IsResolved:(int)isResolved Rating:(int)rating{
    if (satifactionType == 1) {
        // 弹评价页面
        [self showCustomActionSheet:ServerSatisfcationNolType andDoBack:NO isInvitation:0 Rating:rating IsResolved:isResolved];
        
    }else{
        // 提交评价
        [self commitSatisfactionWithIsResolved:isResolved Rating:rating];
    }
}

// 提交评价
- (void)commitSatisfactionWithIsResolved:(int)isResolved Rating:(int)rating{
    if(isComment){
        return;
    }
    if (isResolved == 2) {
        // 没有选择 按已解决处理
        isResolved = 0;
    }
    //  此处要做是否评价过人工或者是机器人的区分
    if ([[ZCStoreConfiguration getZCParamter:KEY_ZCISOFFLINE] intValue] == 1 || [ZCIMChat getZCIMChat].libConfig.isArtificial) {
        // 评价过客服了，下次不能再评价人工了
        [ZCStoreConfiguration setZCParamter:KEY_ZCISEVALUATIONSERVICE value:@"1"];
    }else{
        // 评价过机器人了，下次不能再评价了
        [ZCStoreConfiguration setZCParamter:KEY_ZCISEVALUATIONROBOT value:@"1"];
    }
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    [dict setObject:@"" forKey:@"problem"];
    [dict setObject:[self getZCLibConfig].cid forKey:@"cid"];
    [dict setObject:[self getZCLibConfig].uid forKey:@"userId"];
    
    
    [dict setObject:@"1" forKey:@"type"];
    [dict setObject:[NSString stringWithFormat:@"%d",rating] forKey:@"source"];
    [dict setObject:@"" forKey:@"suggest"];
    [dict setObject:[NSString stringWithFormat:@"%d",isResolved] forKey:@"isresolve"];
    //    [dict setObject:[NSString stringWithFormat:@"%d",isresolve] forKey:@"isresolve"];
    // commentType  评价类型 主动评价 1 邀请评价0
    [dict setObject:@"0" forKey:@"commentType"];
    isComment = YES;
    [[[ZCUIConfigManager getInstance] getZCAPIServer] doComment:dict result:^(ZCNetWorkCode code, int status, NSString *msg) {
        isComment = NO;
    }];
    [self thankFeedBack:0 rating:rating IsResolve:1];
  
}


- (void)thankFeedBack:(int)type rating:(float)rating IsResolve:(int)isresolve{
    
    // 页面刷新过了 满意度cell赋值了
//    _isAddServerSatifaction = NO;
    
//    if (type == 0) {
        // 邀请评价结束后替换满意度cell
        ZCLibMessage *temModel=[[ZCLibMessage alloc] init];
        temModel.date         = zcLibDateTransformString(FormateTime, [NSDate date]);
        temModel.cid          = [self getZCLibConfig].cid;
        temModel.action       = 0;
        temModel.sender       = [self getZCLibConfig].uid;
        temModel.senderName   = _receivedName;
        temModel.senderFace   = @"";
        temModel.t=[NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]];
        temModel.ts           = zcLibDateTransformString(FormateTime, [NSDate date]);
        temModel.receiver     = [self getZCLibConfig].companyName;
        temModel.receiverName = [self getZCLibConfig].uid;
        temModel.offlineType  = @"1";
        temModel.receiverFace = @"";
        temModel.tipStyle = 209;
        temModel.ratingCount = rating;
        temModel.satisfactionCommtType =  isresolve;
        temModel.isQuestionFlag = [NSString stringWithFormat:@"%d",isresolve];
        [self addReceivedNameMessageToList:temModel];
//    }
    _isAddServerSatifaction = NO;
}


-(void)actionSheetClick:(int)isCommentTpye{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(self.navigationController){
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"感谢您的反馈^-^!") duration:1.0f view:self.view.window.rootViewController.view position:ZCToastPositionCenter];
        }else{
            
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"感谢您的反馈^-^!") duration:1.0f view:self.presentingViewController.view position:ZCToastPositionCenter];
        }

    });
    
    if(isCommentTpye == 1){
        [self thankFeedBack];
        [_listArray removeAllObjects];
        [_listTable reloadData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self goBackIsKeep];
        });
        
    }else if(isCommentTpye == 0){
//        [self.zcKeyboardView getKeyBoardViewStatus] == AGAINACCESSASTATUS
        if ([self.zcKeyboardView getKeyBoardViewStatus] == NEWSESSION_KEYBOARD_STATUS) {
            [_listArray removeAllObjects];
            [_listTable reloadData];
        }
        [self goBackIsKeep];
    }else{
//        NSLog(@"评价页面关闭了");
    }
    
}
// 感谢您的评价
-(void)thankFeedBack{
    
    [_zcKeyboardView hideKeyboard];
    
    
    if([ZCIMChat getZCIMChat].libConfig.isArtificial && self.zckitInfo.isCloseAfterEvaluation){
        // 调用离线接口
        [[self getZCAPIServer] logOut:[ZCIMChat getZCIMChat].libConfig];
        
        // 添加离线消息
        [self addTipsListenerMessage:ZCTipCellMessageOverWord];
    
        // 关闭通道
        [[ZCIMChat getZCIMChat] closeConnection];
        
        // 清理页面缓存
        [[ZCUIConfigManager getInstance] cleanObjectMenorery];
        
        // 清空标记加载历史记录会再次显示机器人欢迎语
        // 是否转接过人工
        [ZCStoreConfiguration setZCParamter:KEY_ZCISROBOTHELLO value:@"1"];
        [ZCStoreConfiguration setZCParamter:KEY_ZCISOFFLINE value:@"1"];
        
//        [_zcKeyboardView setRobotViewStatusType:AGAINACCESSASTATUS];
        [_zcKeyboardView setKeyBoardStatus:NEWSESSION_KEYBOARD_STATUS];
    }
}

// 评价页面是否消失的代理事件
- (void)dimissCustomActionSheetPage{
    _isDismissSheetPage = YES;
}


// 设置昵称
- (void)setTitleName:(NSString *)title{
    /**
     * 0.默认 1.企业昵称 2.自定义昵称
     *
     */
    if ([[ZCLibClient getZCLibClient].libInitInfo.titleType intValue] == 1) {
        // 取企业昵称
        [self.titleLabel setText:[self getZCLibConfig].companyName];
    }else if ([[ZCLibClient getZCLibClient].libInitInfo.titleType intValue] ==2) {
        if (![@"" isEqual:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.customTitle)]) {
              // 自定义的昵称
              [self.titleLabel setText:[ZCLibClient getZCLibClient].libInitInfo.customTitle];
          }else{
              // 取默认
              [self.titleLabel setText:title];
          }
        
    }else{
        // 取默认
        [self.titleLabel setText:title];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
//    NSLog(@"release BlockLeakViewController");
}

//-(BOOL)isGoodsMsg:(NSString *)message{
//    if (message && ![@"" isEqualToString:message] && (message.length >= 6)){
//        NSString *flagStr = [message substringToIndex:6];
//        if ([@"[消息类型]" isEqualToString:flagStr]) {
//            return YES;
//        }
//    }
//    return NO;
//}
#pragma mark- KNBOrderViewControllerDelegate 订单查询控制器代理
-(void)dismissViewController:(UIViewController *)controller andSendOrderMessage:(NSString *)msg{
    [self dismissViewControllerAnimated:YES completion:nil];
    if(![self getZCLibConfig].isArtificial){
        return;
    }
    [self sendMessage:msg questionId:@"" type:ZCMessageTypeText duration:@""];
}

-(KNBGoodsInfo *)isJSONtoModel:(NSString *)message{
    // 判断字符串是否以 特定字符开头
//    if (message && ![@"" isEqualToString:message] && (message.length >= 6)){
    if ([message hasPrefix:@"[消息类型]"]){
//        NSString *flagStr = [message substringToIndex:6];
//        if ([@"[消息类型]" isEqualToString:flagStr]) {

            message = [message stringByReplacingOccurrencesOfString:@"<br>" withString:@","];
            message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@","];
            message = [message stringByReplacingOccurrencesOfString:@"[" withString:@"\""];
            message = [message stringByReplacingOccurrencesOfString:@"]" withString:@"\""];

            NSString *msgJSON = [NSString stringWithFormat:@"{%@}",message];
            KNBGoodsInfo *goodsInfo = [KNBGoodsInfo yy_modelWithJSON:msgJSON];
            if (goodsInfo) {
                return goodsInfo;
            } else {
                return nil;
            }
//        }
    }
    return nil;
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
