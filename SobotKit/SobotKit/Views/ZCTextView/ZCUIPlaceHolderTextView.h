//
//  UIPlaceHolderTextView.h
//  Tutu
//
//  Created by zhangxinyao on 14-11-21.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ZCMLEmojiLabel.h"

/**
 *  <#Description#>
 */
@interface ZCUIPlaceHolderTextView : UITextView {
    NSString *placeholder;
    UIColor *placeholderColor;
}


@property (nonatomic,retain)ZCMLEmojiLabel *placeHolderLabel;


/**
 *  占位文字的字体大小
 */
@property (nonatomic,strong) UIFont *placeholederFont;

/**
 *  占位文字
 */
@property(nonatomic, strong) NSString  *placeholder;

/**
 *  占位页面背景颜色
 */
@property(nonatomic, retain) UIColor *placeholderColor;



/**
 *  <#Description#>
 *
 *  @param notification 通知
 */
-(void)textChanged:(NSNotification*)notification;

/**
 *  设置行间距
 */
@property (nonatomic,assign) int LineSpacing;


@end
