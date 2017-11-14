//
//  ZCVoiceChatCell.m
//  
//
//  Created by 张新耀 on 15/10/10.
//
//

#import "ZCVoiceChatCell.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIImageTools.h"
@interface ZCVoiceChatCell()

@end


@implementation ZCVoiceChatCell{
    UIColor     *ivBgColor;
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _voiceButton =[ZCButton buttonWithType:UIButtonTypeCustom];
        _voiceButton.type = 1;
        [_voiceButton setBackgroundColor:[UIColor clearColor]];
        [_voiceButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_voiceButton.titleLabel setFont:[ZCUITools zcgetListKitDetailFont]];
        [self.contentView addSubview:_voiceButton];
        _voiceButton.imageView.animationDuration = .8f;
        _voiceButton.imageView.animationRepeatCount = 0;
        [_voiceButton addTarget:self action:@selector(playVoice:) forControlEvents:UIControlEventTouchUpInside];
        [_voiceButton setBackgroundImage:[ZCUIImageTools zcimageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        _voiceButton.userInteractionEnabled=YES;
        [_voiceButton addTarget:self action:@selector(bgColorChangeAction:) forControlEvents:UIControlEventTouchDown];
        
        
        _translationLabel = [[UILabel alloc] init];
        _translationLabel.font = [ZCUITools zcgetKitChatFont];
        _translationLabel.textColor = [ZCUITools zcgetRightChatColor];
        _translationLabel.numberOfLines = 0;
        [self.contentView addSubview:_translationLabel];
        _translationLabel.hidden = YES;
        
    }
    return self;
}


-(CGFloat) InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    CGFloat height=[super InitDataToView:model time:showTime];

    ivBgColor            = self.ivBgView.backgroundColor;

    self.ivBgView.hidden = NO;
    
    
    
    [_voiceButton setBackgroundColor:[UIColor clearColor]];
    
    if([@"" isEqual:zcLibConvertToString(model.richModel.msgtranslation)]){
        _voiceButton.hidden  = NO;
        _translationLabel.hidden = YES;
        
        // 0,自己，1机器人，2客服
        if(self.isRight){
            [self.ivBgView setFrame:CGRectMake(self.viewWidth-60-10-50, height, 60,40)];
            [_voiceButton setFrame:CGRectMake(self.viewWidth-60-5 -50, height+7.5,45, 25)];
            [_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@"ZCPop_voice_send_normal"] forState:UIControlStateNormal];
            [_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@"ZCPop_voice_send_normal"] forState:UIControlStateHighlighted];
            [_voiceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_voiceButton setTitleColor:[ZCUITools zcgetRightChatTextColor] forState:UIControlStateNormal];
            
        }else{
            [_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@"ZCPop_voice_receive_normal"] forState:UIControlStateNormal];
            [_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@"ZCPop_voice_receive_normal"] forState:UIControlStateHighlighted];
            
            [self.ivBgView setFrame:CGRectMake(58, height, 80, 40)];
            [_voiceButton setFrame:CGRectMake(63, height+7.5, 60, 25)];
            [_voiceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_voiceButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            [_voiceButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
            
        }
        
        
        // 设置数据
        if(model.richModel.duration.length < 5 || model.richModel.duration.length>6){
            model.richModel.duration=@"00:00″";
        }
        NSString *timeStr = [NSString stringWithFormat:@"%@",model.richModel.duration];
        
    //    NSLog(@"当前记录的语音时间时长为%@",timeStr);
        if ([timeStr isEqualToString:@"01:00"]) {
            timeStr = @"00:59";
        }

        timeStr = [timeStr substringFromIndex:3];
        if (timeStr.length ==2 && [timeStr hasPrefix:@"0"]) {
           timeStr = [timeStr substringFromIndex:1];
            
        }
        timeStr = [timeStr stringByAppendingString:@"″"];
        [_voiceButton setTitle:timeStr forState:UIControlStateNormal];
        // 左边客服不发送语音暂不显示
        if (self.isRight) {
            CGFloat cellWidth =  (self.viewWidth - 100 - 60)/60 * [timeStr intValue];
            CGRect btnFrame = _voiceButton.frame;
            CGRect bgFrame = self.ivBgView.frame;
            if (cellWidth > 1){
                btnFrame.size.width = btnFrame.size.width + cellWidth;
                btnFrame.origin.x =  btnFrame.origin.x - cellWidth;
                bgFrame.origin.x = bgFrame.origin.x - cellWidth;
                bgFrame.size.width = bgFrame.size.width + cellWidth;
                self.ivBgView.frame = bgFrame;
                _voiceButton.frame = btnFrame;
            }
        }
        
        
        if(model.isPlaying){
            
            [self setAnimationImages:_voiceButton];
            [_voiceButton.imageView startAnimating];
        }
        
        if ([timeStr isEqualToString:@"00″″"]) {
            // 隐藏
            [_voiceButton setTitle:@"" forState:UIControlStateNormal];
            // 显示
            [self.ivBgView.layer addAnimation:[self AlphaLight:1.5] forKey:@"aAlpha"];
            [_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@""] forState:UIControlStateNormal];
            [_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@""] forState:UIControlStateHighlighted];
            _voiceButton.userInteractionEnabled = NO;
        }else{
            
            if (model.senderType == 0) {
                if (model.sendStatus == 0) {
                    [_voiceButton setTitle:timeStr forState:UIControlStateNormal];
                }else if (model.sendStatus == 1){
                    [_voiceButton setTitle:@"" forState:UIControlStateNormal];
                }else if (model.sendStatus == 2){
                    [_voiceButton setTitle:@"" forState:UIControlStateNormal];
                }
            }
            
            [self.ivBgView.layer removeAnimationForKey:@"aAlpha"];
            [_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@"ZCPop_voice_send_normal"] forState:UIControlStateNormal];
            [_voiceButton setImage:[ZCUITools zcuiGetBundleImage:@"ZCPop_voice_send_normal"] forState:UIControlStateHighlighted];
            _voiceButton.userInteractionEnabled = YES;
        }
        
        height=height+50 ;
    }else{
        _voiceButton.hidden = YES;
        _translationLabel.text = zcLibConvertToString(model.richModel.msgtranslation);
        _translationLabel.hidden = NO;
        
        CGSize size = [_translationLabel.text boundingRectWithSize:CGSizeMake(self.maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_translationLabel.font} context:nil].size;
        CGFloat msgX = 0;
        // 0,自己，1机器人，2客服
        if(self.isRight){
            [_translationLabel setTextColor:[ZCUITools zcgetRightChatTextColor]];
            int rx=self.viewWidth-size.width-30 - 50;
            msgX = rx;
            [_translationLabel setFrame:CGRectMake(msgX, height + 12, size.width, size.height)];
            [self.ivBgView setFrame:CGRectMake(rx-8, height, size.width+28, size.height + 24)];
        }else{
            [_translationLabel setTextColor:[ZCUITools zcgetLeftChatTextColor]];
            msgX = 78;
            [_translationLabel setFrame:CGRectMake(msgX, height + 12, size.width, size.height)];
            [self.ivBgView setFrame:CGRectMake(58, height, size.width+33, size.height + 24)];
        }
        height=size.height+34 ;
    }
    
    [self setSendStatus:self.ivBgView.frame];
    
    // 设置尖角
    [self.ivLayerView setFrame:self.ivBgView.frame];
    CALayer *layer              = self.ivLayerView.layer;
    layer.frame                 = (CGRect){{0,0},self.ivLayerView.layer.frame.size};
    self.ivBgView.layer.mask = layer;
    
    
    [self.ivBgView setNeedsDisplay];
   
    
    [self setFrame:CGRectMake(0, 0, self.viewWidth, height)];
    
    return height;
}


