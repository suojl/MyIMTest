//
//  KNBOrderInfo.h
//  SobotKit
//
//  Created by suojl on 2017/11/3.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KNBGoodsInfo.h"

@class KNBOrderInfo;
@interface KNBQueryBackInfo : NSObject

@property (nonatomic, assign) int code;
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, strong) NSArray *data;

@end

@interface KNBOrderInfo : NSObject

@property (nonatomic, strong) NSString *createData;
@property (nonatomic, assign) NSInteger orderStatus;
@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, strong) NSString *orderNo;
@property (nonatomic, strong) NSArray *goodsList;

@end

