//
//  CustomActionSheet.m
//  SobotSDK
//
//  Created by 张新耀 on 15/8/5.
//  Copyright (c) 2015年 sobot. All rights reserved.
//

#import "ZCUICustomActionSheet.h"
#import "ZCUIRatingView.h"
#import "ZCUIPlaceHolderTextView.h"

#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIImageTools.h"
#import "ZCUIConfigManager.h"
#import "ZCIMChat.h"
#import "ZCStoreConfiguration.h"

#import "ZCLibSatisfaction.h"

#import "ZCSatisfactionButton.h"
#import "ZCItemView.h"

#define BorderWith     0.75f //(1.0 / [UIScreen mainScreen].scale) / 2

#define INPUT_MAXCOUNT 200

#define ZCkScreenWidth         [UIScreen mainScreen].bounds.size.width
#define ZCScreenScale          (ZCkScreenWidth / 375.0f)
#define ZCNumber(num)          (num*ZCScreenScale)

@interface ZCUICustomActionSheet()<RatingViewDelegate,UIGestureRecognizerDelegate,UITextViewDelegate>

//@property (nonatomic, weak) ZCUICustomActionSheet       *actionSheet;
@property (nonatomic, strong) UIView                  *sheetView;// 背景View(白色View)
@property(nonatomic,strong)ZCItemView *item;

@property(nonatomic,assign) CGFloat commitBtY ;
@property(nonatomic,weak)   UILabel *messageLabel;
@property(nonatomic,weak)   UILabel *quesLabel;
@property(nonatomic,assign)SatisfactionType type;
@property(nonatomic,assign)BOOL isChangePostion;// 是否去刷新星评
@property(nonatomic,weak) UIView * problemView;// 记录已解决 未解决 的坐标


@property(nonatomic,strong) UIScrollView *backGroundView;// 内容视图view（中间滑动部分）
@property(nonatomic,strong) UIView *itemView;// 标签view
@property(nonatomic,strong) ZCUIRatingView *ratingView;// 星评View
@property(nonatomic,strong) ZCUIPlaceHolderTextView *textView;
@property(nonatomic,strong) UIButton *commitBtn;
@property(nonatomic,strong) UIView * topView;// 顶部View
@property(nonatomic,strong) UILabel * stLable;//

@end




@implementation ZCUICustomActionSheet{
 
    BOOL isKeyBoardShow;
    BOOL touchRating;

    
    int currentServerType;
    
    ZCLibConfig *_config;
    BOOL isresolve;
    BOOL isDidClose;
    
    CGFloat viewWidth;
    CGFloat viewHeight;

    BOOL  _isBack;// 返回
    
    //1 主动评价 2 0邀请评价
    int _invitationType ;
    
    BOOL  _isBcakClose;// 评价完人工后结束会话
    
    NSString *_name ;  //客服或者机器人的昵称
    
    BOOL  isShowIsOrNoSolveProblemView;// 人工评价时，是否显示是否已解决页面
    
    NSMutableArray * _listArray;
    
    UILabel * _tiplab;// 星级评价标签
    
    BOOL  _isMustAdd; // 标签是否是必选
    
    BOOL  _isInputMust;// 评价框是否必填
    
    int  ratingCount; // 邀请评价记录几星
    int  isResolveCount;// 邀请评价记录 是否已解决
    
    BOOL _isAddServerSatifaction;// 满意度cell刷新
    
}

//  2.3.0 版本替换初始化方法
- (ZCUICustomActionSheet*)initActionSheet:(SatisfactionType)type Name:(NSString *)name Cofig:(ZCLibConfig *)config cView:(UIView *)view  IsBack:(BOOL)isBack isInvitation:(int) invitationType  WithUid:(NSString *)uid IsCloseAfterEvaluation:(BOOL) isCloseAfterEvaluation Rating:(int)rating IsResolved:(int)isResolve IsAddServerSatifaction:(BOOL) isAddServerSatifaction{
    
    self = [super init];
    if (self) {
        
        viewWidth = view.frame.size.width;
        viewHeight = view.frame.size.height;
        _config = config;
        // 初始化的背景视图，添加手势  添加高斯模糊
        self.frame = CGRectMake(0, 0, viewWidth, viewHeight);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(shareViewDismiss:)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        _name = name;
        _isBack = isBack;
        _invitationType = invitationType;
        currentServerType = type;
        _isBcakClose = isCloseAfterEvaluation;
        _isMustAdd = NO;
        _isInputMust = NO;
  
        ratingCount = rating;
        isResolveCount = isResolve;
        _isAddServerSatifaction = isAddServerSatifaction;
        
        if (currentServerType == 3 || currentServerType == 4) {
            // 加载人工客服的标签。根据接口的数据进行UI布局
             [self loadDataWithUid:uid];
        }else{
            // 机器人的模式为固定格式
            [self setupType:type];
        }
    }
    return self;
}


