//
//  ZCImageChatCell.h
//  SobotApp
//
//  Created by 张新耀 on 15/9/16.
//  Copyright (c) 2015年 com.sobot.chat. All rights reserved.
//

#import "ZCChatBaseCell.h"
#import "ZCUIImageView.h"

/**
 *  聊天信息类型为单个图片的cell
 */
@interface ZCImageChatCell : ZCChatBaseCell

/**
 *  单个图片
 */
@property (nonatomic,strong) ZCUIImageView             *ivSingleImage;

@end
