//
//  ZCUIKeyboardDelegate.h
//  SobotKit
//
//  Created by zhangxy on 15/11/13.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCLibMessageConstants.h"
#import <UIKit/UIKit.h>
/**ZCKeyboardType键盘类型*/
typedef NS_ENUM(NSInteger,ZCKeyboardType) {
    /** 执行转接人工 */
    ZCKeyboardOnClickTurnUser            = 1,
    /** 执行转接人工 */
    ZCKeyboardOnClickReConnectedUser     = 2,
    /** 执行重新初始化 */
    ZCKeyboardOnClickReInit              = 3,
    /** 去留言 */
    ZCKeyboardOnClickLeavePage           = 4,
    /** 关闭技能组选择框 */
    ZCKeyboardOnClickCloseSkillSet       = 5,
    /** 满意度评价 */
    ZCKeyboardOnClickSatisfaction        = 6,
    /** 添加留言tipCell */
    ZCKeyboardOnClickAddLeavemeg         = 7,
    /** 排队中重复点击转人工操作 */
    ZCKeyboardOnClickDoWaiteWarning      = 8,
    /** 仅机器人模式添加机器人欢迎语 */
    ZCKeyboardOnClickAddRobotHelloWolrd  = 9,
    /** 添加拉黑tipCell */
    ZCKeyboardOnClickAddBlockTipCell     = 10,
    /** 用户离线不能发送消息，提醒本次会话已结束 */
    ZCKeyboardOnClickAddOverMsgTipCell   = 11,
    ZCKeyboardOnClickAddPhotoCamera      = 12,
    ZCKeyboardOnClickAddPhotoPicture     = 13,

    /** 查询用户订单*/
    ZCKeyboardOnClickQueryOrderForGoods = 14
};

/**
 *  ZCUIKeyboardDelegate
 */
@protocol ZCUIKeyboardDelegate <NSObject>


/**
 *  执行发送消息
 @param text 消息内容
 @param question 引导问题的问题编号
 @param type 消息类型
 @param time 语音消息的时间
 */
-(void) sendMessage:(NSString *)text questionId:(NSString*)question type:(ZCMessageType) type duration:(NSString *) time;


/**
 *  其它点击
 *  @param obj  object
 *  @param type 键盘事件类型
 */
-(void) keyboardItemClick:(ZCKeyboardType ) type object:(id)obj;

@end