- (void)setDisplay{
    [self setupType:currentServerType];
}



- (void)loadDataWithUid:(NSString *)uid{
    
    [[ZCLibServer getLibServer] satisfactionMessage:uid start:^{
        
    } success:^(NSMutableArray *messageArr, ZCNetWorkCode code) {
        
        if (_listArray == nil) {
            _listArray = [NSMutableArray arrayWithCapacity:0];
        }else{
            [_listArray removeAllObjects];
        }
        _listArray = messageArr;
        
        ZCLibSatisfaction * model = _listArray[0];
        if ([model.isQuestionFlag  intValue] == 1) {
            isShowIsOrNoSolveProblemView = YES;
        }
        // 加载成功的布局
        [self setDisplay];
    } fail:^(NSString *msg, ZCNetWorkCode errorCode) {
        // 加载不成功的布局
        [self setDisplay];
    }];
    
}


-(void)setupType:(SatisfactionType)type{
    
    _sheetView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, 0)];
    [self addSubview:_sheetView];
    // topView
    _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, 49)];
    _topView.backgroundColor = UIColorFromRGB(TextTopColor);
    [self.sheetView addSubview:_topView];
    
    // 顶部标题栏部分  关闭按钮  标题  暂不评价 评价后结束会话
    // 左上角关闭按钮
    UIButton * closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(14, 15, 15, 15);
    [closeBtn setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_sf_close"] forState:UIControlStateNormal];
    [closeBtn setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_sf_close"] forState:UIControlStateSelected];
    [closeBtn setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_sf_close"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(dismissView:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:closeBtn];
    
    
    // 标题
    UILabel * titlelab = [[UILabel alloc]init];
    titlelab.textColor     = UIColorFromRGB(SatisfactionTextTitleColor);
    titlelab.textAlignment = NSTextAlignmentCenter;
    titlelab.numberOfLines = 0;
    titlelab.font          = [ZCUITools zcgetTitleFont];
    
    
    // 暂不评价按钮
    UIButton * noSatisfactionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [noSatisfactionBtn setTitle:ZCSTLocalString(@"暂不评价") forState:UIControlStateNormal];
    noSatisfactionBtn.frame = CGRectMake(viewWidth- 10 - 52 , 15, 52, 20);
    if (zcGetAppLanguages() == 1) {
       noSatisfactionBtn.frame = CGRectMake(viewWidth- 10 - 52-30 , 15, 52 + 30, 20);
    }
    [noSatisfactionBtn addTarget:self action:@selector(itemMenuClick:) forControlEvents:UIControlEventTouchUpInside];
    noSatisfactionBtn.tag  = RobotChangeTag3;
    [noSatisfactionBtn setTitleColor:[ZCUITools zcgetNoSatisfactionTextColor] forState:UIControlStateNormal];
    noSatisfactionBtn.titleLabel.font = [ZCUITools zcgetCustomListKitDetailFont];
    
    if (_isBack && (currentServerType == 1 || currentServerType == 3)) {
        [_topView addSubview:noSatisfactionBtn];
    }
    
    if (_isBcakClose && (currentServerType == 4 || currentServerType == 3)) {// 人工客服返回评价后结束会话
        titlelab.frame = CGRectMake(ScreenWidth/2 - (viewWidth-100)/2, 8, viewWidth -100, 18);
        titlelab.text = ZCSTLocalString(@"请您对本次服务进行评价");
        if (currentServerType == 1) {
            titlelab.text = ZCSTLocalString(@"机器人客服评价");
        }
        
        // 显示提交后会话将结束
        UILabel *tiplab = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth/2 - (viewWidth-100)/2, CGRectGetMaxY(titlelab.frame)+6, viewWidth -100, 12)];
        tiplab.font = [ZCUITools zcgetListKitDetailFont];
        tiplab.textAlignment = NSTextAlignmentCenter;
        tiplab.numberOfLines = 0;
        tiplab.textColor = [ZCUITools zcgetSatisfactionColor];
        tiplab.text = ZCSTLocalString(@"提交评价后会话将结束");
        [_topView addSubview:tiplab];
    }else{
        titlelab.frame = CGRectMake(ScreenWidth/2 - (viewWidth-100)/2, 14, viewWidth -100, 20);
        titlelab.font = [ZCUITools zcgetTitleFont];
        // 标题只有一行
        if (currentServerType == RobotSatisfcationBackType || currentServerType == ServerSatisfcationBackType) {
            titlelab.text = ZCSTLocalString(@"请您对本次服务进行评价");
            noSatisfactionBtn.hidden = NO;
        }else if(currentServerType == RobotSatisfcationNolType){
            titlelab.text = ZCSTLocalString(@"机器人客服评价");
        }else if(currentServerType == ServerSatisfcationNolType){
            titlelab.text = ZCSTLocalString(@"请您对本次服务进行评价");
        }
        
    }
    
    [_topView addSubview:titlelab];
    
    // 线条
    UIView *topline = [[UIView alloc]initWithFrame:CGRectMake(0, 48, viewWidth, 0.5)];
    topline.backgroundColor = [ZCUITools zcgetNoSatisfactionTextColor];
    [_topView addSubview:topline];
    
    
    if (type >2) {
        self.isOpenProblemSolving = isShowIsOrNoSolveProblemView;
    }else{
        self.isOpenProblemSolving = YES;
    }
    
    // 背景view UIScrollView  中间部分
    self.backGroundView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_topView.frame), viewWidth, 0)];
    self.backGroundView.autoresizesSubviews = YES;
    self.backGroundView.backgroundColor = UIColorFromRGB(TextTopColor);
    [self.sheetView addSubview:self.backGroundView];
    
    UIView *problemView ;// 记录位置
    if (self.isOpenProblemSolving) {
        // label
        UILabel * nicklab = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, viewWidth, 21)];
        nicklab.font = [ZCUITools zcgetVoiceButtonFont];
        nicklab.numberOfLines = 0;
        nicklab.textColor = UIColorFromRGB(SatisfactionTextTitleColor);
        nicklab.text = [NSString stringWithFormat:ZCSTLocalString(@"请问 [%@] 是否解决了您的问题？"),_name];
        nicklab.textAlignment = NSTextAlignmentCenter;
        [self.backGroundView addSubview:nicklab];
        
        self.type = type;
        
        // 已解决 未解决
        for (int i=0; i<2; i++) {
            ZCSatisfactionButton *btn=[ZCSatisfactionButton buttonWithType:UIButtonTypeCustom];
            if(i==0){
                
                [btn setFrame:CGRectMake(viewWidth/2 - 8 -120, CGRectGetMaxY(nicklab.frame)+15, 120, 36)];
                btn.tag=RobotChangeTag1;
                [btn setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_sf_zan_gray_nol"] forState:UIControlStateNormal];
                [btn setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_sf_zan_sel"] forState:UIControlStateSelected];
                [btn setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_sf_zan_sel"] forState:UIControlStateHighlighted];
                btn.selected=NO;
                [btn setTitle:ZCSTLocalString(@"已解决") forState:UIControlStateNormal];
            }else{
                [btn setFrame:CGRectMake(viewWidth/2 + 8, CGRectGetMaxY(nicklab.frame)+15,120, 36)];
                btn.tag=RobotChangeTag2;
                [btn setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_sf_no_gray_nol"] forState:UIControlStateNormal];
                [btn setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_sf_no_gray_sel"] forState:UIControlStateSelected];
                [btn setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_sf_no_gray_sel"] forState:UIControlStateHighlighted];
                [btn setTitle:ZCSTLocalString(@"未解决") forState:UIControlStateNormal];
                btn.selected=NO;
            }
            
            [btn.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
            [btn setTitleColor:[ZCUITools zcgetNoSatisfactionTextColor] forState:UIControlStateNormal];
            [btn setTitleColor:[ZCUITools zcgetSatisfactionTextSelectedColor] forState:UIControlStateHighlighted];
            [btn setTitleColor:[ZCUITools zcgetSatisfactionTextSelectedColor]  forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(robotServerButton:) forControlEvents:UIControlEventTouchUpInside];
            
            [btn setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:[ZCUITools zcgetSatisfactionBgSelectedColor] forState:UIControlStateSelected];
            [btn setBackgroundColor:[ZCUITools zcgetSatisfactionBgSelectedColor] forState:UIControlStateHighlighted];
            
//            if (_isBack && currentServerType == ServerSatisfcationBackType && btn.tag == RobotChangeTag1) {
//                [btn setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_sf_zan_blue_nol"] forState:UIControlStateNormal];
//                [btn setTitleColor:[ZCUITools zcgetDynamicColor] forState:UIControlStateNormal];
//            }else{
            
            btn.layer.borderWidth = BorderWith;
            btn.layer.borderColor = UIColorFromRGB(LineCommentLineColor).CGColor;
            btn.layer.cornerRadius = 7.5f;
            btn.layer.masksToBounds = YES;
            btn.titleLabel.font = [ZCUITools zcgetDetGoodsFont];
            
            if (currentServerType == 4 && _invitationType == 0 && isResolveCount == 1) {
                if (btn.tag ==  RobotChangeTag2) {
                    btn.selected = YES;
                    isresolve = YES;
                    btn.layer.borderColor = [UIColor clearColor].CGColor;
                }
            }else{
                if (btn.tag == RobotChangeTag1) {
                    btn.selected = YES;
                    isresolve=NO;
                    btn.layer.borderColor = [UIColor clearColor].CGColor;
                }
            }
            
            [self.backGroundView addSubview:btn];
            problemView = btn;
            self.problemView = problemView;
        }

    }
  
#pragma mark -- 星星
//    UILabel *message ; // 请您对【客服】进行评价
    if (type >2) {
        UILabel * nickLab = [[UILabel alloc]init];
        
        if ( !self.isOpenProblemSolving) {
            // 不显示已解决 未解决
            nickLab.frame = CGRectMake(0, 20, viewWidth, 21);
        }else if (self.isOpenProblemSolving){
            // 显示已解决 未解决
            nickLab.frame = CGRectMake(0, CGRectGetMaxY(self.problemView.frame) +20, viewWidth, 21);
        }
        
        nickLab.textAlignment = NSTextAlignmentCenter;
        nickLab.numberOfLines = 0;
        nickLab.text = [NSString stringWithFormat:ZCSTLocalString(@"请您对 [%@] 进行评价"),_name];
        nickLab.textColor = UIColorFromRGB(SatisfactionTextTitleColor);
        nickLab.font = [ZCUITools zcgetVoiceButtonFont];

        [self.backGroundView addSubview:nickLab];
        _ratingView=[[ZCUIRatingView alloc] initWithFrame:CGRectMake(viewWidth/2 - 250/2,  CGRectGetMaxY(nickLab.frame)+15, 250, 40 )];
        [_ratingView setImagesDeselected:@"ZCStar_unsatisfied" partlySelected:@"ZCStar_satisfied" fullSelected:@"ZCStar_satisfied" andDelegate:self];
        self.backGroundView.userInteractionEnabled = YES;
        self.sheetView.userInteractionEnabled = YES;
        self.userInteractionEnabled = YES;
        self.isChangePostion =NO;
        
        
        if (_invitationType == 0) {
            [_ratingView displayRating:(float)ratingCount];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
               [_ratingView displayRating:(float)ratingCount];
            });
        }else{
            [_ratingView displayRating:5.0f];
        }
        
        [self.backGroundView addSubview:_ratingView];
        
        // 满意度tipmsg
        _tiplab = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_ratingView.frame) +15, viewWidth, 20)];
        _tiplab.textAlignment = NSTextAlignmentCenter;
        _tiplab.textColor  =  [ZCUITools zcgetScoreExplainTextColor];

        
        if (_listArray.count && _listArray != nil) {
//            _tiplab.text = @"非常满意";
            ZCLibSatisfaction *item = _listArray[(int)_ratingView.rating -1];
            _tiplab.text = item.scoreExplain;
        }
        _tiplab.font = [ZCUITools zcgetDetGoodsFont];
        [self.backGroundView addSubview:_tiplab];
        self.messageLabel = _tiplab;
    }
    

#pragma mark -- 计算首次 显示的内容大小 计算提交按钮的位置
    
    CGFloat commitBtY = type>2 ? CGRectGetMaxY(self.messageLabel.frame)+20 : CGRectGetMaxY(self.problemView.frame)+20;
    //三目运算判断
    self.commitBtY = commitBtY;
    
    // 滑块的高度
    CGRect bggroundFrame = self.backGroundView.frame;
    bggroundFrame.size.height = commitBtY;
    self.backGroundView.frame = bggroundFrame;
    self.backGroundView.contentSize = CGSizeMake(viewWidth , commitBtY);
    
    // 提交评价
    _commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _commitBtn.frame = CGRectMake(0, CGRectGetMaxY(self.backGroundView.frame), viewWidth, 49);
    [_commitBtn setTitle:ZCSTLocalString(@"提交评价") forState:UIControlStateNormal];
    _commitBtn.titleLabel.font = [ZCUITools zcgetVoiceButtonFont];
    [_commitBtn setTitleColor:[ZCUITools zcgetSubmitEvaluationButtonColor] forState:UIControlStateNormal];
    [_commitBtn setBackgroundColor:[ZCUITools zcgetCommentCommitButtonColor]];
    [_commitBtn addTarget:self action:@selector(sendComment:) forControlEvents:UIControlEventTouchUpInside];
    [self.sheetView addSubview:_commitBtn];
    
    
    //获取高度
    CGRect sheetFrame = self.sheetView.frame;
    sheetFrame.size.height  = CGRectGetMaxY(self.backGroundView.frame) + _commitBtn.frame.size.height;
    sheetFrame.origin.y = viewHeight - sheetFrame.size.height;
    self.sheetView.frame = sheetFrame;
    
}

