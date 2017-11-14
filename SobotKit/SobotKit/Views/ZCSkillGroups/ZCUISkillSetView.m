//
//  ZCUISkillSetView.m
//  MyTextViews
//
//  Created by zhangxy on 16/1/21.
//  Copyright © 2016年 zxy. All rights reserved.
//

#import "ZCUISkillSetView.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIChatKeyboard.h"
#import "ZCLibConfig.h"
#import "ZCUIConfigManager.h"

#import "ZCUIImageTools.h"

#import "ZCIMChat.h"

@interface ZCUISkillSetView()

@property(nonatomic,strong) UIView *backGroundView;
@property(nonatomic,strong) UIScrollView *scrollView;

@end

@implementation ZCUISkillSetView{
    void(^SkillSetClickBlock)(ZCLibSkillSet *itemModel);
    void(^CloseBlock)(void);
    void(^ToRobotBlock)(void);
    
    CGFloat viewWidth;
    CGFloat viewHeight;
    NSMutableArray *listArray;
    
    ZCUIChatKeyboard *_keyboardView;
}


- (ZCUISkillSetView *)initActionSheet:(NSMutableArray *)array withView:(UIView *)view{
    self=[super init];
    if(self){
        
        viewWidth = view.frame.size.width;
        viewHeight = view.frame.size.height;
        
        listArray = array;
        
        if(!listArray){
            listArray = [[NSMutableArray alloc] init];
        }
        
        //初始化背景视图，添加手势
        self.frame = CGRectMake(0, 0, viewWidth, viewHeight);
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        self.userInteractionEnabled = YES;
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareViewDismiss:)];
//        [self addGestureRecognizer:tapGesture];
        
        [self createSubviews];
    }
    return self;
}


- (void)createSubviews{
    CGFloat bw=270;
    CGFloat itemH = 72;
    CGFloat itemW = (bw-11)/2.0f;
    CGFloat sh = listArray.count/2 *itemH;
    if(sh > itemH * 3){
        sh = itemH * 3;
    }
    if (listArray.count == 3 || listArray.count == 4) {
        sh = itemH *2 + 3;
    }else if (listArray.count == 5 || listArray.count == 6){
        sh = itemH * 3 + 6;
    }
    
    self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake((viewWidth - bw) / 2.0, viewHeight, bw, 0)];
    self.backGroundView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    self.backGroundView.autoresizesSubviews = YES;
    self.backGroundView.backgroundColor = UIColorFromRGBAlpha(TextTopColor, 0.95);
    [self.backGroundView.layer setCornerRadius:5.0f];
    self.backGroundView.layer.masksToBounds = YES;
    [self addSubview:self.backGroundView];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bw, 58)];
    [titleLabel setText:ZCSTLocalString(@"选择咨询内容")];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setFont:TitleFont];
    [self.backGroundView addSubview:titleLabel];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 58, bw, sh)];
    self.scrollView.showsVerticalScrollIndicator=YES;
    self.scrollView.bounces = NO;
    [self.backGroundView addSubview:self.scrollView];
    
    CGFloat x=4;
    CGFloat y=0;
    int index = listArray.count%2==0?round(listArray.count/2):round(listArray.count/2)+1;
    
    for (int i=0; i<listArray.count; i++) {
        UIButton *itemView = [self addItemView:listArray[i] withX:x withY:y withW:itemW withH:itemH];
        
        [itemView setBackgroundColor:[UIColor whiteColor]];
        itemView.userInteractionEnabled = YES;
        itemView.tag = i;
        [itemView addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
        if(i%2==1){
            x = 4;
            y = y + itemH+3;
        }else if(i%2==0){
            x = itemW + 7;
        }
        [self.scrollView addSubview:itemView];
    }
    [self.scrollView setContentSize:CGSizeMake(bw, index*itemH + (index-1)*3)];
    
    
    UIButton *cannelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cannelButton setFrame:CGRectMake(0, sh+58+2, bw,44)];
    [cannelButton.titleLabel setFont:TitleFont];
    [cannelButton setTitle:ZCSTLocalString(@"取消") forState:UIControlStateNormal];
    [cannelButton addTarget:self action:@selector(tappedCancel) forControlEvents:UIControlEventTouchUpInside];
    [cannelButton setTitleColor:[ZCUITools zcgetCommentCommitButtonColor] forState:UIControlStateNormal];
    [self.backGroundView addSubview:cannelButton];
    [ZCUITools addTopBorderWithColor:UIColorFromRGBAlpha(LineTextMenuColor, 0.7) andWidth:.5f withView:cannelButton];
    
    [UIView animateWithDuration:0.25f animations:^{
        CGFloat bh=sh+58+2+44;
        [self.backGroundView setFrame:CGRectMake(self.backGroundView.frame.origin.x, (viewHeight-bh)/2,self.backGroundView.frame.size.width, bh)];
    } completion:^(BOOL finished) {
        
    }];
    
    // 注册通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gotoRobotChat:) name:@"closeSkillView" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gotoRobotChatAndLeavemeg:) name:@"gotoRobotChatAndLeavemeg" object:nil];
    
}
-(void)addBorderWithColor:(UIColor *)color isBottom:(BOOL) isBottom with:(UIView *) view{
    CGFloat borderWidth = 0.75f;
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    if(isBottom){
        border.frame = CGRectMake(0, view.frame.size.height - borderWidth, self.frame.size.width, borderWidth);
    }else{
        border.frame = CGRectMake(view.frame.size.width - borderWidth,0, borderWidth, self.frame.size.height);
    }
    border.name=@"border";
    [view.layer addSublayer:border];
}

