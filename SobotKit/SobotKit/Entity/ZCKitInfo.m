//
//  ZCKitInitInfo.m
//  SobotKit
//
//  Created by zhangxy on 15/11/13.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCKitInfo.h"

@implementation ZCKitInfo

-(id)init{
    self=[super init];
    if(self){
        _isShowTansfer = YES;
        _isOpenRecord  = YES;
    }
    return self;
}


@end