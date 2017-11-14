//
//  ZCChatBaseCell.m
//  SobotApp
//
//  Created by 张新耀 on 15/9/15.
//  Copyright (c) 2015年 com.sobot.chat. All rights reserved.
//

#import "ZCChatBaseCell.h"
#import "ZCLibCommon.h"
#import "ZCUITools.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIXHImageViewer.h"
#import "ZCIMChat.h"
#import "ZCStoreConfiguration.h"
#import "ZCLibClient.h"


@implementation ZCChatBaseCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _lblTime=[[UILabel alloc] init];
        [_lblTime setTextAlignment:NSTextAlignmentCenter];
        [_lblTime setFont:[ZCUITools zcgetListKitTimeFont]];
        [_lblTime setTextColor:[ZCUITools zcgetTimeTextColor]];
        [_lblTime setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_lblTime];
        _lblTime.hidden=YES;
        
        
        _lblNickName =[[UILabel alloc] init];
        [_lblNickName setBackgroundColor:[UIColor clearColor]];
        [_lblNickName setTextAlignment:NSTextAlignmentLeft];
        [_lblNickName setFont:[ZCUITools zcgetListKitDetailFont]];
        [_lblNickName setTextColor:[ZCUITools zcgetServiceNameTextColor]];
        [_lblNickName setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_lblNickName];
        _lblNickName.hidden=YES;
        
        _ivHeader = [[ZCUIImageView alloc] init];
        [_ivHeader setContentMode:UIViewContentModeScaleAspectFit];
        [_ivHeader.layer setMasksToBounds:YES];
        [_ivHeader setBackgroundColor:[UIColor clearColor]];
        _ivHeader.layer.cornerRadius=4.0f;
        _ivHeader.layer.masksToBounds=YES;
        _ivHeader.layer.borderWidth = 0.5f;
        _ivHeader.layer.borderColor = [ZCUITools zcgetBackgroundColor].CGColor;
        [self.contentView addSubview:_ivHeader];
        

        _ivBgView = [[UIImageView alloc] init];
        [_ivBgView setContentMode:UIViewContentModeScaleAspectFit];
        [_ivBgView.layer setMasksToBounds:YES];
        [_ivBgView setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_ivBgView];
        
        
        _btnReSend =[UIButton buttonWithType:UIButtonTypeCustom];
        [_btnReSend setBackgroundColor:[UIColor clearColor]];
        _btnReSend.layer.cornerRadius=3;
        _btnReSend.layer.masksToBounds=YES;
        [self.contentView addSubview:_btnReSend];
        _btnReSend.hidden=YES;
        
        
        _btnTurnUser =[UIButton buttonWithType:UIButtonTypeCustom];
        [_btnTurnUser setBackgroundColor:[UIColor clearColor]];
        [_btnTurnUser setTitle:@"转人工" forState:UIControlStateNormal];
        _btnTurnUser.tag = ZCChatCellClickTypeConnectUser;
        [_btnTurnUser setTitleColor:[ZCUITools zcgetDynamicColor] forState:UIControlStateNormal];
        _btnTurnUser.layer.borderColor = [ZCUITools zcgetDynamicColor].CGColor;
        _btnTurnUser.layer.borderWidth = 0.75f;
        _btnTurnUser.layer.cornerRadius = 3.0f;
        _btnTurnUser.layer.masksToBounds = YES;
        [_btnTurnUser.titleLabel setFont:[ZCUITools zcgetKitChatFont]];
        [_btnTurnUser addTarget:self action:@selector(connectWithStepOnWithTheTop:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_btnTurnUser];
        _btnTurnUser.hidden=YES;
        
        
        _btnStepOn =[UIButton buttonWithType:UIButtonTypeCustom];
        [_btnStepOn setBackgroundColor:[UIColor clearColor]];
        _btnStepOn.layer.cornerRadius=3;
        _btnStepOn.layer.masksToBounds=YES;
//        [_btnStepOn setTitle:@"" forState:UIControlStateNormal];
        _btnStepOn.tag = ZCChatCellClickTypeStepOn;
        [_btnStepOn setContentMode:UIViewContentModeRight];
        [_btnStepOn setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_nonsupport_icon"] forState:UIControlStateNormal];
        [_btnStepOn addTarget:self action:@selector(connectWithStepOnWithTheTop:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_btnStepOn];
        _btnStepOn.hidden=YES;
        
        _btnTheTop =[UIButton buttonWithType:UIButtonTypeCustom];
        [_btnTheTop setBackgroundColor:[UIColor clearColor]];
        [_btnTheTop setContentMode:UIViewContentModeRight];
        _btnTheTop.layer.cornerRadius=3;
        _btnTheTop.layer.masksToBounds=YES;
        [_btnTheTop setImage:[ZCUITools zcuiGetBundleImage:@"zcicon_zan_icon"] forState:UIControlStateNormal];
//        [_btnTheTop setTitle:@"" forState:UIControlStateNormal];
        _btnTheTop.tag = ZCChatCellClickTypeTheTop;
        [_btnTheTop addTarget:self action:@selector(connectWithStepOnWithTheTop:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_btnTheTop];
        _btnTheTop.hidden=YES;
        
        
        _lblRobotCommentResult =[[UILabel alloc] init];
        [_lblRobotCommentResult setBackgroundColor:[UIColor clearColor]];
        [_lblRobotCommentResult setTextAlignment:NSTextAlignmentLeft];
        [_lblRobotCommentResult setFont:[ZCUITools zcgetListKitDetailFont]];
        [_lblRobotCommentResult setTextColor:[ZCUITools zcgetTimeTextColor]];
        [_lblRobotCommentResult setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_lblRobotCommentResult];
        _lblRobotCommentResult.hidden=YES;
        
        
        
        _activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityView.hidden=YES;
        [_btnReSend addSubview:_activityView];
        
        
        _ivLayerView = [[UIImageView alloc] init];
        
        self.userInteractionEnabled=YES;
    }
    return self;
}



-(CGFloat)InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    self.maxWidth=self.viewWidth-160;
    
    CGFloat cellHeight=0;
    
    [self resetCellView];
    
    _tempModel=model;
    if(![@"" isEqual:zcLibConvertToString(showTime)]){
        [_lblTime setText:showTime];
//        [_lblTime setFrame:CGRectMake(0, 0, self.viewWidth, 30)];
        _lblTime.hidden=NO;
        
        if (showTime.length < 6) {
            [self.lblTime setFrame:CGRectMake((self.viewWidth - 53)/2, 10, 53, 20)];
            self.lblTime.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
            self.lblTime.layer.cornerRadius = 10.0f;
            self.lblTime.layer.masksToBounds = YES;
        }else{
            [self.lblTime setFrame:CGRectMake((self.viewWidth - 90)/2, 10, 90, 20)];
            self.lblTime.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
            self.lblTime.layer.cornerRadius = 10.0f;
            self.lblTime.layer.masksToBounds = YES;
        }
        cellHeight = 30 ;
    }
    
    cellHeight=cellHeight+10;
    
    _lblNickName.hidden=NO;
    _ivHeader.hidden=NO;
    
    UIImage *bgImage = [ZCUITools zcuiGetBundleImage:@"ZCPop_green_left_normal"];
    
    // 0,自己，1机器人，2客服
    if(model.senderType==0){
        _isRight = YES;
        [_lblNickName setFrame:CGRectZero];
        
        //  nickName 用户的昵称 对应传给后台的字段为“uname”
        if (![@"" isEqual:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.nickName)]) {
            
            [_lblNickName setFrame:CGRectMake(10, cellHeight, self.viewWidth - 77, 16)];
        }else{
            [_lblNickName setText:@""];
            [_lblNickName setFrame:CGRectMake(10, cellHeight, self.viewWidth -77, 0)];
        }
        [_ivHeader setFrame:CGRectMake(self.viewWidth - 50, cellHeight, 40, 40)];
        
        _lblNickName.textAlignment = NSTextAlignmentRight;
        if (![@"" isEqual:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.nickName)]) {
            // 设置内容的Y坐标
            cellHeight=cellHeight+20;
        }
        
        
        // 用户的昵称长度为14个字后面拼接“...”
        if ([ZCLibClient getZCLibClient].libInitInfo.nickName.length >14) {
            NSString * nickSub = [[ZCLibClient getZCLibClient].libInitInfo.nickName substringToIndex:14];
            NSString * nickStr = [nickSub stringByAppendingString:@"..."];
            [_lblNickName setText:nickStr];
        }else{
            [_lblNickName setText:[NSString stringWithFormat:@"%@",[ZCLibClient getZCLibClient].libInitInfo.nickName]];
        }
       
        // 设置用户的头像 (这里的头像取 用户自定义的不用重服务器拉取)
        [_ivHeader loadWithURL:[NSURL URLWithString:zcUrlEncodedString([ZCLibClient getZCLibClient].libInitInfo.avatarUrl)] placeholer:[ZCUITools zcuiGetBundleImage:@"ZCIcon_UserAvatar_nol"] showActivityIndicatorView:NO];
        
        
        // 右边气泡背景图片
        bgImage = [ZCUITools zcuiGetBundleImage:@"ZCPop_green_normal"];
        bgImage=[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(30, 5, 5, 15)];
        // 右边气泡绿色
        [_ivBgView setBackgroundColor:[ZCUITools zcgetRightChatColor]];
        
    }else{
        _isRight = NO;
        
        [_ivHeader setFrame:CGRectMake(10, cellHeight, 40, 40)];
        [_lblNickName setFrame:CGRectMake(67, cellHeight, self.viewWidth-77, 16)];
        
        // 设置内容的Y坐标
        cellHeight=cellHeight+20;
        
        if(model.senderType==1){
            
            // 机器人
            // 昵称长度为14个字后面拼接“...”
            if (model.senderName.length >14) {
                NSString * nickSub = [model.senderName substringToIndex:14];
                NSString * nickStr = [nickSub stringByAppendingString:@"..."];
                [_lblNickName setText:nickStr];
            }else{
                [_lblNickName setText:[NSString stringWithFormat:@"%@",model.senderName]];
            }
            [_ivHeader loadWithURL:[NSURL URLWithString:zcUrlEncodedString(model.senderFace)] placeholer:[ZCUITools zcuiGetBundleImage:@"avatar_robot"] showActivityIndicatorView:NO];
        }else{
            // 客服
            if([@"" isEqual:zcLibConvertToString(model.senderName)]){
                model.senderName = [ZCIMChat getZCIMChat].libConfig.companyName;
            }
            if (model.senderName.length >14) {
                NSString * nickSub = [model.senderName substringToIndex:14];
                NSString * nickStr = [nickSub stringByAppendingString:@"..."];
                [_lblNickName setText:nickStr];
            }else{
               [_lblNickName setText:[NSString stringWithFormat:@"%@",model.senderName]];
            }
            // 设置客服的头像
            if ([@"" isEqual:zcLibConvertToString(model.senderFace)]) {
                model.senderFace = [ZCIMChat getZCIMChat].libConfig.senderFace;
            }
            [_ivHeader loadWithURL:[NSURL URLWithString:zcUrlEncodedString(model.senderFace)] placeholer:[ZCUITools zcuiGetBundleImage:@"avatar_customerservice"] showActivityIndicatorView:NO];
        }
        
        _lblNickName.textAlignment = NSTextAlignmentLeft;
        bgImage=[bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(30, 15, 5, 5)];
        
        [_ivBgView setBackgroundColor:[ZCUITools zcgetLeftChatColor]];
    }
    //设置尖角
    [_ivLayerView setImage:bgImage];
    
    return cellHeight;
}

