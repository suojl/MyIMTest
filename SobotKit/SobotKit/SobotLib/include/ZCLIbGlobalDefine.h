//
//  GlobalDefine.h
//  SobotSDK
//
//  Created by 张新耀 on 15/8/5.
//  Copyright (c) 2015年 sobot. All rights reserved.
//


// UTF8 字符串
#define UTF8Data(str) [str dataUsingEncoding:NSUTF8StringEncoding]



// 应用程序代理
#define ApplicationDelegate                 ((AppDelegate *)[[UIApplication sharedApplication] delegate])


// 是否为iOS7或者iOS7以上的版本，如果设备版本<iOS7 返回NO 否则返回YES
#define iOS7                                ((floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)? NO:YES)


// 是否为竖屏
#define isPortrait                          ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown)


// 格式化转换(int转String)
#define IntToString(x)                      [NSString stringWithFormat:@"%d",x]


// 获取NSUserDefaults对象
#define UserDefaults                        [NSUserDefaults standardUserDefaults]


// 获取发送通知对象
#define NOTIFICATION_CENTER                 [NSNotificationCenter defaultCenter]



// 导航栏的高度
//#define NavBarHeight                        (iOS7 ? 64.0 : 44.0)
//
//
//// 状态栏的高度
//#define StatusBarHeight                     (iOS7 ? 0.0 : 20.0)


// 设备屏幕尺寸的宽度
#define SysScreenWidth                      [[UIScreen mainScreen] bounds].size.width

// 设备屏幕尺寸的高度
#define SysScreenHeight                     [[UIScreen mainScreen] bounds].size.height

// 屏幕旋转后宽度的尺寸
#define ScreenWidth                         (isPortrait ? MIN(SysScreenWidth,SysScreenHeight) : MAX(SysScreenWidth,SysScreenHeight))

// 屏幕旋转后高度的尺寸
#define ScreenHeight                        (isPortrait ? MAX(SysScreenWidth,SysScreenHeight) : MIN(SysScreenWidth,SysScreenHeight))


// iPhoneX
#define ZC_iPhoneX (SysScreenWidth == 375.f && SysScreenHeight == 812.f ? YES : NO)

// 导航栏的高度
#define NavBarHeight                        (ZC_iPhoneX ? 88.f : (iOS7 ? 64.0 : 44.0))

// 状态栏的高度
#define StatusBarHeight                     (ZC_iPhoneX ? 44.f : (iOS7 ? 0.0 : 20.0))


// View的宽度
#define ViewWidth(v)                        v.frame.size.width

// View的高度
#define ViewHeight(v)                       v.frame.size.height

// View的X轴坐标
#define ViewX(v)                            v.frame.origin.x

// View的Y轴坐标
#define ViewY(v)                            v.frame.origin.y

// 颜色取值方法
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define COLORWithAlpha(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define UIColorFromRGBAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]


// 多语言支持
#define ZCSTLocalString(key) NSLocalizedStringFromTable(key, @"SobotLocalizable", nil)


