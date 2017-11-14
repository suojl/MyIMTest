//
//  ZCUIChatShare.h
//  SobotKit
//
//  Created by zhangxy on 15/11/13.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZCLibMessage.h"
#import "ZCUIChatDelegate.h"

/**
 *  聊天提醒类
 *  通过判断 客服是否超时 用户不说话 记时 添加提示信息
 */
@interface ZCUIChatShare : NSObject

@property(nonatomic,assign) BOOL isSendToUser;
@property(nonatomic,assign) BOOL isSendToSobot;
@property(nonatomic,assign) BOOL isCustomerLastSend;

/**
 *  单例
 *
 *  @return ZCUIChatShare创建的对象
 */
+(ZCUIChatShare *) getInstance;
-(void) cleanAllInstanceValue;
-(void) startInstanceValue;

/**
 *  设置代理
 *
 *  @param delegate  代理对象
 */
-(void)setShareDelegate:(id<ZCUIChatDelegate>) delegate;

/**
 *  用户不说话，人工发送消息以后，置为0，同时设置客户可以计数
 */
-(void)cleanUserCount;


/**
 *  管理员不说话，人工发送消息以后，置为0，同时设置人工可以计数
 */
-(void)cleanAdminCount;

/**
 *  录音是暂停双方计数
 */
-(void)pauseCount;
/**
 *  取消时，判断开始哪一个
 */
-(void)pauseToStartCount;


/**
 *  设置正在输入输入框，方便获取内容变更
 *
 *  @param textView 输入框
 */
-(void)setInputListener:(UITextView *)textView;

@end
