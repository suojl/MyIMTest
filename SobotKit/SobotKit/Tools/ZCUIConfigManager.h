//
//  ZCUIConfigManager.h
//  SobotKit
//
//  Created by zhangxy on 15/11/13.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZCKitInfo.h"
#import "ZCLibConfig.h"
#import "ZCLibServer.h"
#import "ZCUIKeyboardDelegate.h"

#import "ZCLibMessageConstants.h"
#import "ZCLibClient.h"


#define VoiceLocalPath zcLibGetDocumentsFilePath(@"/sobot/")
/**
 *  NSTimerListenerType ENUM
 */
typedef NS_ENUM(NSInteger,NSTimerListenerType){
    /** 用户长时间不说话提醒 */
    NSTimerListenerTypeUserTimeOut  = 1,
    /** 客服长时间不说话提醒 */
    NSTimerListenerTypeAdminTimeOut = 2
};

/**
 *  ZCUIManagerDelegate
 */
@protocol ZCUIManagerDelegate <NSObject>

/**
 定时器按条件触发

 @param type 出发类型，用户超时，人工超时
 */
-(void)onTimerListener:(NSTimerListenerType) type;

@end



/**
 *  ZC UI布局管理类
 */
@interface ZCUIConfigManager : NSObject


/**
 获取UI管理对象

 @return 
 */
+(ZCUIConfigManager *) getInstance;

/** 保存历史记录的cid列表 */
@property(nonatomic, strong) NSMutableArray *cidsArray;

/** 初始化配置UI参数类 */
@property(nonatomic, strong) ZCKitInfo *kitInfo;


/**
 定时器：超时应答
 */
@property(nonatomic, assign) id<ZCUIManagerDelegate> delegate;


/**
 *  获取关键操作类
 *
 *  @return
 */
-(ZCLibServer *) getZCAPIServer;



/**
 销毁管理对象
 */
-(void)destoryConfigManager;

/**
 *  返回时清理临时缓存
 */
-(void)cleanObjectMenorery;


#pragma mark
-(void)startTipTimer;
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



/**
 获取表情包字典

 @return <#return value description#>
 */
-(NSDictionary *)allExpressionDict;

@end
