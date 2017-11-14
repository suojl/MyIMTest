//
//  EmojiButton.h
//  SobotApp
//
//  Created by 张新耀 on 15/9/15.
//  Copyright (c) 2015年 com.sobot.chat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmojiButton : UIButton

@property NSInteger buttonIndex;
@property(nonatomic,retain) NSString * faceTag;
@property(nonatomic,retain) NSString * faceString;

@end
