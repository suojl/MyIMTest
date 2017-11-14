//
//  KNBPartPresentAnimation.h
//  SobotKit
//
//  Created by suojl on 2017/11/6.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KNBPartPresentAnimation : NSObject <UIViewControllerAnimatedTransitioning>


/**
 *  呈现新的控制器
 */
@property (nonatomic, assign) BOOL reverse;

/**
 *  动画持续时间
 */
@property (nonatomic, assign) NSTimeInterval duration;

@end
