//
//  ZCUIConfigManager.m
//  SobotKit
//
//  Created by zhangxy on 15/11/13.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCUIConfigManager.h"
#import "ZCLibMessageConstants.h"
#import "ZCUIChatKeyboard.h"
#import "ZCIMChat.h"
#import "ZCStoreConfiguration.h"

Class object_getClass(id object);

@interface ZCUIConfigManager(){
    ZCLibServer *_libServer;
}

@end


@implementation ZCUIConfigManager{
    NSMutableDictionary *allFaceDict;
    
    ///////////////////////定时器相关/////////////////////////////////
    NSTimer *tipTimer;
    int     userTipTime;        // 用户不说话
    BOOL    isUserTipTime;      // 是否提醒了
    
    int     adminTipTime;       // 客服超时
    BOOL    isAdminTipTime;     // 是否已经提醒
    
    int     lowMinTime;         // 不足1分钟，提醒
    
    UITextView *inputTextView;   // 输入框
    int        inputCount;       // 循环计数
    NSString   *lastMessage;     // 上次计数时的内容
    BOOL       isSendInput;
    
    Class _originalClass;
}


+(ZCUIConfigManager *) getInstance{
    static ZCUIConfigManager *_kitInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(_kitInstance == nil){
            _kitInstance = [[self alloc] init];
        }
    });
    return _kitInstance;
}

-(id)init{
    self=[super init];
    if(self){
        [ZCStoreConfiguration cleanLocalParamter];
        
        _libServer = [ZCLibServer getLibServer];
    }
    return self;
}


-(void)setDelegate:(id<ZCUIManagerDelegate>)delegate{
    _delegate = delegate;
    _originalClass = object_getClass(delegate);
}

-(ZCLibServer *) getZCAPIServer{
    if(!_libServer){
        _libServer = [ZCLibServer getLibServer];
    }
    return _libServer;
}


-(void)destoryConfigManager{
    if(_kitInfo){
        _kitInfo  = nil;
    }
    
    if ([ZCIMChat getZCIMChat].messageArr) {
        [[ZCIMChat getZCIMChat].messageArr removeAllObjects];
    }
    
    [ZCLibClient getZCLibClient].libInitInfo.skillSetId = @"";
    [ZCLibClient getZCLibClient].libInitInfo.skillSetName = @"";
    
    // 退出SDK 或者 重新开始新会话 重新设置评价的参数
    [ZCStoreConfiguration setZCParamter:KEY_ZCISSENDTOUSER value:@""];
    [ZCStoreConfiguration setZCParamter:KEY_ZCISSENDTOROBOT value:@""];
    
    // 新会话之后可以重新评级
    [ZCStoreConfiguration setZCParamter:KEY_ZCISEVALUATIONROBOT value:@""];
    [ZCStoreConfiguration setZCParamter:KEY_ZCISEVALUATIONSERVICE value:@""];
    
    /** 定时器相关 */
    isAdminTipTime = YES;
 
    
    isUserTipTime  = NO;
    
    lowMinTime = 0;
    
    _libServer = nil;
    
    inputTextView = nil;
    
    [self cleanObjectMenorery];
}

/**
 *  @param type       是否是新会话  0 不是 ，1 是
 */
-(void)cleanObjectMenorery{
    if(tipTimer){
        [tipTimer invalidate];
    }
    
    if(_delegate){
        _delegate   = nil;
    }
    
    allFaceDict  = nil;
    [ZCStoreConfiguration setZCParamter:KEY_ZCISOFFLINE value:@"0"];
    [ZCStoreConfiguration setZCParamter:KEY_ZCISOFFLINEBEBLACK value:@"0"];
    [ZCStoreConfiguration setZCParamter:KEY_ZCISROBOTHELLO value:@"0"];
    
    // 清理本地存储文件
    dispatch_async(dispatch_queue_create("com.sobot.cache", DISPATCH_QUEUE_SERIAL), ^{
        NSFileManager *_fileManager = [NSFileManager new];
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:VoiceLocalPath];
        
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [VoiceLocalPath stringByAppendingPathComponent:fileName];
            // 未过期，添加到排序列表
            if(![ZCUITools videoIsValid:filePath]){
                // 过期，直接删除
                [_fileManager removeItemAtPath:filePath error:nil];
            }
        }
    });
    
}