#pragma mark -- 点击 已解决 未解决 事件 
-(IBAction)robotServerButton:(UIButton *)sender{
    [sender setSelected:YES];
    sender.layer.borderColor = [UIColor clearColor].CGColor;
    if (sender.tag == RobotChangeTag1) {
        isresolve=NO;
        UIButton *btn=(UIButton *)[self.backGroundView viewWithTag:RobotChangeTag2];
        [btn setSelected:NO];
        btn.layer.borderColor = UIColorFromRGB(LineCommentLineColor).CGColor;
        if (currentServerType <3) {
            // 机器人模式触发
            [self showMenuItem:NO];// 收起
        }
        
        
    }else if(sender.tag == RobotChangeTag2){
        isresolve=YES;
        UIButton *btn=(UIButton *)[self.backGroundView viewWithTag:RobotChangeTag1];
        [btn setSelected:NO];
        btn.layer.borderColor = UIColorFromRGB(LineCommentLineColor).CGColor;
        if (currentServerType == RobotSatisfcationBackType || currentServerType == RobotSatisfcationNolType) {
            [self showMenuItem:YES];// 展开
        }
    }
    
//    if (sender.selected) {
//        sender.layer.backgroundColor = [UIColor clearColor].CGColor;
//    }else{
//        sender.layer.borderColor = UIColorFromRGB(LineCommentLineColor).CGColor;
//    }
    
}

