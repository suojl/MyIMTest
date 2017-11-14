//
//  ZCLibSkillSet.h
//  SobotLib
//
//  Created by zhangxy on 16/1/21.
//  Copyright © 2016年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZCLibSkillSet : NSObject

@property (nonatomic,strong) NSString *groupId;
@property (nonatomic,strong) NSString *channelType;
@property (nonatomic,strong) NSString *groupName;
@property (nonatomic,strong) NSString *companyId;
@property (nonatomic,strong) NSString *recGroupName;
@property (nonatomic,assign) BOOL      isOnline;



-(id)initWithMyDict:(NSDictionary *)dict;

@end
