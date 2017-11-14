//
//  ZCChatCellDelegate.h
//  SobotApp
//
//  Created by 张新耀 on 15/9/17.
//  Copyright (c) 2015年 com.sobot.chat. All rights reserved.
//

#import "ZCLibMessage.h"
/**聊天消息cell的点击类型*/
typedef NS_ENUM(NSInteger,ZCChatCellClickType) {
    /** 点击图片 */
    ZCChatCellClickTypeTouchImageNO      = 1,
    /** 点击头像 （未使用）*/
    ZCChatCellClickTypeHeader            = 2,
    /** 重新发送 */
    ZCChatCellClickTypeReSend            = 3,
    /** 播放声音 */
    ZCChatCellClickTypePlayVoice         = 4,
    /** 听筒播放 （未使用）*/
    ZCChatCellClickTypeReceiverPlayVoice = 5,
    /** 打开Web */
    ZCChatCellClickTypeOpenURL           = 6,
    /** 引导答案 */
    ZCChatCellClickTypeItemChecked       = 7,
    /** 点击图片 */
    ZCChatCellClickTypeTouchImageYES     = 8,
    /** 转人工 */
    ZCChatCellClickTypeConnectUser       = 9,
    /** 满意度评价 */
    ZCChatCellClickTypeSatisfaction      = 10,
    /** 留言 */
    ZCChatCellClickTypeLeaveMessage      = 11,
    /** 发送商品信息 */
    ZCChatCellClickTypeSendGoosText      = 12,
    /** 展示复制成功 */
    ZCChatCellClickTypeShowToast         = 13,
    /** 踩 */
    ZCChatCellClickTypeStepOn            = 14,
    /** 顶 */
    ZCChatCellClickTypeTheTop            = 15,
};

/**
 *  ZCChatCellDelegate
 */
@protocol ZCChatCellDelegate <NSObject>

/**
 *  聊天消息cell点击的代理方法
 *
 *  @param model  消息体
 *  @param type   聊天消息cell的点击类型
 *  @param object 代理
 */
-(void)cellItemClick:(ZCLibMessage *)model type:(ZCChatCellClickType) type obj:(id)object;


/**
 *  文本链接点击
 *
 *  @param text    点击文本
 *  @param type    类型
 *  @param linkURL 链接
 */
-(void)cellItemLinkClick:(NSString *)text type:(ZCChatCellClickType) type obj:(NSString *)linkURL;

@optional
// 评价cell使用
- (void)cellItemClick:(int)satifactionType IsResolved:(int)isResolved Rating:(int)rating;

@end
