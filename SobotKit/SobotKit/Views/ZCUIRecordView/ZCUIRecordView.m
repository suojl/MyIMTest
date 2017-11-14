//
//  RecordView.m
//  SobotSDK
//
//  Created by 张新耀 on 15/8/12.
//  Copyright (c) 2015年 sobot. All rights reserved.
//

#import "ZCUIRecordView.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIConfigManager.h"

#define RecordViewWidth  180
#define RecordViewHeight 180

@implementation ZCUIRecordView{
    UIView      *topView;
    UIImageView *anniminView;
    UIImageView *pauseView;
    UILabel     *timeLablel;
    UILabel     *tipLabel;
    
    NSTimer     *voiceTimer;
    
    //开始录音
    NSURL           *tmpFile;
    AVAudioRecorder *recorder;
    BOOL            recording;
    AVAudioPlayer   *audioPlayer;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (ZCUIRecordView *)initRecordView:(id<ZCUIRecordDelegate>)delegate cView:(UIView *)view{
    self=[super init];
    if(self){
        //初始化背景视图，添加手势
        self.frame = CGRectMake((view.frame.size.width-RecordViewWidth)/2, (view.frame.size.height-RecordViewHeight)/2, RecordViewWidth, RecordViewHeight);
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        self.layer.cornerRadius  = 5.0f;
        self.layer.masksToBounds = YES;
        
        [self createView];
        
        _delegate=delegate;
    }
    return self;
}

-(void)createView{
    topView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, RecordViewWidth, 100)];
    [topView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:topView];
    
    
    UIImageView *voiceTagView=[[UIImageView alloc] initWithFrame:CGRectMake((RecordViewWidth-166)/2, 30, 166, 70)];
    [voiceTagView setContentMode:UIViewContentModeScaleAspectFit];
    [voiceTagView setImage:[ZCUITools zcuiGetBundleImage:@"ZCRecording_mike"]];
    [topView addSubview:voiceTagView];
    
    anniminView=[[UIImageView alloc] initWithFrame:CGRectMake((RecordViewWidth-166)/2, 30, 166, 70)];
    [anniminView setContentMode:UIViewContentModeScaleAspectFit];
    anniminView.animationImages = [NSArray arrayWithObjects:
                                   [ZCUITools zcuiGetBundleImage:@"ZCRecording_volum1"],
                                   [ZCUITools zcuiGetBundleImage:@"ZCRecording_volum2"],
                                   [ZCUITools zcuiGetBundleImage:@"ZCRecording_volum3"],
                                   [ZCUITools zcuiGetBundleImage:@"ZCRecording_volum4"],
                                   [ZCUITools zcuiGetBundleImage:@"ZCRecording_volum5"], nil];
    anniminView.animationDuration = .8f;
    anniminView.animationRepeatCount = 0;
    [topView addSubview:anniminView];
    [anniminView startAnimating];
    
    pauseView=[[UIImageView alloc] initWithImage:[ZCUITools zcuiGetBundleImage:@"ZCRecording_cancel"]];
    [pauseView setContentMode:UIViewContentModeScaleAspectFit];
    [pauseView setFrame:CGRectMake((RecordViewWidth-166)/2, 30, 166, 70)];
    [self addSubview:pauseView];
    pauseView.hidden=YES;
    
    timeLablel=[[UILabel alloc] initWithFrame:CGRectMake(0, 105, RecordViewWidth, 25)];
    [timeLablel setBackgroundColor:[UIColor clearColor]];
    [timeLablel setTextColor:[UIColor whiteColor]];
    [timeLablel setFont:[ZCUITools zcgetListKitDetailFont]];
    timeLablel.layer.cornerRadius  = 3.0f;
    timeLablel.layer.masksToBounds = YES;
    [timeLablel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:timeLablel];
    
    
    tipLabel=[[UILabel alloc] initWithFrame:CGRectMake(25, 135, RecordViewWidth-50, 25)];
    [tipLabel setBackgroundColor:[UIColor lightGrayColor]];
    [tipLabel setFont:[ZCUITools zcgetListKitDetailFont]];
    tipLabel.layer.cornerRadius  = 3.0f;
    tipLabel.layer.masksToBounds = YES;
    [tipLabel setTextAlignment:NSTextAlignmentCenter];
    [tipLabel setTextColor:[UIColor whiteColor]];
    [self addSubview:tipLabel];
}


