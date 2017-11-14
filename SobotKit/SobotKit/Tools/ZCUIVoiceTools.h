//
//  ZCUIVoiceTools.h
//  SobotKit
//
//  Created by zhangxy on 15/11/12.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import <Foundation/Foundation.h>

/**播放状态*/
typedef NS_ENUM(NSInteger,ZCVoicePlayStatus) {
    /** 播放失败 */
    ZCVoicePlayStatusError      = 0,
    /** 中断开始播放*/
    ZCVoicePlayStatusReStart    = 1,
    /** 中断 */
    ZCVoicePlayStatusPause      = 2,
    /** 播放完成 */
    ZCVoicePlayStatusFinish     = 3,
    /** 开始失败*/
    ZCVoicePlayStatusStartError = 4,
};

/**
 *  ZCUIVoiceDelegate
 */
@protocol ZCUIVoiceDelegate <NSObject>

/**
 *  音频播放设置
 *
 *  @param status 播放状态
 */
-(void)voicePlayStatusChange:(ZCVoicePlayStatus) status;

@end

/**
 *  ZC 播放语音的工具类
 *  设置播放语音的代理和代理方法 播放状态 播放音频文件 停止播放
 */
@interface ZCUIVoiceTools : NSObject

/**
 *  设置播放语音的代理,将传进来的对象作为代理
 */
@property (nonatomic,assign) id<ZCUIVoiceDelegate> delegate;


/**
 *  播放音频文件
 *  @param audioURL url地址
 *  @param data     数据包
 */
-(void)playAudio:(NSURL *)audioURL data:(NSData *)data;

/**
 *  停止播放
 */
-(void) stopVoice;




@end