-(CGFloat)setSendStatus:(CGRect )backgroundF{
    // 自己、设置发送状态
    if(_tempModel.senderType==0){
        if(_tempModel.sendStatus==0){
            self.btnReSend.hidden=YES;
        }else if(_tempModel.sendStatus==1){
            if(_tempModel.richModel.msgType == 1){
                // 发送图片时，不显示发送的动画，由发送进度代替
                [self.btnReSend setHidden:YES];
                return 0;
            }
            [self.btnReSend setHidden:NO];
            [self.btnReSend setBackgroundColor:[UIColor clearColor]];
            [self.btnReSend setImage:nil forState:UIControlStateNormal];
            [self.btnReSend setFrame:CGRectMake(backgroundF.origin.x-34, backgroundF.origin.y+8, 24, 24)];
            
            self.activityView.hidden=NO;
            _activityView.center=CGPointMake(12, 12);
            [_activityView startAnimating];
        }else if(_tempModel.sendStatus==2){
            [self.btnReSend setHidden:NO];
            [self.btnReSend setBackgroundColor:[UIColor clearColor]];
            [self.btnReSend setImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_send_fail"] forState:UIControlStateNormal];
            [self.btnReSend setFrame:CGRectMake(backgroundF.origin.x-34, backgroundF.origin.y+8, 24, 24)];
            [self.btnReSend addTarget:self action:@selector(clickReSend:) forControlEvents:UIControlEventTouchUpInside];
            
            _activityView.hidden=YES;
            [_activityView stopAnimating];
        }
    }else{
        // 设置未读状态
        if(_tempModel.isRead){
            [self.btnReSend setHidden:NO];
            [self.btnReSend setImage:nil forState:UIControlStateNormal];
            
            [self.btnReSend setFrame:CGRectMake(backgroundF.origin.x+backgroundF.size.width+10, backgroundF.origin.y+10, 6, 6)];
        }
    }
    
    
    self.btnTurnUser.hidden = YES;
    self.btnStepOn.hidden = YES;
    self.btnTheTop.hidden = YES;
    self.lblRobotCommentResult.hidden = YES;
    CGFloat showheight = 0;
    
    // 机器人回复，判断是否显示“顶、踩、转人工”
    if(_tempModel.senderType == 1){
        if([ZCIMChat getZCIMChat].libConfig.isArtificial){
            self.tempModel.showTurnUser = NO;
        }
        
        if(_tempModel.showTurnUser && ![ZCIMChat getZCIMChat].libConfig.isArtificial && [ZCLibClient getZCLibClient].libInitInfo.serviceMode!=1){
        
            [self.btnTurnUser setFrame:CGRectMake(backgroundF.origin.x + 10,  backgroundF.origin.y + backgroundF.size.height+15, 69, 24)];
            self.btnTurnUser.hidden = NO;
            
            showheight = 40.0f;
        }
        
        if(self.tempModel.commentType > 0){
            if(self.tempModel.commentType == 1){
                self.btnTheTop.hidden = NO;
                self.btnStepOn.hidden = NO;
                [self.btnTheTop setFrame:CGRectMake(backgroundF.origin.x + 10,  backgroundF.origin.y + backgroundF.size.height + 15, 30, 24)];
                [self.btnStepOn setFrame:CGRectMake(CGRectGetMaxX(self.btnTheTop.frame)+15,  backgroundF.origin.y + backgroundF.size.height + 15, 30, 24)];
                
                if (!self.btnTurnUser.hidden) {
                    [self.btnTheTop setFrame:CGRectMake(CGRectGetMaxX(self.btnTurnUser.frame) + 15,  backgroundF.origin.y + backgroundF.size.height + 15, 30, 24)];
                    [self.btnStepOn setFrame:CGRectMake(CGRectGetMaxX(self.btnTheTop.frame)+15,  backgroundF.origin.y + backgroundF.size.height + 15, 30, 24)];
                }
            }else{
                _lblRobotCommentResult.hidden = NO;
                if (!self.btnTurnUser.hidden) {
                   [_lblRobotCommentResult setFrame:CGRectMake(CGRectGetMaxX(self.btnTurnUser.frame) +15,  backgroundF.origin.y + backgroundF.size.height + 10, backgroundF.size.width, 30)];
                }else{
                     [_lblRobotCommentResult setFrame:CGRectMake( backgroundF.origin.x,  backgroundF.origin.y + backgroundF.size.height + 10, backgroundF.size.width, 30)];
                }
                
               
                if(self.tempModel.commentType == 2){
                    [_lblRobotCommentResult setText:ZCSTLocalString(@"感谢您的反馈")];
                }else{
                    [_lblRobotCommentResult setText:ZCSTLocalString(@"很抱歉没能帮到您")];
                }
            }
            
            showheight = 40.0f;
        }
    }
    return showheight;
}


-(void)headerClick:(UITapGestureRecognizer *)gesture{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeHeader obj:nil];
    }
}

