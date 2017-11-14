//
//  ZCStoreConfiguration.h
//  SobotKit
//
//  Created by zhangxy on 2017/2/14.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZCLocalStore.h"
#import "ZCKitInfo.h"
#import "ZCUIChatKeyboard.h"

/** 用户ID 用户的唯一标识 */
extern NSString * const KEY_ZCUSERID;

/** appkey app的标识 */
extern NSString * const KEY_ZCCONFIGMESSAGE;

/** 是否发送过机器人欢迎语 */
extern NSString * const KEY_ZCISROBOTHELLO;

/** 是否评价过人工客服 */
extern NSString * const KEY_ZCISEVALUATIONSERVICE;

/** 是否评价过机器人 */
extern NSString * const KEY_ZCISEVALUATIONROBOT;

/** 记录是否（客服离线、用户被拉黑、用户被下线、打开新窗口、长时间未说话）这几种情况  */
extern NSString * const KEY_ZCISOFFLINE;

/** 是否是拉黑下线 */
extern NSString * const KEY_ZCISOFFLINEBEBLACK;

/** 是否给人工发送过消息 */
extern NSString * const KEY_ZCISSENDTOUSER;

/** 是否给机器人发送过消息 */
extern NSString * const KEY_ZCISSENDTOROBOT;


@interface ZCStoreConfiguration : NSObject



+(NSString *)getZCParamter:(NSString *) key;

+(int)getZCIntParamter:(NSString *) key;

+(void)setZCParamter:(NSString *) key value:(id) value;

+(void) cleanLocalParamter;




@end
