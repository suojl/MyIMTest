//
//  RecordView.h
//  SobotSDK
//
//  Created by 张新耀 on 15/8/12.
//  Copyright (c) 2015年 sobot. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

/**
 *  录音状态
 */
typedef NS_ENUM(NSInteger, RecordState) {
    /** 开始录音或接着录音 */
    RecordStart=1,
    /** 暂停录音 */
    RecordPause=2,
    /** 录音完成 */
    RecordComplete=3,
    /** 取消录音 */
    RecordCancel=4,
};

/**
 *  ZCUIRecordDelegate 
 */
@protocol ZCUIRecordDelegate <NSObject>

/**
 *  录音结束
 *
 *  @param filePath 录音文件路径
 *  @param duration 音频时长
 */
-(void)recordComplete:(NSString *)filePath videoDuration:(CGFloat )duration;

/**
 *  开始录音 取消录音 页面cell的闪烁动画，以及取消发送之后删除 cell的事件
 *  @param  duration  录音时长
 *  @param  type  开始录音/取消录音
 *
 */
- (void)recordCompleteType:(RecordState) type videoDuration:(CGFloat)duration;

@end

/**
 *  录音view
 *  处理录音事件
 */
@interface ZCUIRecordView : UIView<AVAudioRecorderDelegate>

// 录音成功代理，录音没有取消时调用
@property (nonatomic , retain) id<ZCUIRecordDelegate> delegate;

/**
 *  初始化view
 *
 *  @param delegate 录音完成，返回录音文件
 *  @param view 添加到传入的View上计算frame
 *  @return 初始化对象
 */
- (ZCUIRecordView *)initRecordView:(id<ZCUIRecordDelegate>) delegate cView:(UIView *)view;


/**
 *  显示弹出层
 *  @param view 添加到传入的View上
 */
- (void)showInView:(UIView *)view;

/**
 *  取消View
 */
- (void)dismissRecordView;

/**
 *  改变录音状态
 *
 *  @param state 当前显示的状态
 */
-(void)didChangeState:(RecordState) state;

/**
 *   当前时间
 */
-(NSTimeInterval) currentTime;

@end
