//
//  ZCUILoading.h
//  SobotKit
//
//  Created by lizhihui on 15/11/11.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  智齿loading页面
 */
@interface ZCUILoading : UIView

/**
 *  单例
 */
+ (ZCUILoading*)shareZCUILoading;


/**
 *  展示
 *  @param  SuperView 智齿loading要展示的父类View
 */
- (void)showAddToSuperView:(UIView*)SuperView;


/**
 *  消失
 */
- (void)dismiss;

@end