-(void)connectWithStepOnWithTheTop:(UIButton *) btn{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
        [self.delegate cellItemClick:self.tempModel type:btn.tag obj:nil];
    }

}


-(CGFloat) getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime{
    return 0;
}


// 重新发送
-(IBAction)clickReSend:(UIButton *)sender{
    //初始化AlertView
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:ZCSTLocalString(@"重新发送")
                                                   delegate:self
                                          cancelButtonTitle:ZCSTLocalString(@"取消")
                                          otherButtonTitles:ZCSTLocalString(@"发送"),nil];
    alert.tag=2;
    [alert show];
    
}


// 提示层回调
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==1){
        if(buttonIndex==1){
            // 打电话
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_callURL]];
        }
    } else if(alertView.tag==2){
        if(buttonIndex == 1){
            if(_delegate && [_delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                [_delegate cellItemClick:_tempModel type:ZCChatCellClickTypeReSend obj:nil];
            }
        }
        
    }
}


-(void)resetCellView{
    _lblTime.hidden=YES;
    [_lblTime setText:@""];
    
    _activityView.hidden=YES;
    
    _btnReSend.hidden=YES;
    
    [_activityView stopAnimating];
    [_activityView setHidden:YES];
    
    _ivBgView.hidden=NO;
    [_ivBgView.layer.mask removeFromSuperlayer];
  
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat )viewWidth{
    CGFloat cellheight = 0;
    if(![@"" isEqual:zcLibConvertToString(showTime)]){
        cellheight = 30;
    }
    cellheight=cellheight+10;
    
    // 0,自己，1机器人，2客服
    if(model.senderType!=0){
        cellheight = cellheight + 20;
    }
    
    if (model.senderType ==0 ) {
        if (![@"" isEqual:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.nickName)]) {
            // 设置内容的Y坐标
            cellheight=cellheight+20;
        }
    }
    
    cellheight = cellheight + [self getStatusHeight:model];
    
    return cellheight;

}


+(CGFloat )getStatusHeight:(ZCLibMessage *) messageModel{
    CGFloat showheight = 0;
    // 机器人回复，判断是否显示“顶、踩、转人工”
    if(messageModel.senderType == 1){
        if(messageModel.showTurnUser){
            showheight = 40.0f;
        }
        
        if(messageModel.commentType > 0){
            showheight = 40.0f;
        }
    }
    return showheight;
}


@end
