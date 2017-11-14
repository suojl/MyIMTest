//
//  ZCUILoading.m
//  SobotKit
//
//  Created by lizhihui on 15/11/11.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCUILoading.h"
#import "ZCUIWavesView.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
@interface ZCUILoading()
{
    UIActivityIndicatorView *activityView;
}

@end


@implementation ZCUILoading
static  ZCUILoading *_zcuiLoading = nil;
// 单例
+ (ZCUILoading*)shareZCUILoading{
    static  dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(_zcuiLoading==nil){
            _zcuiLoading = [[self alloc] init];
        }
    });
    return _zcuiLoading;
}



#pragma mark -- show
- (void)showAddToSuperView:(UIView*)SuperView{
    if(_zcuiLoading){
        for (UIView *v in _zcuiLoading.subviews) {
            [v removeFromSuperview];
        }
    }
    
    _zcuiLoading.frame = CGRectMake(0, NavBarHeight, SuperView.frame.size.width,SuperView.frame.size.height-NavBarHeight-50);
    [_zcuiLoading setBackgroundColor:[UIColor clearColor]];
    [_zcuiLoading setAutoresizesSubviews:YES];
    [_zcuiLoading setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView setFrame:CGRectMake(0, 0, 40, 40)];
    [activityView setBackgroundColor:[UIColor clearColor]];
    [activityView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin];
    [activityView startAnimating];
    [_zcuiLoading addSubview:activityView];
    [activityView setCenter:CGPointMake(_zcuiLoading.bounds.size.width/2, _zcuiLoading.bounds.size.height/2)];
    
    // 将ZCUILoading添加到传进来的父视图SuperView
    [SuperView addSubview:self];
    
}

#pragma mark -- dismiss

// 消失
- (void)dismiss{
    if(activityView){
        [activityView stopAnimating];
        [activityView removeFromSuperview];
    }
    // 移除所有子视图
    [self removeFromSuperview];
}


@end
