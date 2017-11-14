//
//  ZCLibSatisfaction.h
//  SobotKit
//
//  Created by lizhihui on 2017/6/9.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZCLibSatisfaction : NSObject

/** 企业id */
@property (nonatomic,strong) NSString  * companyId;

/** 满意度配置id */
@property (nonatomic,strong) NSString  * configId;

/** 创建时间 */
@property (nonatomic,strong) NSString  * createTime;

/** 技能组id */
@property (nonatomic,strong) NSString  * groupId;

/** 技能组名称 */
@property (nonatomic,strong) NSString  * groupName;

/** 评价框引导语 */
@property (nonatomic,strong) NSString  * inputLanguage;

/** 评价框是否必填 1是 0否 */
@property (nonatomic,strong) NSString  * isInputMust;

/** 人工客服是否解决问题  1开启 0关闭 */
@property (nonatomic,strong) NSString  * isQuestionFlag;

/** '标签是否必填 1是 0否 */
@property (nonatomic,strong) NSString  * isTagMust;

/** 标签id，多个id之间逗号分隔 */
@property (nonatomic,strong) NSString  * labelId;

/** 标签名称，多个名称之间逗号分隔 */
@property (nonatomic,strong) NSString  * labelName;

/** 操作类型 0开关设置 1满意度策略 */
@property (nonatomic,strong) NSString  * operateType;

/** 星级 1,2,3,4,5星 */
@property (nonatomic,assign) int  score;

/** 星级说明 */
@property (nonatomic,strong) NSString  * scoreExplain;

/** 设置方式：1整体设置 2区分客服技能组设置 */
@property (nonatomic,strong) NSString  * settingMethod;

/** 更新时间 */
@property (nonatomic,strong) NSString  * updateTime;


-(id)initWithMyDict:(NSDictionary *)dict;

@end
