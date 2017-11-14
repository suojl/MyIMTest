//
//  ZCOrderTypeController.h
//  SobotApp
//
//  Created by zhangxy on 2017/7/18.
//  Copyright © 2017年 com.sobot.chat.app. All rights reserved.
//


#import "ZCUIBaseController.h"
//#import "ZCOrderTypeModel.h"
#import "ZCLibTicketTypeModel.h"
@interface ZCOrderTypeController : ZCUIBaseController

@property(nonatomic,weak) NSString *pageTitle;

@property(nonatomic,weak) UIViewController *parentVC;

@property(nonatomic,strong) NSString *typeId;

@property (nonatomic, strong)  void(^orderTypeCheckBlock) (ZCLibTicketTypeModel *model);

@property(nonatomic,strong)NSMutableArray   *listArray;

@end
