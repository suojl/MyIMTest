//
//  ZCUISkillSetView.h
//  MyTextViews
//
//  Created by zhangxy on 16/1/21.
//  Copyright © 2016年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCLibSkillSet.h"

@class ZCUIChatKeyboard;


/**
 *  ZCUISkillSetView
 **/
@interface ZCUISkillSetView : UIView


/**
 *  创建技能组页面
 *  @param  array  技能组数据
 *  @param  view   技能组页面添加到指定的view
 *  @return ZCUISkillSetView  技能组列表页面
 */
- (ZCUISkillSetView *)initActionSheet:(NSMutableArray *)array withView:(UIView *)view;


/**
 *  显示技能组页面 
 *  @param view 技能组页面添加到指定的view
 */
- (void)showInView:(UIView *)view;

/**
 *  关闭技能组页面
 *  @param  isClose 当前是否关闭
 */
- (void)tappedCancel:(BOOL) isClose;

/**
 * 点击选中的技能组回调事件
 * @param block 点击选中的技能组回调事件，当前的技能组对象ZCLibSkillSet
 */
- (void)setItemClickBlock:(void(^)(ZCLibSkillSet *itemModel)) block;

/**
 *  直接退出SDK 并关闭技能组弹框
 *  @param closeBlock 直接退出SDK 并关闭技能组弹框的回调事件
 */
- (void)setCloseBlock:(void(^)(void)) closeBlock;

/**
 *  关闭技能页面 和机器人会话
 *  @param toRobotBlock 关闭技能页面 和机器人会话的回调事件
 */
- (void)closeSkillToRobotBlock:(void(^)(void)) toRobotBlock;

/**
 *  @param keyboardView 获取当前键盘类
 */
- (void)setZCKeyboardView:(ZCUIChatKeyboard *) keyboardView;

@end
