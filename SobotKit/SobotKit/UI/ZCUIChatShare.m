//
//  ZCUIChatShare.m
//  SobotKit
//
//  Created by zhangxy on 15/11/13.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCUIChatShare.h"
#import "ZCUIConfigManager.h"


@implementation ZCUIChatShare{
    NSTimer *tipTimer;
    int     userTipTime;        // 用户不说话
    BOOL    isUserTipTime;      // 是否提醒了
    
    int     adminTipTime;       // 客服超时
    BOOL    isAdminTipTime;     // 是否已经提醒
    
    int     lowMinTime;         // 不足1分钟，提醒
    
    id<ZCUIChatDelegate> _delegate;
    
    UITextView *inputTextView;   // 输入框
    int        inputCount;       // 循环计数
    NSString   *lastMessage;     // 上次计数时的内容
    BOOL       isSendInput;
}

static ZCUIChatShare *_instance=nil;
+(ZCUIChatShare *)getInstance{
    // 考虑即时清理，没有使用单例
    if(_instance==nil){
        
        _instance=[[ZCUIChatShare alloc] init];
    }
    return _instance;
}


-(void) cleanAllInstanceValue {
    isAdminTipTime = YES;
    isUserTipTime  = NO;
    
    lowMinTime = 0;
    _isSendToUser = NO;
    _isSendToSobot = NO;
    
    if(tipTimer){
        [tipTimer invalidate];
    }
    
    _instance = nil;
}


-(id)init{
    self=[super init];
    if(self){
        lowMinTime = 0;
    
        isAdminTipTime = YES;
        isUserTipTime  = NO;
        
        userTipTime = 0;
        adminTipTime = 0;

        tipTimer       = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCount) userInfo:nil repeats:YES];
        
    }
    return self;
}

-(void)setShareDelegate:(id<ZCUIChatDelegate>)delegate{
    _delegate=delegate;
}

-(ZCLibConfig *) getZCLibConfig{
    return [[ZCUIConfigManager shareConfigManager] getZCLibConfig];
}


-(void)cleanAdminCount{
    isUserTipTime  = NO;
    isAdminTipTime = YES;
    
    adminTipTime   = 0;
    userTipTime    = 0;
}

-(void)cleanUserCount{
    isUserTipTime  = YES;
    isAdminTipTime = NO;

    userTipTime    = 0;
    adminTipTime   = 0;
}

-(void)pauseCount{
    isUserTipTime  = YES;
    isAdminTipTime = YES;
}

-(void)pauseToStartCount{
    if(self.isSendToSobot || self.isSendToUser){
        if(self.isCustomerLastSend){
            // 客服最后发送消息调用
            [self cleanAdminCount];
        }else{
            // 用户最后发消息
            [self cleanUserCount];
        }
    }else{
        // 客服最后发送消息调用
        [self cleanAdminCount];
    }
}

-(void)setInputListener:(UITextView *)textView{
    inputTextView = textView;
}


/**
 *  计数，计算提示信息
 */
-(void)timerCount{
//        if(!isReachable){
//            return;
//        }
    
//    [ZCLogUtils logHeader:LogHeader debug:@"isArtificial====%zd\n,isUserTipTime====%zd\n,userTipTime===%d\n",[self getZCLibConfig].isArtificial,isUserTipTime,userTipTime];
    
    lowMinTime=lowMinTime+1;
    
    // 用户超时，此处不处理了，改由服务器判断
    
    // 用户长时间不说话,人工才添加提示语
    if(!isUserTipTime && [self getZCLibConfig].isArtificial){
        userTipTime=userTipTime+1;
        if(userTipTime>=[self getZCLibConfig].userTipTime*60){
         
//            if(_delegate && [_delegate respondsToSelector:@selector(addMessageToList:type:name:face:source:content:)]){
//                [_delegate addMessageToList:ZCTipCellMessageUserTipWord type:0 name:@"" face:@"" source:1 content:nil];
//            }
            
            
            userTipTime   = 0;
            isUserTipTime = YES;
        }
    }
    
    // 人工时才提醒，客服不说话
    if(!isAdminTipTime && [self getZCLibConfig].isArtificial){
        adminTipTime=adminTipTime+1;
        if(adminTipTime>[self getZCLibConfig].adminTipTime*60){
//            if(_delegate && [_delegate respondsToSelector:@selector(addMessageToList:type:name:face:source:content:)]){
//                [_delegate addMessageToList:ZCTipCellMessageAdminTipWord type:0 name:@"" face:@"" source:1 content:nil];
//            }
            adminTipTime   = 0;
            isAdminTipTime = YES;
        }
    }
    
    
    
    // 间隔指定时间，发送正在输入内容，并且是人工客服时
    if(inputTextView && [[ZCUIConfigManager shareConfigManager] getZCLibConfig].isArtificial){
        inputCount = inputCount + 1;
        
        if(inputCount > 3){
            
            inputCount = 0;
            
            // 发送正输入
            NSString *text = inputTextView.text;
            if(![text isEqual:lastMessage]){
                lastMessage = text;
                
                [ZCLogUtils logHeader:LogHeader debug:@"发送正在输入内容...%@",lastMessage];
                
                if(isSendInput){
                    return;
                }
                isSendInput = YES;
                [[[ZCUIConfigManager shareConfigManager] getZCLibServer]
                 sendInputContent:[[ZCUIConfigManager shareConfigManager] getZCLibConfig]
                 content:lastMessage success:^(ZCNetWorkCode sendCode) {
                    isSendInput = NO;
                } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
                    isSendInput = NO;
                }];
            }
        }
    }
}

@end
