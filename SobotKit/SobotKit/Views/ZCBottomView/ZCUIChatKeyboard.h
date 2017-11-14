//
//  ZCUIChatKeyboard.h
//  SobotKit
//
//  Created by zhangxy on 15/11/13.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZCUIKeyboardDelegate.h"
#import "ZCLibConfig.h"
#import "ZCUISkillSetView.h"
#import "ZCButton.h"
#import "EmojiBoardView.h"
#import "ZCUIRecordView.h"

#define BottomHeight 49

/**
 *   ZCKeyboardStatus   ENUM
 */
typedef NS_ENUM(NSUInteger,ZCKeyboardStatus){

    WAITSTATUS             = 3,             // 转人工、+ 、输入框、排队中...
    SERVERV_KEYBOARD_STATUS        = 10,          // 人工键盘样式
    ROBOT_KEYBOARD_STATUS          = 11,          // 机器人键盘样式
    NEWSESSION_KEYBOARD_STATUS     = 12,          // 新会话键盘样式

    
    
    
};


/**
 *  智齿 底部bottomView
 *  输入框 转人工按钮 语音按钮 相机相册按钮
 */
@interface ZCUIChatKeyboard : NSObject

/** 初始化时 能否点击转人工按钮 */
@property (nonatomic,assign) BOOL   isConnectioning;

/** 智齿keyboard代理 */
@property(nonatomic) id<ZCUIKeyboardDelegate> delegate;

/** 聊天页底部View（输入框，按钮的父类） */
@property (nonatomic,strong) UIView     *zc_bottomView;

/** 输入框 */
@property (nonatomic,strong) UITextView *zc_chatTextView;

/** 转人工按钮 */
@property (nonatomic,strong) UIButton   *zc_turnButton;

/** 语音事件 */
@property (nonatomic,strong) UIButton   *zc_voiceButton;

/** 留言按钮 */
@property (nonatomic,strong) UIButton   *zc_leaveMsgButton;

/** 图片按钮 */
@property (nonatomic,strong) UIButton   *zc_addMoreButton;

/** 录音按钮 */
@property (nonatomic,strong) UIButton   *zc_pressedButton;

/** 表情按钮 */
@property (nonatomic,strong) UIButton   *zc_faceButton;

/** 新会话按钮 */
@property (nonatomic,strong) UIButton   *zc_againAccessBtn;

/** 加载动画 */
@property (nonatomic,strong) UIActivityIndicatorView *zc_activityView;

/** 系统相册相机图片 */
@property (nonatomic,strong) UIImagePickerController *zc_imagepicker;

/** 聊天页中UITableView 用于界面键盘高度处理 */
@property (nonatomic,strong) UITableView *zc_listTable;

/** 键盘高度 */
@property (nonatomic,assign) CGFloat zc_keyBoardHeight;

/** 语音动画页面 */
@property (nonatomic,strong) ZCUIRecordView *zc_recordView;

/** emjoy布局view */
@property (nonatomic,strong) EmojiBoardView *zc_emojiView;

/** 添加留言背景View */
@property (nonatomic,strong) UIView   *zc_sessionBgView;

/** 满意度按钮 */
//@property (nonatomic,strong) ZCButton *zc_satisfactionBtn;

/** 新会话按钮 */
//@property (nonatomic,strong) ZCButton *zc_againBtn;

/** 留言按钮 */
//@property (nonatomic,strong) ZCButton *zc_leaveMsgBtn;

/** 添加相机的View */
@property (nonatomic,strong) UIView *zc_moreView;

/** (排队中...)Label */
@property (nonatomic,strong) UILabel *zc_waitLabel;

/** 获取用户传入的VC页面 */
@property (nonatomic,strong) UIView *zc_sourceView;

/** 技能组展示页面 */
@property (nonatomic,strong) ZCUISkillSetView *skillSetView;

/** 机器人语音按钮*/
@property (nonatomic,strong) UIButton * zc_robotVoiceBtn;

/** 机器人录音功能提示语*/
@property (nonatomic,strong) UILabel * vioceTipLabel;


/**
 *  初始化聊天页面中的底部输入框区域UI
 *
 *  @param unitView  聊天VC的View
 *  @param listTable 聊天的tableview
 *  @param delegate  代理
 *
 */
+ (id)initWihtConfigView:(UIView *)unitView table:(UITableView *)listTable delegate:(id<ZCUIKeyboardDelegate>)delegate;


/**
 *  添加键盘监听
 */
- (void)handleKeyboard;

/**
 *  隐藏键盘
 */
-(void)hideKeyboard;

/**
 *  移除键盘监听
 */
-(void)removeKeyboardObserver;


/**
 转人工，执行转人工后，如果当前技能组没有人工在线，可以转到其他技能组的客服

 @param isAgin YES第二次转接，默认转接是NO
 */
-(void)turnUserServer:(BOOL)isAgin;

/**
 *  隐藏技能组
 */
-(void) dismisSkillsetView;



-(void)setKeyBoardStatus:(ZCKeyboardStatus)status;

/**
 *  获取当前键盘的样式
 */
-(ZCKeyboardStatus) getKeyBoardViewStatus;

/**
 *  通过初始化信息设置键盘以及相应的操作
 *
 *  @param config 配置信息model
 */
-(void)setInitConfig:(ZCLibConfig *)config;


@end