#pragma mark 定时器相关
-(void)startTipTimer{
    if(tipTimer){
        [tipTimer invalidate];
        tipTimer = nil;
    }
    tipTimer       = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCount) userInfo:nil repeats:YES];
    
    // 定时器相关
    lowMinTime = 0;
//    isAdminTipTime = YES;
//    isUserTipTime  = NO;
    userTipTime = 0;
    adminTipTime = 0;
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
    if(tipTimer){
        if (tipTimer && ![tipTimer isValid]) {
            return ;
        }
        [tipTimer setFireDate:[NSDate distantFuture]];
    }
}

-(void)pauseToStartCount{
    if(tipTimer){
        if (tipTimer && ![tipTimer isValid]) {
            return ;
        }
        [tipTimer setFireDate:[NSDate date]];
    }
}

-(void)setInputListener:(UITextView *)textView{
    inputTextView = textView;
}


/**
 *  计数，计算提示信息
 */
-(void)timerCount{
//        [ZCLogUtils logHeader:LogHeader debug:@"isArtificial====%zd\n,isUserTipTime====%zd\n,userTipTime===%d\n",[self getZCLibConfig].isArtificial,isUserTipTime,userTipTime];
    
    ZCLibConfig *libConfig = [ZCIMChat getZCIMChat].libConfig;
    
    lowMinTime=lowMinTime+1;
    
    // 用户超时，此处不处理了，改由服务器判断
    
    // 用户长时间不说话,人工才添加提示语
    if(!isUserTipTime && libConfig.isArtificial){
        userTipTime=userTipTime+1;
        if(userTipTime>=libConfig.userTipTime*60){
            // 用户超时应答语
            if(_delegate && [_delegate respondsToSelector:@selector(onTimerListener:)]){
                [_delegate onTimerListener:NSTimerListenerTypeUserTimeOut];
            }
            userTipTime   = 0;
            isUserTipTime = YES;
        }
    }
    
    // 人工时才提醒，客服不说话
    if(!isAdminTipTime && libConfig.isArtificial){
        adminTipTime=adminTipTime+1;
        if(adminTipTime>libConfig.adminTipTime*60){
            @try {
                Class currentClass = object_getClass(self.delegate);
                if (currentClass == _originalClass && [_delegate respondsToSelector:@selector(onTimerListener:)]){
                    [_delegate onTimerListener:NSTimerListenerTypeAdminTimeOut];
                }
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
            
            adminTipTime   = 0;
            isAdminTipTime = YES;
           
        }
    }
    
    // 间隔指定时间，发送正在输入内容，并且是人工客服时
    if(inputTextView && libConfig.isArtificial){
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
                // 正在输入
                __weak ZCUIConfigManager *configManager = self;
                [[configManager getZCAPIServer]
                 sendInputContent:libConfig
                 content:lastMessage
                 success:^(ZCNetWorkCode sendCode) {
                     isSendInput = NO;
                 } failed:^(NSString *errorMessage, ZCNetWorkCode errorCode) {
                     isSendInput = NO;
                 }];
            }
        }
    }
}


-(NSDictionary *)allExpressionDict{
    if(allFaceDict==nil || allFaceDict.allKeys.count == 0){
        NSArray *faceArr = [ZCUITools allExpressionArray];
        if(faceArr && faceArr.count > 0){
            allFaceDict = [NSMutableDictionary dictionary];
            for (NSDictionary *item in faceArr) {
                [allFaceDict setObject:item[@"VALUE"] forKey:item[@"KEY"]];
            }
        }
    }
    return allFaceDict;
}




@end
