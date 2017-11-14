//
//  ZCOrderCusFieldController.h
//  SobotApp
//
//  Created by zhangxy on 2017/7/21.
//  Copyright © 2017年 com.sobot.chat.app. All rights reserved.
//

#import "ZCUIBaseController.h"
#import "ZCLibOrderCusFieldsModel.h"

@interface ZCOrderCusFieldController : ZCUIBaseController

@property(nonatomic,strong) ZCLibOrderCusFieldsModel *preModel;

@property (nonatomic, strong)  void(^orderCusFiledCheckBlock) (ZCLibOrderCusFieldsDetailModel *model,NSMutableArray *arr);

@property(nonatomic,strong) NSMutableArray *listArray;

@end
