//
//  KNBOrderInfo.m
//  SobotKit
//
//  Created by suojl on 2017/11/3.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "KNBOrderInfo.h"


@implementation KNBOrderInfo


+(NSDictionary *)modelCustomPropertyMapper{
    return @{@"createData":@[@"createDate",@"add_time"],
             @"orderStatus":@[@"customStatus",@"order_status"],
             @"orderId":@[@"orderId",@"order_id"],
             @"orderNo":@[@"orderNo",@"order_id"],
             @"goodsList":@[@"goodsList",@"orderGoods"]
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"goodsList" : KNBGoodsInfo.class};
}
@end

@implementation KNBQueryBackInfo

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"data" : KNBOrderInfo.class};
}
@end

