//
//  KNBGoodsCell.h
//  SobotKit
//
//  Created by suojl on 2017/10/26.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KNBGoodsInfo.h"
#import "ZCUIImageView.h"
#import "ZCChatBaseCell.h"

@interface KNBGoodsCell : ZCChatBaseCell

@property(nonatomic,strong) KNBGoodsInfo *goodsInfo;

///**
// 订单编号
// */
//@property(nonatomic,strong) UILabel *orderNumber;
//
///**
// 订单状态
// */
//@property(nonatomic,strong) UILabel *orderState;

/**
 价钱
 */
@property(nonatomic,strong) UILabel *orderPrice;

/**
 订单/商品描述
 */
@property(nonatomic,strong) UILabel *orderTitle;

/**
 下单时间
 */
@property(nonatomic,strong) UILabel *orderDate;

/**
 商品首图
 */
@property(nonatomic,strong) ZCUIImageView *goodsImageView;

/**
 发送商品按钮
 */
@property(nonatomic,strong) UIButton *btnSendGoods;

/**
 当前cell的高度
 */
@property(nonatomic,assign) CGFloat cellHeight;

/**
 cell的背景视图
 */
@property (nonatomic,strong) UIView *cellBackgroundView;

@end