#pragma 显示存在问题
-(void)showMenuItem:(BOOL) isShow{
    if (isShow) {
        // 显示标签
        [self.item removeFromSuperview];
        [self.textView removeFromSuperview];
        [self.stLable removeFromSuperview];
        
        CGFloat itemY = currentServerType >2 ? CGRectGetMaxY(self.messageLabel.frame)+20 : CGRectGetMaxY(self.problemView.frame)+20;
        
        // 是否有以下情况label 以及Btn
        UILabel *stLable=[[UILabel alloc] initWithFrame:CGRectMake(0, itemY -30, viewWidth, 0)];
        if (currentServerType == 1 || currentServerType == 2) {
            stLable.frame = CGRectMake(0, itemY , viewWidth, 30);
            
        }else{
            if (currentServerType >2 &&(_listArray.count > 0 && _listArray != nil) && (_ratingView.rating>0 && _ratingView.rating< 5) ) {
                
                ZCLibSatisfaction * model = _listArray[(int)_ratingView.rating -1];
                if (![@"" isEqual: zcLibConvertToString(model.labelName)]) {
                    stLable.frame = CGRectMake(0, itemY, viewWidth, 30);
                }
            }
        }

        
        [stLable setTextAlignment:NSTextAlignmentCenter];
        [stLable setText:ZCSTLocalString(@"存在哪些问题")];
        
        
        [stLable setFont:[ZCUITools zcgetVoiceButtonFont]];
        [stLable setTextColor:UIColorFromRGB(SatisfactionTextTitleColor)];
        [self.backGroundView addSubview:stLable];
        self.stLable = stLable;
        
        self.item = [[ZCItemView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(stLable.frame)+ 0, viewWidth, 0)];
        
        if (currentServerType == 1 || currentServerType == 2) {
            self.item.frame = CGRectMake(0, CGRectGetMaxY(stLable.frame)+ 15, viewWidth, 0);
            
        }else{
            if (currentServerType >2 &&(_listArray.count > 0 && _listArray != nil) && (_ratingView.rating>0 && _ratingView.rating< 5) ) {
                
                ZCLibSatisfaction * model = _listArray[(int)_ratingView.rating -1];
                if (![@"" isEqual: zcLibConvertToString(model.labelName)]) {
                    self.item.frame = CGRectMake(0, CGRectGetMaxY(stLable.frame)+ 15, viewWidth, 0);
                }
            }
        }
        
        // 数据源
        NSArray *items=[_config.robotCommentTitle componentsSeparatedByString:@","];
        if(currentServerType== 3 || currentServerType == 4){
            items = @[];// 调用接口不成功的时候用
            _isInputMust = NO;
            _isMustAdd = NO;
            [stLable setText:@""];
            if (_listArray.count >0 && _listArray !=nil) {
                // 接口返回的数据
                if (_ratingView.rating>0) {
                    ZCLibSatisfaction * model = _listArray[(int)_ratingView.rating -1];
                    if ([@"" isEqual: zcLibConvertToString(model.labelName)]) {
                        _isMustAdd = NO;
                    }else{
                        items = [model.labelName componentsSeparatedByString:@"," ];
                        if ([model.isTagMust intValue] == 1 ) {
                            _isMustAdd = YES;
                        }else{
                            _isMustAdd = NO;
                        }

                    }
                    if (_listArray.count >0) {
                        if ([model.isInputMust intValue] == 1) {
                            _isInputMust = YES;
                        }else{
                            _isInputMust = NO;
                        }

                    }
                    
                    if (_isMustAdd) {
                        [stLable setText:ZCSTLocalString(@"存在哪些问题（必选）")];
                    }else{
                        [stLable setText:ZCSTLocalString(@"存在哪些问题")];
                    }
                    
                }
            }
        }
        
        [self.item InitDataWithArray:items];
        CGRect itemF = self.item.frame ;
        itemF.size.height =[ZCItemView getHeightWithArray:items];
        self.item.frame = itemF;
        [self.backGroundView addSubview:self.item];
      
        // 评价输入框
        _textView=[[ZCUIPlaceHolderTextView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(self.item.frame) + 0, viewWidth - 60 , 60)];
        if (currentServerType == 1 || currentServerType == 2) {
            _textView.frame = CGRectMake(30, CGRectGetMaxY(self.item.frame) + 20, viewWidth - 60 , 60);
            
        }else{
            if (currentServerType >2 &&(_listArray.count > 0 && _listArray != nil) && (_ratingView.rating>0 && _ratingView.rating< 5) ) {
                
                ZCLibSatisfaction * model = _listArray[(int)_ratingView.rating -1];
                if (![@"" isEqual: zcLibConvertToString(model.labelName)]) {
                    _textView.frame = CGRectMake(30, CGRectGetMaxY(self.item.frame) + 20, viewWidth - 60 , 60);
                }
            }
        }

        
        _textView.layer.borderWidth   = BorderWith;
        _textView.layer.borderColor   = UIColorFromRGB(LineTextMenuColor).CGColor;
        _textView.layer.cornerRadius  = 3.0f;
        _textView.layer.masksToBounds = YES;
        _textView.backgroundColor     = [UIColor clearColor];
        _textView.placeholder         = ZCSTLocalString(@"欢迎给我们的服务提建议~");
        _textView.placeholderColor    = UIColorFromRGB(recordingBtnSelectedColor);
        _textView.placeholederFont    = [UIFont systemFontOfSize:14];
        _textView.font                = [UIFont systemFontOfSize:14];
        _textView.delegate            = self;
        
        if (_listArray != nil && _listArray.count >0) {
            if (_ratingView>0) {
                 ZCLibSatisfaction * model = _listArray[(int)_ratingView.rating -1];
                if (![@"" isEqual:zcLibConvertToString(model.inputLanguage)]) {
                    if (_isInputMust) {
                        _textView.placeholder = [NSString stringWithFormat:@"(必填)%@",model.inputLanguage];
                        if (zcGetAppLanguages() == 1) {
                          _textView.placeholder = [NSString stringWithFormat:@"(Required)%@",model.inputLanguage];
                        }
                        
                    }else{
                       _textView.placeholder = model.inputLanguage;
                    }
                    
                }
            }
        }
        
        [self.backGroundView addSubview:_textView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        CGRect bgF = self.backGroundView.frame;
        bgF.size.height = CGRectGetMaxY(_textView.frame) + 20;
        self.backGroundView.contentSize = CGSizeMake(viewWidth, bgF.size.height);
        if (bgF.size.height > ZCNumber(480-49*2)) {
            bgF.size.height = ZCNumber(480-49*2);
        }
        self.backGroundView.frame = bgF;
        
        // 由于是相对坐标 所以需要重新计算
        CGRect commitFrame = self.commitBtn.frame;
        commitFrame.origin.y = CGRectGetMaxY(self.backGroundView.frame);
        self.commitBtn.frame = commitFrame;
        
        CGRect sheetFrame = self.sheetView.frame;
        sheetFrame.size.height  = CGRectGetMaxY(self.backGroundView.frame) + _commitBtn.frame.size.height;
        self.sheetView.frame = sheetFrame;
        CGRect newSheetViewF   = self.sheetView.frame;
        newSheetViewF.origin.y = viewHeight - self.sheetView.frame.size.height;
        [UIView animateWithDuration:0.3 animations:^{
            self.sheetView.frame = newSheetViewF;
        }];

    }else{
        
        // 不显示  标签
        [self.item removeFromSuperview];
        [self.textView removeFromSuperview];
        [self.stLable removeFromSuperview];
        
        CGFloat itemY = currentServerType >2 ? CGRectGetMaxY(self.messageLabel.frame)+20 : CGRectGetMaxY(self.problemView.frame)+20;
        CGRect bgViewframe = self.backGroundView.frame;
        bgViewframe.size.height = itemY;
        self.backGroundView.frame = bgViewframe;
        self.backGroundView.contentSize = CGSizeMake(bgViewframe.size.width, bgViewframe.size.height);
        CGRect commitF = self.commitBtn.frame;
        commitF.origin.y = CGRectGetMaxY(self.backGroundView.frame);
        self.commitBtn.frame = commitF;
        
        CGRect sheetFrame = self.sheetView.frame;
        sheetFrame.size.height  = CGRectGetMaxY(self.backGroundView.frame) + _commitBtn.frame.size.height;
        self.sheetView.frame = sheetFrame;
        CGRect newSheetViewF   = self.sheetView.frame;
        newSheetViewF.origin.y = viewHeight - self.sheetView.frame.size.height;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.sheetView.frame = newSheetViewF;
            if(isKeyBoardShow){
               [_textView resignFirstResponder];
            }
        }];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    }
    
}




