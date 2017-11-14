//
//  KNBGoodsInfo.m
//  SobotKit
//
//  Created by suojl on 2017/10/26.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "KNBGoodsInfo.h"
#import "ZCUIConfigManager.h"

@implementation KNBGoodsInfo

/*
    [消息类型]:[123]
    [订单编号]:[18264532919127139187478]
    [订单状态]:[代收货]
    [商品首图]:[http://f12.baidu.com/it/u=3087422712,1174175413&fm=72]
    [商品价格]:[1232323]
    [下单时间]:[2017-10-23]
    [商品名称]:[]
 */
+(NSDictionary *)modelCustomPropertyMapper{
    return @{@"orderNumber":@"订单编号",
             @"goodsNo":@"商品编号",
             @"orderState":@"订单状态",
             @"orderDate":@"下单时间",
             @"cardType":@"消息类型",

             @"goodsImgUrl":@[@"firstImg",@"original_img",@"商品首图"],
             @"goodsTitle":@[@"goodsName",@"goods_name",@"商品名称"],
             @"goodsId":@[@"id",@"goods_id"],
             @"goodsPrice":@[@"price",@"goods_price",@"商品价格"]
             };
}

-(void)setOrderState:(NSString *)orderState{
    if (orderState && ![@"" isEqualToString:orderState]) {
        NSDictionary *stateDic = [ZCUIConfigManager getInstance].kitInfo.orderStateDictionary;
        if (stateDic && [stateDic objectForKey:orderState]) {
            _orderState = [stateDic objectForKey:orderState];
        }else{
            _orderState = orderState;
        }
    }else{
        _orderState = @"未查到";
    }
}

-(void)setOrderDate:(NSString *)orderDate{
    if (orderDate && ![@"" isEqualToString: orderDate]) {
        if (orderDate.length > 10) {
            _orderDate = [orderDate substringToIndex:10];
        }else{
            _orderDate = orderDate;
        }
    }else{
        _orderDate = orderDate;
    }
}
@end

