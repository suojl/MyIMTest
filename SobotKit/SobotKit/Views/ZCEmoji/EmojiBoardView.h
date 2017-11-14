//
//  EmojiBoardView.h
//  SobotApp
//
//  Created by 张新耀 on 15/9/15.
//  Copyright (c) 2015年 com.sobot.chat. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EmojiButton.h"

/**
 *  EmojiBoardActionType ENUM
 */
typedef NS_ENUM(NSInteger,EmojiBoardActionType) {
    /** 删除 */
    EmojiActionDel=1,
    /** 发送 */
    EmojiActionSend=2,
};

@protocol EmojiBoardDelegate <NSObject>

@optional

-(void)onEmojiItemClick:(NSString *) faceTag faceName:(NSString *) name index:(NSInteger)itemId;

-(void)emojiAction:(EmojiBoardActionType) action;

@end


@interface EmojiBoardView : UIView<UIScrollViewDelegate>
{
    UIScrollView *faceView;
    
    UIPageControl *facePageControl;
    
    NSArray *_faceMap;
}


@property (nonatomic, assign) id<EmojiBoardDelegate> delegate;

-(id)initWithBoardHeight:(CGFloat ) height pH:(CGFloat) ph pW:(CGFloat) pw;


-(void) refreshItemsView;

@end
