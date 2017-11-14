//
//  ZCActionSheet.h
//  wash
//
//  Created by lizhihui on 15/10/21.
//
//

#import <UIKit/UIKit.h>

@class ZCActionSheet;

/**
 *  The statement agreement ZCActionSheetDelegate
 */
@protocol ZCActionSheetDelegate <NSObject>

@optional

/**
 * ZCActionSheet 代理事件
 * @param actionSheet ZCActionSheet
 * @param buttonIndex 选中的下标
 */
- (void)actionSheet:(ZCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

/** 
 *  ZCActionSheet
 */
@interface ZCActionSheet : UIView

/**
 *  代理
 */
@property (nonatomic, weak  ) id <ZCActionSheetDelegate> delegate;

// 选中的下标
@property (nonatomic, assign) int                        selectIndex;


/**
 *  创建ZCActionSheet方法
 *  @param delegate  代理
 *  @param color     选中的颜色
 *  @param cancelTitle 取消按钮的标题
 *  @param otherTitles,...  其他按钮
 *  @return instancetype ZCActionSheet类
 */
- (instancetype)initWithDelegate:(id<ZCActionSheetDelegate>)delegate selectedColor:(UIColor *) color CancelTitle:(NSString *)cancelTitle OtherTitles:(NSString*)otherTitles,... NS_REQUIRES_NIL_TERMINATION;



- (instancetype)initWithDelegate:(id<ZCActionSheetDelegate>)delegate selectedColor:(UIColor *) color showTitle:(NSString *)title CancelTitle:(NSString *)cancelTitle OtherTitles:(NSString*)otherTitles,... NS_REQUIRES_NIL_TERMINATION;

/**
 *  展示ZCActionSheet
 */
- (void)show;

@end