/**
 *  显示弹出层
 *
 *  @param view
 */
- (void)showInView:(UIView *)view{
    [[ZCUIConfigManager getInstance] pauseCount];
    [view addSubview:self];
}



/**
 *  关闭弹出层
 */
- (void)dismissRecordView{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [UIView animateWithDuration:1.0f animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            // 当用户没有发送的时候，不调用此方法，无法启动计数
            [[ZCUIConfigManager getInstance] pauseToStartCount];
            [self removeFromSuperview];
        }
    }];
}

-(void)didChangeState:(RecordState) state{
    switch (state) {
        case RecordStart:
            if(_delegate && [_delegate respondsToSelector:@selector(recordCompleteType:videoDuration:)]){
                
                [_delegate recordCompleteType:RecordStart videoDuration:0];
            }
           
            topView.hidden   = NO;
            pauseView.hidden = YES;
            [tipLabel setText:ZCSTLocalString(@"手指上滑，取消发送")];
            [tipLabel setBackgroundColor:UIColorFromRGBAlpha(TextTopColor, 0.1)];
            [anniminView startAnimating];
            
            
            if (!recording) {
                recording = YES;
                NSString *fileName=[NSString stringWithFormat:@"%ldtempAudio.wav",(long)[[NSDate date] timeIntervalSince1970]];
                
                tmpFile = [NSURL fileURLWithPath:zcLibGetTmpDownloadFilePath(fileName)];
                [self startForFilePath:tmpFile];
                [recorder prepareToRecord];
                
//                UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
//                view.backgroundColor = [UIColor redColor];
//                [self addSubview:view];
                
            }
            if(!recorder.isRecording){ 
                [recorder record];
            }
            
            if(voiceTimer==nil){
                [timeLablel setText:[NSString stringWithFormat:@"0″"]];
                
                voiceTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerDiscount) userInfo:nil repeats:YES];
            }else{
                [voiceTimer setFireDate:[NSDate date]];
            }
            

            break;

        case RecordPause:
            topView.hidden   = YES;
            pauseView.hidden = NO;
            [tipLabel setText:ZCSTLocalString(@"松开手指，取消发送")];
            [tipLabel setBackgroundColor:UIColorFromRGB(BgVoiceRedColor)];
            
//            [tipLabel setBackgroundColor:[UIColor redColor]];
//            if (voiceTimer!=nil && voiceTimer.isValid) {
//                [voiceTimer setFireDate:[NSDate distantFuture]];
//            }
            
