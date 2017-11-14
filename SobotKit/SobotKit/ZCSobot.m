//
//  ZCSobot.m
//  SobotKit
//
//  Created by zhangxy on 15/11/12.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCSobot.h"

@implementation ZCSobot

+(void)startZCChatView:(ZCKitInfo *)info with:(UIViewController *)byController target:(id<ZCUIChatDelagete>)delegate pageBlock:(void (^)(ZCUIChatController *, ZCPageBlockType))pageClick messageLinkClick:(void (^)(NSString *))messagelinkBlock{
    if(byController==nil){
       
        return;
    }
    if(info == nil){
        return;
    }
    
    if([@"" isEqual:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.appKey)]){
        return;
    }
    
    ZCUIChatController *chat=[[ZCUIChatController alloc] initWithInitInfo:info];
    chat.hidesBottomBarWhenPushed=YES;
    chat.chatDelegate = delegate;
    [chat setPageBlock:pageClick messageLinkClick:messagelinkBlock];
    
    if(byController.navigationController==nil){
        chat.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;    // 设置动画效果
        [byController presentViewController:chat animated:YES completion:^{
            
        }];
    }else{
        [byController.navigationController pushViewController:chat animated:YES];
    }
}


+(NSString *)getVersion {
    return zcGetSDKVersion();
}


+(NSString *)getChannel{
    return zcGetAppChannel();
}


+(void)setShowDebug:(BOOL)isShowDebug{
     [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",isShowDebug] forKey:ZCKey_ISDEBUG];
}





@end
