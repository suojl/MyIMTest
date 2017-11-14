//
//  ZCOrderOnlyEditCell.h
//  SobotApp
//
//  Created by zhangxy on 2017/7/21.
//  Copyright © 2017年 com.sobot.chat.app. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZCOrderCreateCell.h"

@interface ZCOrderOnlyEditCell : ZCOrderCreateCell

@property (nonatomic,strong) UILabel *labelName;;

@property (nonatomic,strong) UITextField *fieldContent;

@property (nonatomic,strong) UIImageView *imgArrow;;


@end
