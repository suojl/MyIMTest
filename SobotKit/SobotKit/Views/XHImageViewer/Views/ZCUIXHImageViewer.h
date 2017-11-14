//
//  XHImageViewer.h
//  XHImageViewer
//
//  Created by 曾 宪华 on 14-2-17.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507
//  本人QQ群（142557668）. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCUIXHImageURLDataSource.h"

@class ZCUIXHImageViewer;

/**
 *  WillDismissWithSelectedViewBlock
 */
typedef void (^WillDismissWithSelectedViewBlock)(ZCUIXHImageViewer *imageViewer, UIImageView *selectedView);

/**
 *  DidDismissWithSelectedViewBlock
 */
typedef void (^DidDismissWithSelectedViewBlock)(ZCUIXHImageViewer *imageViewer, UIImageView *selectedView);

/**
 *  DidChangeToImageViewBlock
 */
typedef void (^DidChangeToImageViewBlock)(ZCUIXHImageViewer *imageViewer, UIImageView *selectedView);

@protocol ZCUIXHImageViewerDelegate <NSObject>

@optional
- (void)imageViewer:(ZCUIXHImageViewer *)imageViewer
    willDismissWithSelectedView:(UIImageView *)selectedView;
- (void)imageViewer:(ZCUIXHImageViewer *)imageViewer
    didDismissWithSelectedView:(UIImageView *)selectedView;
- (void)imageViewer:(ZCUIXHImageViewer *)imageViewer
    didChangeToImageView:(UIImageView *)selectedView;

- (UIView *)customTopToolBarOfImageViewer:(ZCUIXHImageViewer *)imageViewer;
- (UIView *)customBottomToolBarOfImageViewer:(ZCUIXHImageViewer *)imageViewer;
@end

@interface ZCUIXHImageViewer : UIView

@property (nonatomic, weak) id<ZCUIXHImageViewerDelegate> delegate;

@property (nonatomic, assign) CGFloat backgroundScale;

@property (nonatomic, assign) BOOL disableTouchDismiss;

- (UIImage *)currentImage;

- (void)showWithImageViews:(NSArray *)views
              selectedView:(UIImageView *)selectedView;

- (void)tappedScrollView:(UITapGestureRecognizer *)sender;

- (id)initWithImageViewerWillDismissWithSelectedViewBlock:(WillDismissWithSelectedViewBlock)willDismissWithSelectedViewBlock
                          didDismissWithSelectedViewBlock:(DidDismissWithSelectedViewBlock)didDismissWithSelectedViewBlock
                                didChangeToImageViewBlock:(DidChangeToImageViewBlock)didChangeToImageViewBlock;

@end