#pragma mark 打分改变代理
-(void)ratingChanged:(float)newRating{
    touchRating=YES;

    if (self.isChangePostion) {
        // 星评提示语
        if (_listArray != nil && _listArray.count > 0) {
            if (_ratingView.rating>0 && _ratingView.rating<=5) {
                // 小心数组越界了。。
                ZCLibSatisfaction *item = _listArray[(int)_ratingView.rating -1];
                _tiplab.text = item.scoreExplain;
            }
        }
        
        if (newRating >0 && newRating <5) {
            [self showMenuItem:YES];
        }else{
            [self showMenuItem:NO];
        }
    }

    self.isChangePostion = YES;
    
    if ((int)newRating == 5) {
        _isMustAdd = NO;
        _isInputMust = NO;
    }
}



#pragma mark --  关闭页面 不做评价  左上角关闭
- (void)dismissView:(UIButton*)sender{
    [self tappedCancel];
}


// 显示弹出层
- (void)showInView:(UIView *)view{
    [view addSubview:self];
}

// 隐藏弹出层
- (void)shareViewDismiss:(UITapGestureRecognizer *) gestap{
   
    // 触摸的评分
    if(touchRating){
        touchRating=NO;
        return;
    }
    
    if(isKeyBoardShow){
        isKeyBoardShow=NO;
        [_textView resignFirstResponder];
        return;
    }
    
    CGPoint point = [gestap locationInView:self];
    CGRect f=self.sheetView.frame;
    if(point.x<f.origin.x || point.x>(f.origin.x+f.size.width) ||
       point.y<f.origin.y || point.y>(f.origin.y+f.size.height)){
        [self tappedCancel];
    }
    
}

