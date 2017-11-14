//
//  ZCUIVoiceTools.m
//  SobotKit
//
//  Created by zhangxy on 15/11/12.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCUIVoiceTools.h"
#import <AVFoundation/AVFoundation.h>

@interface ZCUIVoiceTools()<AVAudioPlayerDelegate>{
    AVAudioPlayer           *audioPlayer;
//    id<ZCUIVoiceDelegate>   delegate;
}



@end

@implementation ZCUIVoiceTools

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark 播放声音

-(void)playAudio:(NSURL *)audioURL data:(NSData *)data{
    if(audioPlayer!=nil && [audioPlayer isPlaying]){
        [audioPlayer stop];
        
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
        }
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
    
    
    //初始化播放器的时候如下设置
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    // iOS5之后 AVAudioSession 代替之前的AudioSession
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    
    NSError *error;
    if(data!=nil){
        audioPlayer=[[AVAudioPlayer alloc]initWithData:data error:&error];
    }else{
        audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:audioURL
                                                          error:&error];
    }
    audioPlayer.delegate=self;
    audioPlayer.volume=1;
    if (error) {
        
        [ZCLogUtils logHeader:LogHeader info:@"error:%@",[error description]];
        if(_delegate && [_delegate respondsToSelector:@selector(voicePlayStatusChange:)]){
            [_delegate voicePlayStatusChange:ZCVoicePlayStatusStartError];
        }
        return;
    }
    //添加近距离事件监听，添加前先设置为YES，如果设置完后还是NO的读话，说明当前设备没有近距离传感器
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    
    //准备播放
    [audioPlayer prepareToPlay];
    //播放
    [audioPlayer play];
}

-(void) stopVoice{
    if(audioPlayer && audioPlayer.isPlaying){
        audioPlayer.currentTime = 0;  //当前播放时间设置为0
        [audioPlayer stop];
    }
    
    //添加近距离事件监听，添加前先设置为YES，如果设置完后还是NO的读话，说明当前设备没有近距离传感器
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
}


#pragma mark 播放停止、失败 代理
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    [ZCLogUtils logHeader:LogHeader debug:@"走了完成的代理-----"];
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    
    if(_delegate && [_delegate respondsToSelector:@selector(voicePlayStatusChange:)]){
        [_delegate voicePlayStatusChange:ZCVoicePlayStatusFinish];
    }
    // 后台音乐可以继续播放
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    
    [ZCLogUtils logHeader:LogHeader debug:@"走了失败的代理-----"];
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    
    if(_delegate && [_delegate respondsToSelector:@selector(voicePlayStatusChange:)]){
        [_delegate voicePlayStatusChange:ZCVoicePlayStatusError];
    }
}
// 当音频播放过程中被中断时
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
    // 当音频播放过程中被中断时，执行该方法。比如：播放音频时，电话来了！
    // 这时候，音频播放将会被暂停。
    if(_delegate && [_delegate respondsToSelector:@selector(voicePlayStatusChange:)]){
        [_delegate voicePlayStatusChange:ZCVoicePlayStatusPause];
    }
}

// 当中断结束时
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags{
    
    // AVAudioSessionInterruptionFlags_ShouldResume 表示被中断的音频可以恢复播放了。
    // 该标识在iOS 6.0 被废除。需要用flags参数，来表示视频的状态。
    
    
    [ZCLogUtils logHeader:LogHeader debug:@"中断结束，恢复播放"];
    
    if (flags == AVAudioSessionInterruptionOptionShouldResume && player != nil){
        [player play];
        if(_delegate && [_delegate respondsToSelector:@selector(voicePlayStatusChange:)]){
            [_delegate voicePlayStatusChange:ZCVoicePlayStatusReStart];
        }
    }
}


#pragma mark - 处理近距离监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)//黑屏
    {
        
        [ZCLogUtils logHeader:LogHeader info:@"Device is close to user"];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else
    {
        //没黑屏幕
        
        [ZCLogUtils logHeader:LogHeader info:@"Device is not close to user"];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (![audioPlayer isPlaying]) {//没有播放了，也没有在黑屏状态下，就可以把距离传感器关了
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
        }
    }
}

@end