//            [anniminView stopAnimating];
//            [recorder pause];
            
            break;
        case RecordCancel:
            if(recording){
                [voiceTimer invalidate];
                recording = NO;
                [recorder stop];
                [anniminView stopAnimating];
            }
            // 取消发送，删除文件
            zcLibDeleteFileAtPath([tmpFile path]);
            
            if(_delegate && [_delegate respondsToSelector:@selector(recordCompleteType:videoDuration:)]){
                
                [_delegate recordCompleteType:RecordCancel videoDuration:[self currentTime]];
            }
            
            break;
        case RecordComplete:
            if(recording){
                [voiceTimer invalidate];
                recording = NO;
                [recorder stop];
                [anniminView stopAnimating];
                
//                AVAudioSession * audioSession = [AVAudioSession sharedInstance];
//                [audioSession setActive:NO error:nil];
//                [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
                
                // 后台应用可以继续播放音乐（例如酷狗音乐）
                [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
                
//                NSData *data=[NSData dataWithContentsOfURL:tmpFile];
                NSError *error;
                audioPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:tmpFile
                                                                  error:&error];
                CGFloat duration=audioPlayer.duration;
                // 至少是1秒
                if(duration>=1){
                    if(_delegate && [_delegate respondsToSelector:@selector(recordComplete:videoDuration:)]){
                        [_delegate recordComplete:[tmpFile path] videoDuration:duration];
                    }
                }else{
                    //[self.window.rootViewController.view makeToast:VoiceMinTips duration:1 position:@"center"];
                    topView.hidden   = YES;
                    pauseView.hidden = NO;
                    pauseView.image = [ZCUITools zcuiGetBundleImage:@"ZCRecording_timeshort"];
                   // [tipLabel setText:VoiceMinTips];
                    [tipLabel setText:ZCSTLocalString(@"说话时间过短")];
                    [tipLabel setBackgroundColor:UIColorFromRGB(BgVoiceRedColor)];
                    [timeLablel setText:[NSString stringWithFormat:@"00:00"]];
                    // 删除发送的空语音
                    if (_delegate && [_delegate respondsToSelector:@selector(recordCompleteType:videoDuration:)]) {
                        [_delegate recordCompleteType:RecordCancel videoDuration:0];
                    }
                }
            }
            break;
        default:
            break;
    }
}

-(NSTimeInterval)currentTime{
    if(recorder){
        return recorder.currentTime;
    }
    return 0;
}

//动态显示时间
-(void)timerDiscount{
    int duration=(int)recorder.currentTime;
   // NSLog(@"当前的时间为：%d",duration);
    // 当时间大于1s的时候
    if (duration == 1) {
     //   NSLog(@"当前时间为1s");
        if(_delegate && [_delegate respondsToSelector:@selector(recordComplete:videoDuration:)]){
            
            [_delegate recordCompleteType:RecordStart videoDuration:1.0f];
        }
    }
    
    if(duration>50){
        int limit=60-duration;
        NSString *text=[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@%d",ZCSTLocalString(@"倒计时:"),limit]];
        
//        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text];
//        [str addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(text.length-2,2)];
//        timeLablel.attributedText=str;
        [timeLablel setText:text];
    }else{
        [timeLablel setText:[NSString stringWithFormat:@"%d″",duration]];
    }
    
    //大于60秒，停止录音
    if(duration>=60){
        [self didChangeState:RecordComplete];
        
//        [self.window.rootViewController.view makeToast:VoiceMaxTips duration:1 position:@"center"];
        topView.hidden   = YES;
        pauseView.hidden = NO;
        pauseView.image = [ZCUITools zcuiGetBundleImage:@"ZCRecording_timeshort"];
        //[tipLabel setText:VoiceMaxTips];
        [tipLabel setText:ZCSTLocalString(@"说话时间过长")];
        [tipLabel setBackgroundColor:UIColorFromRGB(BgVoiceRedColor)];
        [timeLablel setText:[NSString stringWithFormat:@"00:59"]];
        [self dismissRecordView];
    }
}



- (void)startForFilePath:(NSURL *)filePath {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        // [ZCLogUtils logHeader:LogHeader debug:@"audioSession: %@ %d %@", [err domain], (int)[err code], [[[err userInfo] description]];
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
//        [ZCLogUtils logHeader:LogHeader debug:@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]];
        return;
    }
    
    err = nil;
    
    NSData *audioData = [NSData dataWithContentsOfFile:[tmpFile path] options: 0 error:&err];
    if(audioData)
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:[tmpFile path] error:&err];
    }
    
    err = nil;
    recorder = [[AVAudioRecorder alloc] initWithURL:tmpFile settings:[ZCUITools getAudioRecorderSettingDict] error:&err];
    if(!recorder){
//        [ZCLogUtils logHeader:LogHeader debug:@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]];
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    
    [recorder record];
    recorder.meteringEnabled = YES;
    
    //时间
    [recorder recordForDuration:(NSTimeInterval) 60];
}


@end