// 页面消失
- (void)tappedCancel{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.backGroundView setFrame:CGRectMake(_backGroundView.frame.origin.x,viewHeight ,self.backGroundView.frame.size.width,self.backGroundView.frame.size.height)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
    
    // 记录页面消失
    if (_delegate && [_delegate respondsToSelector:@selector(dimissCustomActionSheetPage)]) {
        [_delegate dimissCustomActionSheetPage];
    }
    
}

-(void)keyBoardWillShow:(NSNotification *) notification{
    isKeyBoardShow = YES;
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    {
        CGRect  sheetViewFrame = self.sheetView.frame;
        sheetViewFrame.origin.y = viewHeight - keyboardHeight - self.sheetView.frame.size.height;
        self.sheetView.frame = sheetViewFrame;
    }
    
    // commit animations
    [UIView commitAnimations];
}

//键盘隐藏
- (void)keyBoardWillHide:(NSNotification *)notification {
    if(_ratingView!=nil && _ratingView.rating>=5){
        return;
    }
    
    float animationDuration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView beginAnimations:@"bottomBarDown" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView commitAnimations];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect sheetFrame = self.sheetView.frame;
        sheetFrame.origin.y = viewHeight - self.sheetView.frame.size.height;
        self.sheetView.frame = sheetFrame;
    }];
}

