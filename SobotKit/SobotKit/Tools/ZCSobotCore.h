//
//  ZCSobotCore.h
//  SobotKit
//
//  Created by zhangxy on 2017/2/14.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZCKitInfo.h"
#import "ZCLibClient.h"
#import "ZCUIKeyboardDelegate.h"
#import "ZCUIChatKeyboard.h"

/**
 *  DidFinishPickingMediaBlock
 */
typedef void(^DidFinishPickingMediaBlock)(NSString *filePath , ZCMessageType type, NSString *duration);

/**
 *  ZCSobotCore
 */
@interface ZCSobotCore : NSObject



/**
 判断当前初始化条件是否改变

 @return YES 需要从新初始化，NO不需要重新初始化
 */
+(BOOL) checkInitParameterChanged;

/**
 *  根据类型获取图片
 *  @param zc_imagepicker UIImagePickerController
 *  @param buttonIndex 2，来源照相机，1来源相册
 *  @param delegate       ZCUIKeyboardDelegate
 *
 */
+(void)getPhotoByType:(NSInteger) buttonIndex byUIImagePickerController:(UIImagePickerController*)zc_imagepicker Delegate:(id)delegate ;


/**
 *  系统相机相册的完成的代理事件
 *  @param zc_imagepicker  UIImagePickerController
 *  @param zc_sourceView   父类VC的view
 *  @param delegate       ZCUIKeyboardDelegate
 *  @param info           图片资源
 */
+(void)imagePickerController:(UIImagePickerController *)zc_imagepicker
didFinishPickingMediaWithInfo:(NSDictionary *)info WithView:(UIView *)zc_sourceView
                    Delegate:(id)delegate block:(DidFinishPickingMediaBlock) finshBlock;;

@end
