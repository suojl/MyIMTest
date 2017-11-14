//
//  ZCUIImageTools.h
//  SobotKit
//
//  Created by zhangxy on 15/11/23.
//  Copyright © 2015年 zhichi. All rights reserved.
//
#import <Foundation/Foundation.h>


// Fix for issue #416 Undefined symbols for architecture armv7 since WebP introduction when deploying to device
void WebPInitPremultiplyNEON(void);

void WebPInitUpsamplersNEON(void);

void VP8DspInitNEON(void);

/**
 *  ZC 图片处理工具类
 */
@interface ZCUIImageTools : NSObject

/**
 *  把颜色值转换为color
 *
 *  @param color  颜色
 *
 *  @return image 图片
 */
+ (UIImage *) zcimageWithColor:(UIColor *)color;

/**
 *  等比缩放图片
 *
 *  @param size  缩放尺寸大小
 *  @param image 将要缩放的图片
 *
 *  @return image 缩放后的图片
 */
+(UIImage*)zcScaleToSize:(CGSize)size with:(UIImage *) image;


+ (UIImage *)zc_animatedGIFNamed:(NSString *)name;

+ (UIImage *)zc_animatedGIFWithData:(NSData *)data;

+ (UIImage *)zc_imageWithData:(NSData *)data;

+ (UIImage *)zc_animatedImageByScalingAndCroppingToSize:(CGSize)size with:(UIImage *) image;

/**
 *  获取data的图片了下
 *
 *  @param data 图片数据
 *
 *  @return 图片类型(image/jpeg、image/png、image/gif)
 */
+ (NSString *)zc_contentTypeForImageData:(NSData *)data;



/**
 *  编码图片
 *
 *  @param image <#image description#>
 *
 *  @return <#return value description#>
 */
+(UIImage *)decode:(UIImage *)image;

+(UIImage *)fastImageWithData:(NSData *)data;

+(UIImage *)fastImageWithContentsOfFile:(NSString *)path;

@end
