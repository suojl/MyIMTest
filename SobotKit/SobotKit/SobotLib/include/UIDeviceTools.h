//
//  UIDeviceTools.h
//  SobotKitLimit
//
//  Created by zhangxy on 15/11/21.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  设备类型
 */
typedef NS_ENUM(NSUInteger, UIDeviceFamily) {
    /**
     *  iPhone
     */
    UIDeviceFamilyiPhone,
    /**
     *  iPod
     */
    UIDeviceFamilyiPod,
    /**
     *  iPad
     */
    UIDeviceFamilyiPad,
    /**
     *  AppleTV
     */
    UIDeviceFamilyAppleTV,
    /**
     *  未知
     */
    UIDeviceFamilyUnknown,
};

/**
 *  设备工具类
 *  
 *  获取设备类型 设备名称  UIID
 */
@interface UIDeviceTools : NSObject

/**
 *  单例
 *
 *  @return UIDeviceTools（当前类创建的对象）
 */
+(id)shareDeviceTools;


/**
 Returns a machine-readable model name in the format of "iPhone4,1"
 */
- (NSString *)modelIdentifier;

/**
 Returns a human-readable model name in the format of "iPhone 4S". Fallback of the the `modelIdentifier` value.
 */
- (NSString *)modelName;

/**
 *  用户命名的设备名称
 *
 *  @return 设备名称
 */
- (NSString *)userAgentName;

/**
 Returns the device family as a `UIDeviceFamily`
 */
- (UIDeviceFamily)deviceFamily;

/**
 *  获取UIID
 *
 *  @return UIID
 */
-(NSString *) getIOSUUID;



/**
 获取系统版本号

 @return <#return value description#>
 */
- (NSString *)getIOSVersion;

@end