-(void)addBorderWithColor:(UIColor *)color with:(UIView *) view{
    CGFloat borderWidth = 0.75f;
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    border.frame = CGRectMake(0, 0, self.frame.size.width, borderWidth);
    border.name=@"border";
    [view.layer addSublayer:border];
}


-(UIButton *)addItemView:(ZCLibSkillSet *) model withX:(CGFloat )x withY:(CGFloat) y withW:(CGFloat) w withH:(CGFloat) h{
    UIButton *itemView = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w,h)];
    [itemView setFrame:CGRectMake(x, y, w, h)];
    [itemView setBackgroundImage:[ZCUIImageTools zcimageWithColor:UIColorFromRGB(0xFFFFFF)] forState:UIControlStateHighlighted];
    [itemView setBackgroundImage:[ZCUIImageTools zcimageWithColor:UIColorFromRGB(0xf0f0f0)] forState:UIControlStateHighlighted];
    
    UILabel *_itemName = [[UILabel alloc] initWithFrame:CGRectZero];
    [_itemName setBackgroundColor:[UIColor clearColor]];
    [_itemName setTextAlignment:NSTextAlignmentCenter];
    [_itemName setTextColor:UIColorFromRGB(TextBlackColor)];
    [_itemName setText:model.groupName];
    [_itemName setFont:ListTitleFont];
    [itemView addSubview:_itemName];
    if(!model.isOnline){
        [_itemName setFrame:CGRectMake(0, (h-40)/2 , itemView.frame.size.width, 24)];
        
        UILabel *_itemStatus = [[UILabel alloc] initWithFrame:CGRectMake(0,(h-40)/2+24, itemView.frame.size.width, 16)];
        [_itemStatus setBackgroundColor:[UIColor clearColor]];
        [_itemStatus setTextAlignment:NSTextAlignmentCenter];
        [_itemStatus setFont:ListDetailFont];
        
        
        if ([ZCIMChat getZCIMChat].libConfig.msgFlag == 0) {
            [_itemStatus setText:ZCSTLocalString(@"留言")];
            [_itemStatus setTextColor:UIColorFromRGB(LineTextMenuColor)];
        }else{
            [_itemStatus setText:ZCSTLocalString(@"离线")];
            [_itemStatus setTextColor:UIColorFromRGB(UnOnlineTextColor)];
        }
        
        [itemView addSubview:_itemStatus];
    }else{
        [_itemName setFrame:CGRectMake(0, 0 , itemView.frame.size.width, h)];
    }
    
    return itemView;
}

- (void)itemClick:(UIButton *) view{
    ZCLibSkillSet *model =  listArray[view.tag];
    [ZCLogUtils logHeader:LogHeader info:@"%@",model.groupName];
    
    if(SkillSetClickBlock){
        SkillSetClickBlock(model);
    }
}

-(void)setItemClickBlock:(void (^)(ZCLibSkillSet *))block{
    SkillSetClickBlock = block;
}

-(void)setCloseBlock:(void (^)(void))closeBlock{
    CloseBlock = closeBlock;
}

- (void)closeSkillToRobotBlock:(void(^)(void)) toRobotBlock{
    ToRobotBlock = toRobotBlock;
}

- (void)gotoRobotChat:(NSNotification*)notification{

    [self tappedCancel];
}

- (void)setZCKeyboardView:(ZCUIChatKeyboard *)keyboardView{
    
}


/**
 *  显示弹出层
 *
 *  @param view
 */
- (void)showInView:(UIView *)view{
    [view addSubview:self];
}

// 隐藏弹出层
- (void)shareViewDismiss:(UITapGestureRecognizer *) gestap{
    CGPoint point = [gestap locationInView:self];
    CGRect f=self.backGroundView.frame;
    
    if(point.x<f.origin.x || point.x>(f.origin.x+f.size.width) ||
       point.y<f.origin.y || point.y>(f.origin.y+f.size.height)){
        [self tappedCancel:YES];
    }
}


- (void)tappedCancel{
    [self tappedCancel:YES];
}
/**
 *  关闭弹出层
 */
- (void)tappedCancel:(BOOL) isClose{
    // 移除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.backGroundView setFrame:CGRectMake(_backGroundView.frame.origin.x,viewHeight ,self.backGroundView.frame.size.width,self.backGroundView.frame.size.height)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            if(CloseBlock && isClose){
                CloseBlock();
            }
            [self removeFromSuperview];
        }
    }];
    // 点击取消的时候设置键盘样式 关闭加载动画
//    [_keyboardView setRobotViewStatusType:1];
    [_keyboardView setKeyBoardStatus:ROBOT_KEYBOARD_STATUS];
    [_keyboardView.zc_activityView stopAnimating];
}

- (void)gotoRobotChatAndLeavemeg:(NSNotification*)notifiation{
    [UIView animateWithDuration:0.25f animations:^{
        [self.backGroundView setFrame:CGRectMake(_backGroundView.frame.origin.x,viewHeight ,self.backGroundView.frame.size.width,self.backGroundView.frame.size.height)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (ToRobotBlock) {
            ToRobotBlock();
        }
            [self removeFromSuperview];
        
    }];
    // 点击取消的时候设置键盘样式 关闭加载动画
//    [_keyboardView setRobotViewStatusType:1];
    [_keyboardView setKeyBoardStatus:ROBOT_KEYBOARD_STATUS];
    [_keyboardView.zc_activityView stopAnimating];
}
@end
