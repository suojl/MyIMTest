//
//  ZCVoiceChatCell.h
//  
//
//  Created by 张新耀 on 15/10/10.
//
//

#import "ZCChatBaseCell.h"

#import "ZCButton.h"

/**
 *  声音处理 Cell
 *  用户使用sdk，可以发送语音
 */
@interface ZCVoiceChatCell : ZCChatBaseCell

@property(nonatomic,strong) ZCButton *voiceButton;
@property(nonatomic,strong) UILabel  *translationLabel;


@end
