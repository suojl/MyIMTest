//
//  ZCStoreConfiguration.m
//  SobotKit
//
//  Created by zhangxy on 2017/2/14.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "ZCStoreConfiguration.h"

NSString * const KEY_ZCCONFIGMESSAGE           = @"KEYP_ZCConfigMessage";

NSString * const KEY_ZCISROBOTHELLO            = @"KEYP_ZCisRobotHello";

NSString * const KEY_ZCISEVALUATIONSERVICE     = @"KEYP_ZCIsEvaluationService";

NSString * const KEY_ZCISEVALUATIONROBOT       = @"KEYP_ZCisEvaluationRobot";

NSString * const KEY_ZCISOFFLINE               = @"KEYP_ZCisOfflineByCloseAndOfflineByAdmin";

NSString * const KEY_ZCISOFFLINEBEBLACK        = @"KEYP_ZCisOfflineBeBlack";

// 新增数据
NSString * const KEY_ZCISSENDTOUSER            = @"KEY_PZCIsSendToUser";

NSString * const KEY_ZCISSENDTOROBOT           = @"KEY_PZCIsSendToRobot";



@implementation ZCStoreConfiguration

+(void)setZCParamter:(NSString *)key value:(id)value{
    [ZCLocalStore addObject:value forKey:key];
}


+(NSString *)getZCParamter:(NSString *) key{
    return zcLibConvertToString([ZCLocalStore getLocalParamter:key]);
}

+(int)getZCIntParamter:(NSString *) key{
    return [zcLibConvertToString([ZCLocalStore getLocalParamter:key]) intValue];
}


+(void)cleanLocalParamter{
    //清理个人信息缓存
    NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [userDefatluts dictionaryRepresentation];
    if(dictionary.allKeys.count>0){
        for(NSString* key in [dictionary allKeys]){
            if([key hasPrefix:@"KEYP_ZC"]){
                [userDefatluts removeObjectForKey:key];
            }
        }
        
        [userDefatluts removeObjectForKey:KEY_ZCISSENDTOUSER];
        [userDefatluts removeObjectForKey:KEY_ZCISSENDTOROBOT];
        
        [userDefatluts synchronize];
    }
}

@end
