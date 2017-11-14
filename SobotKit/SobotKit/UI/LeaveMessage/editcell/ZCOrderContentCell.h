//
//  ZCOrderContentCell.h
//  SobotApp
//
//  Created by zhangxy on 2017/7/12.
//  Copyright © 2017年 com.sobot.chat.app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCOrderCreateCell.h"
#import "ZCUIPlaceHolderTextView.h"


@interface ZCOrderContentCell : ZCOrderCreateCell

@property(weak,nonatomic) NSMutableArray *imageArr;

@property (nonatomic,strong) UIView *viewContent;

@property (nonatomic,strong) ZCUIPlaceHolderTextView *textDesc;

@property (nonatomic,strong) UIScrollView *fileScrollView;

@property (nonatomic,strong) NSMutableArray * imagePathArr;

@property (nonatomic,strong) UILabel  * tipLab;// 问题描述

@end
