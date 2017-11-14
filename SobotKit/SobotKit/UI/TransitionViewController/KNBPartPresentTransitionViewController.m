//
//  KNBPartPresentTransitionViewController.m
//  SobotKit
//
//  Created by suojl on 2017/11/6.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "KNBPartPresentTransitionViewController.h"
#import "KNBPartPresentAnimation.h"
#import "KNBPartPresentationController.h"
#import "KNBPartPresentAnimation.h"

@interface KNBPartPresentTransitionViewController ()

@end

@implementation KNBPartPresentTransitionViewController

-(instancetype)init{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        // 转场动画代理
        self.transitioningDelegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- UIViewControllerTransitioningDelegate 控制器转场动画代理
-(UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source{
    KNBPartPresentationController *presentationController = [[KNBPartPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    presentationController.shouldDismissWhenTap = NO;
    return presentationController;
}


// 呈现新视图控制器时使用的转场动画 ②
//- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
//    KNBPartPresentAnimation *presetnAnimation = [[KNBPartPresentAnimation alloc] init];
//    presetnAnimation.reverse = YES;
//    return presetnAnimation;
//}
//
//// 返回父视图控制器时使用的转场动画 ③
//- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
//
//    KNBPartPresentAnimation *presetnAnimation = [[KNBPartPresentAnimation alloc] init];
//    presetnAnimation.reverse = NO;
//    return presetnAnimation;
//}
@end
