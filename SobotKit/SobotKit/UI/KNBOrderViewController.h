//
//  KNBOrderViewController.h
//  SobotKit
//
//  Created by suojl on 2017/11/1.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KNBPartPresentTransitionViewController.h"

@protocol KNBOrderViewControllerDelegate <NSObject>
@optional

-(void) dismissViewController:(UIViewController *)controller andSendOrderMessage:(NSString *)msg;
@end

@interface KNBOrderViewController : KNBPartPresentTransitionViewController

@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) UITableView *orderTableView;

@property (nonatomic, weak) id<KNBOrderViewControllerDelegate> vcDelegate;

@end
