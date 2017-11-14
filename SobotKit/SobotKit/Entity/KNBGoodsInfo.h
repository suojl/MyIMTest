//
//  KNBGoodsInfo.h
//  SobotKit
//
//  Created by suojl on 2017/10/26.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KNBGoodsInfo : NSObject


/**
 订单的ID
 */
@property (nonatomic,strong) NSString *orderId;

/**
 商品的ID
 */
@property (nonatomic,assign) int goodsId;
/**
 商品的编号
 */
@property (nonatomic,assign) int goodsNo;


// 消息类型
@property (nonatomic,strong) NSString *messageType;
// 订单号
@property (nonatomic,strong) NSString *orderNumber;

// 商品首图
@property (nonatomic,strong) NSString *goodsImgUrl;

// 商品金额
@property (nonatomic,strong) NSString *goodsPrice;

// 订单状态
@property (nonatomic,strong) NSString *orderState;

// 订单日期
@property (nonatomic,strong) NSString *orderDate;
// 商品描述
@property (nonatomic,strong) NSString *goodsTitle;
// 卡片类型 1. goods:商品  2. order:订单
@property (nonatomic,strong) NSString *cardType;

//
@property (nonatomic,assign) BOOL isAddToCar;

@end