#pragma mark 评价标签 点击事件
-(IBAction)itemButtonClick:(UIButton *)sender{
    sender.selected=!sender.selected;
    
    if(sender.selected){
        [sender.layer setBorderWidth:0];
    }else{
        [sender.layer setBorderWidth:BorderWith];
    }
}


#pragma mark 暂不评价 跳过、取消
-(IBAction)itemMenuClick:(UIButton *)sender{
    if(sender.tag == RobotChangeTag3){
        [self closePage];
    }
    [self tappedCancel];
}


#pragma mark -- 提交评价
-(void)sendComment:(UIButton *) btn{
    //  此处要做是否评价过人工或者是机器人的区分
    if ([[ZCStoreConfiguration getZCParamter:KEY_ZCISOFFLINE] intValue] == 1 || [ZCIMChat getZCIMChat].libConfig.isArtificial) {
        // 评价过客服了，下次不能再评价人工了
        [ZCStoreConfiguration setZCParamter:KEY_ZCISEVALUATIONSERVICE value:@"1"];
    }else{
        // 评价过机器人了，下次不能再评价了
        [ZCStoreConfiguration setZCParamter:KEY_ZCISEVALUATIONROBOT value:@"1"];
    }
        
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
  
    NSString *comment=@"";
    if (_ratingView.rating != 5) {
        for(UIView *objV in _item.subviews){
            int tag=(int)objV.tag;
            if(tag>100 && tag<=107 && [objV isKindOfClass:[UIButton class]]){
                UIButton *btn=(UIButton *)objV;
                if(btn.selected){
                    comment=[NSString stringWithFormat:@"%@%@,",comment,btn.titleLabel.text];
                }
            }
        }
    }
    
    if (currentServerType == 3 || currentServerType == 4) {
        // 只在人工是做评定
        if ([@"" isEqualToString:comment] && _isMustAdd) {
            // 提示
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"标签必选  ") duration:1.0f view:self position:ZCToastPositionCenter];
            
            return;
        }
        if ([@"" isEqualToString:_textView.text] && _isInputMust ) {
            
            // 提示
            [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"请输入您的意见  ") duration:1.0f view:self position:ZCToastPositionCenter];
            return;
        }
    }
    
    
    [dict setObject:comment forKey:@"problem"];
    
    
    if(_config){
        [dict setObject:_config.cid forKey:@"cid"];
        [dict setObject:_config.uid forKey:@"userId"];
    }
    if (currentServerType >2) {
       [dict setObject:[NSString stringWithFormat:@"%d",1] forKey:@"type"];
    }else{
       [dict setObject:[NSString stringWithFormat:@"%d",0] forKey:@"type"];
    }
    [dict setObject:[NSString stringWithFormat:@"%.0f",_ratingView.rating] forKey:@"source"];
    
    
    if (_ratingView.rating == 5) {
        _textView.text = @"";// 5星 置空之前的建议
    }
    NSString * textStr = @"";
    if (_textView.text!=nil ) {
        textStr = _textView.text;
    }
    [dict setObject:textStr forKey:@"suggest"];
    
    NSString * solved = @"-1";   // -1 未开启 0 已解决 1未解决
    if (_isOpenProblemSolving && currentServerType>2) {// 开启已解决 未解决  人工
        if (!isresolve) {
            solved = @"0";
        }else{
            solved = @"1";
        }
    }else if(currentServerType <3){
        if (!isresolve) {
            solved = @"0";
        }else{
            solved = @"1";
        }
    }
    [dict setObject:solved forKey:@"isresolve"];
