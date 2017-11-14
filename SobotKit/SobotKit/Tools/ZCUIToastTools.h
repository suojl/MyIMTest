//
//  ZCUIToastTools.h
//  SobotKitLit
//
//  Created by zhangxy on 15/11/18.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/**
 *  ZCToastPosition
 */
typedef NS_ENUM(NSInteger,ZCToastPosition) {
    /**
     *  中心
     */
    ZCToastPositionCenter = 0,
    /**
     *  顶部
     */
    ZCToastPositionTop    = 1,
    /**
     *  底部
     */
    ZCToastPositionBottom = 2,
};

/**
 *  ZC Toast工具类
 */
@interface ZCUIToastTools : NSObject

/**
 *  单例
 *
 *  @return ZCUIToastTools创建的对象
 */
+(id)shareToast;

/**
 *  展示Toast
 *
 *  @param text     展示的文字
 *  @param duration 展示的时间
 *  @param byView   添加到View上
 *  @param position 位置（中心 顶部 底部）
 */
-(void)showToast:(NSString *) text duration:(CGFloat) duration view:(UIView *) byView position:(ZCToastPosition) position;


/**
 *  展示Toast loading
 *
 *  @param status 状态
 *  @param byView 添加的位置
 */
-(void)showProgress:(NSString *) status with:(UIView *) byView;
-(void)dismisProgress;


/**
 *  展示Toast
 *
 *  @param text     展示的文字
 *  @param duration 展示的时间
 *  @param byView   添加到View上
 *  @param position 位置（中心 顶部 底部）
 *  @param image    展示图片
 */
-(void)showToast:(NSString *) text duration:(CGFloat) duration view:(UIView *) byView position:(ZCToastPosition) position Image:(UIImage*)image;

@end
