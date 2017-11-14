//
//  ZCOrderEditCell.h
//  SobotApp
//
//  Created by zhangxy on 2017/7/12.
//  Copyright © 2017年 com.sobot.chat.app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCOrderCreateCell.h"

#import "ZCUIPlaceHolderTextView.h"
@interface ZCOrderEditCell : ZCOrderCreateCell

@property (nonatomic,strong) UILabel *labelName;;

@property (nonatomic,strong) ZCUIPlaceHolderTextView *textContent;

@end