//    [dict setObject:[NSString stringWithFormat:@"%d",isresolve] forKey:@"isresolve"];
    // commentType  评价类型 主动评价 1 邀请评价0
    [dict setObject:[NSString stringWithFormat:@"%d",_invitationType] forKey:@"commentType"];
    
    btn.enabled = false;
    [[[ZCUIConfigManager getInstance] getZCAPIServer] doComment:dict result:^(ZCNetWorkCode code, int status, NSString *msg) {
        
    }];
    
    if(isKeyBoardShow){
        isKeyBoardShow=NO;
        [_textView resignFirstResponder];
    }
    
    
    btn.enabled = true;
    // 隐藏弹出层
    [self tappedCancel];
    
    if (_invitationType == 0 || (_isAddServerSatifaction && !_isBcakClose  && currentServerType>2 )) {
        if (_delegate && [_delegate respondsToSelector:@selector(thankFeedBack:rating:IsResolve:)]) {
            int resolve = 0;
            if (isresolve) {
                resolve = 2;
            }else{
                resolve = 1;
            }
            [self.delegate thankFeedBack:_invitationType rating:_ratingView.rating IsResolve:resolve];
        }

    }
    
    
    // 关闭页面   提交评价后结束会话
    if (_isBcakClose && _isBack) {
        [self closePage:1];
    }else if(_isBack){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self closePage];
        });
    }else{
        [self closePage:2];
    }
   
}


-(void)closePage{
    // 跳过，直接退出
    [self closePage:0];
}

/**
 *  反馈成功，做页面提醒
 *
 *  @param isComment YES反馈成功，NO，没有执行反馈，直接关闭页面
 */
-(void)closePage:(int) isComment{
    // 跳过，直接退出
    if(self.delegate && [self.delegate respondsToSelector:@selector(actionSheetClick:)]){
        [self.delegate actionSheetClick:isComment];
    }
    self.delegate = nil;
}

#pragma mark -- 代理事件限制200个字符的长度
- (void)textViewDidChange:(UITextView *)textView{
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    
    if (textView.text.length>INPUT_MAXCOUNT) {
        textView.text = [textView.text substringToIndex:INPUT_MAXCOUNT];
    }

}



#pragma mark -- 获取当前的语言
-(int)zcGetAppLanguages{
    //    NSLog(@"当前的语言为%@",[[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0]);
    NSString * lanStr  = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] objectAtIndex:0];
    if ([lanStr hasPrefix:@"en"]) {
        return 1;
    }else if ([lanStr hasPrefix:@"zh-Hans"]){
        return 0;
    }
    return 0;
    
}

#pragma mark -- 手势冲突的代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([touch.view isKindOfClass:[UIButton class]]  || [touch.view isKindOfClass:[ZCUIRatingView class]]  || [touch.view isMemberOfClass:[UIImageView class]]){
        return NO;
    }
    return YES;
}


@end