-(void)setAnimationImages:(UIButton *)sender{
    if(self.isRight){
        [sender.imageView setAnimationImages:[NSArray arrayWithObjects:
                                              [ZCUITools zcuiGetBundleImage:@"ZCPop_voice_send_anime_1"],
                                              [ZCUITools zcuiGetBundleImage:@"ZCPop_voice_send_anime_2"],
                                              [ZCUITools zcuiGetBundleImage:@"ZCPop_voice_send_anime_3"],
                                              [ZCUITools zcuiGetBundleImage:@"ZCPop_voice_send_anime_4"],
                                              [ZCUITools zcuiGetBundleImage:@"ZCPop_voice_send_anime_5"], nil]];
        
    }else{
        [sender.imageView setAnimationImages:[NSArray arrayWithObjects:
                                              [ZCUITools zcuiGetBundleImage:@"ZCPop_voice_receive_anime_1"],
                                              [ZCUITools zcuiGetBundleImage:@"ZCPop_voice_receive_anime_2"],
                                              [ZCUITools zcuiGetBundleImage:@"ZCPop_voice_receive_anime_3"],
                                              [ZCUITools zcuiGetBundleImage:@"ZCPop_voice_receive_anime_4"],
                                              [ZCUITools zcuiGetBundleImage:@"ZCPop_voice_receive_anime_5"], nil]];
    }
}

// 点击播放声音
-(void)playVoice:(UIButton *) sender{
    [self.ivBgView setBackgroundColor:[ZCUITools zcgetRightChatColor]];
    [self.ivBgView setNeedsDisplay];
    // 不是自己发送的，显示的是未读状态
    if(!self.btnReSend.hidden && !self.isRight){
        self.btnReSend.hidden=YES;
        if(self.tempModel){
            self.tempModel.isRead=YES;
        }
    }
    if(self.tempModel && self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
        [self setAnimationImages:sender];
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypePlayVoice obj:sender.imageView];
    }
}


- (void)bgColorChangeAction:(UIButton*)sender{

    [self.ivBgView setBackgroundColor:[ZCUITools zcgetChatRightVideoSelBgColor]];

    [self.ivBgView setNeedsDisplay];
    
}


// 长按选择听筒模式,未使用
-(void)playAction:(id)sender{
    // 不是自己发送的，显示的是未读状态
    if(!self.btnReSend.hidden && !self.isRight){
        self.btnReSend.hidden=YES;
        if(self.tempModel){
            self.tempModel.isRead=YES;
        }
    }
    
    if(self.tempModel && self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
        [self setAnimationImages:sender];
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeReceiverPlayVoice obj:_voiceButton.imageView];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat)width{
    CGFloat height=[super getCellHeight:model time:showTime viewWith:width];
   
    if(![@"" isEqual:zcLibConvertToString(model.richModel.msgtranslation)]){
        CGSize size = [model.richModel.msgtranslation boundingRectWithSize:CGSizeMake(width - 160, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[ZCUITools zcgetKitChatFont]} context:nil].size;
        height = height + size.height + 34;
        
    }else{
        height = height + 50;
    }
    return height;
}


//- (void)resetCellView{
//    [super resetCellView];
//    self.timeBtn.hidden = YES;
//}






#pragma mark -- cell的呼吸动画
- (CABasicAnimation*)AlphaLight:(float)time{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:0.9f];
    animation.toValue = [NSNumber numberWithFloat:0.3f];
    animation.autoreverses = YES;
    animation.duration = time;
    animation.repeatCount = 59;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    return animation;
}


@end
