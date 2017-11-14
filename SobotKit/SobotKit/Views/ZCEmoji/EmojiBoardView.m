//
//  EmojiBoardView.m
//  SobotApp
//
//  Created by 张新耀 on 15/9/15.
//  Copyright (c) 2015年 com.sobot.chat. All rights reserved.
//

#import "EmojiBoardView.h"
#import "ZCUIColorsDefine.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUITools.h"
#import "ZCUIImageTools.h"
@interface EmojiBoardView()
{
    CGFloat h;
    CGFloat w;
}
@end

@implementation EmojiBoardView



-(id)initWithBoardHeight:(CGFloat ) height pH:(CGFloat) ph pW:(CGFloat) pw{
    
    h = ph;
    w = pw;
    self = [super initWithFrame:CGRectMake(0, h, w, height)];
    if (self) {
        self.userInteractionEnabled=YES;
        
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
        [self setAutoresizesSubviews:YES];
        
        CGFloat width = w;
        
        self.backgroundColor = UIColorFromRGB(BgTextColor);
        
        _faceMap = [ZCUITools allExpressionArray];
        if(_faceMap==nil){
            _faceMap = @[];
        }
        
        //表情盘
        faceView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, width, height-20)];
        faceView.pagingEnabled = YES;
        faceView.showsHorizontalScrollIndicator = NO;
        faceView.showsVerticalScrollIndicator = NO;
        [faceView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
        [faceView setAutoresizesSubviews:YES];
        faceView.delegate = self;
        //添加键盘View
        [self addSubview:faceView];
    
        
        //添加PageControl
        facePageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(width/2-50, height-30, 100, 20)];
        [facePageControl setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
        [facePageControl setAutoresizesSubviews:YES];
        
        [facePageControl addTarget:self
                            action:@selector(pageChange:)
                  forControlEvents:UIControlEventValueChanged];
        facePageControl.pageIndicatorTintColor=[UIColor lightGrayColor];
        facePageControl.currentPageIndicatorTintColor=[UIColor darkGrayColor];
        facePageControl.currentPage = 0;
        [self addSubview:facePageControl];
        
        
//        UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [sendButton setBackgroundColor:UIColorFromRGB(BgSystemColor)];
//        [sendButton.layer setCornerRadius:3.0f];
//        [sendButton.layer setMasksToBounds:YES];
//        [sendButton setTitle:@"发送" forState:UIControlStateNormal];
//        [sendButton.titleLabel setFont:ListDetailFont];
//        [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [sendButton setFrame:CGRectMake(width-70, height-35, 50, 25)];
//        [sendButton addTarget:self action:@selector(sendEmoji) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:sendButton];
        
        [self addItemsView];
    }
    
    return self;
}

-(void)refreshItemsView{
    [self addItemsView];
}

-(void) addItemsView{
    for (UIView *item in faceView.subviews) {
        [item removeFromSuperview];
    }
    
    CGFloat width=w;
    CGFloat EmojiWidth  = 44;
    CGFloat EmojiHeight = 44;
    int columns         = width/EmojiWidth;
    // 当宽度无法除尽时，表情居中
    CGFloat itemX       = (width - columns * EmojiWidth)/2;
    
    int allSize         = (int)_faceMap.count;
    int rows            = (self.frame.size.height-20)/44;
    int pageSize        = rows * columns-2;
    int pageNum         = (allSize%pageSize==0) ? (allSize/pageSize) : (allSize/pageSize+1);
    
    faceView.contentSize = CGSizeMake(pageNum * width, 190);
    facePageControl.numberOfPages = pageNum;
    
    for(int i=0; i< pageNum; i++){
        //删除键
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setTitle:@"" forState:UIControlStateNormal];
        [back setImage:[ZCUITools zcuiGetBundleImage:@"ZCicon_emoji_del"] forState:UIControlStateNormal];
        [back setImage:[ZCUITools zcuiGetBundleImage:@"ZCicon_emoji_del_press"] forState:UIControlStateSelected];
        [back setImage:[ZCUITools zcuiGetBundleImage:@"ZCicon_emoji_del_press"] forState:UIControlStateHighlighted];
        [back setBackgroundColor:[UIColor clearColor]];
        //        [back setImage:[UIImage imageNamed:@"del_emoji_normal"] forState:UIControlStateNormal];
        //        [back setImage:[UIImage imageNamed:@"del_emoji_select"] forState:UIControlStateSelected];
        [back addTarget:self action:@selector(backFace) forControlEvents:UIControlEventTouchUpInside];
        back.frame = CGRectMake(itemX+i*width + (columns-2)*EmojiWidth, EmojiHeight * (rows-1)+8, EmojiWidth, EmojiHeight);
        [back setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
        [back.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [faceView addSubview:back];
        
        //发送键
        UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sendButton setTitle:ZCSTLocalString(@"发送") forState:UIControlStateNormal];
        [sendButton.titleLabel setFont:ListTimeFont];
        [sendButton.layer setCornerRadius:4.0f];
        [sendButton.layer setMasksToBounds:YES];
//        [sendButton setImage:[ZCUITools zcuiGetBundleImage:@"ZCicon_emoji_send"] forState:UIControlStateNormal];
//        [sendButton setImage:[ZCUITools zcuiGetBundleImage:@"ZCicon_emoji_send_press"] forState:UIControlStateSelected];
//        [sendButton setImage:[ZCUITools zcuiGetBundleImage:@"ZCicon_emoji_send_press"] forState:UIControlStateHighlighted];
//        [sendButton setBackgroundColor:[UIColor clearColor]];
        // 更改更随主题色
        [sendButton setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUITools zcgetDynamicColor]] forState:UIControlStateNormal];
        [sendButton setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUITools zcgetDynamicColor]] forState:UIControlStateHighlighted];
        [sendButton setTitleColor:[ZCUITools zcgetTopViewTextColor] forState:UIControlStateNormal];
        [sendButton setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
        //        [back setImage:[UIImage imageNamed:@"del_emoji_normal"] forState:UIControlStateNormal];
        //        [back setImage:[UIImage imageNamed:@"del_emoji_select"] forState:UIControlStateSelected];
        [sendButton addTarget:self action:@selector(sendEmoji) forControlEvents:UIControlEventTouchUpInside];
        [sendButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
        sendButton.frame = CGRectMake(itemX+i*width + (columns-1)*EmojiWidth+7, EmojiHeight * (rows-1)+8+10, 30, 24);
        [faceView addSubview:sendButton];
        
        for (int j=0; j<pageSize; j++) {
            NSDictionary *faceDict = [_faceMap objectAtIndex:i*pageSize+j];
            EmojiButton *faceButton = [EmojiButton buttonWithType:UIButtonTypeCustom];
            
            faceButton.buttonIndex = i*pageSize+j;
            faceButton.faceTag=faceDict[@"KEY"];
            faceButton.faceString=faceDict[@"KEY"];
//            [faceButton setTitle:faceKey forState:UIControlStateNormal];
//            [faceButton.titleLabel setFont:[UIFont fontWithName:@"AppleColorEmoji" size:29.0]];
            [faceButton setUserInteractionEnabled:YES];
            [faceButton addTarget:self
                           action:@selector(faceButton:)
                 forControlEvents:UIControlEventTouchUpInside];
            
            //计算每一个表情按钮的坐标和在哪一屏
            CGFloat x = i * width + (j%columns) * EmojiWidth+itemX;
            
            CGFloat y = 8;
            if(j>=columns){
                y = (j / columns) * EmojiHeight + 8;
            }
            faceButton.frame = CGRectMake( x, y, EmojiWidth, EmojiHeight);
            [faceButton setImageEdgeInsets:UIEdgeInsetsMake(7, 7, 7, 7)];
            [faceButton setImage:[ZCUITools zcuiGetExpressionBundleImage:[NSString stringWithFormat:@"%@.png",faceDict[@"VALUE"]]]
                        forState:UIControlStateNormal];
            [faceButton setBackgroundColor:[UIColor clearColor]];
            
            [faceView addSubview:faceButton];
            
            if((i*pageSize+j+1)>=allSize){
                break;
            }
        }
    }
}

//停止滚动的时候
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [facePageControl setCurrentPage:faceView.contentOffset.x / ScreenWidth];
    // 更新页码
    [facePageControl updateCurrentPageDisplay];
}

- (void)pageChange:(id)sender {
    
    [faceView setContentOffset:CGPointMake(facePageControl.currentPage * ScreenWidth, 0) animated:YES];
    [facePageControl setCurrentPage:facePageControl.currentPage];
}

- (void)faceButton:(id)sender {
    EmojiButton *btn = (EmojiButton*)sender;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(onEmojiItemClick:faceName:index:)]){
        [self.delegate onEmojiItemClick:btn.faceTag faceName:btn.faceString index:btn.buttonIndex];
    }
}

- (void)backFace{
    if(self.delegate && [self.delegate respondsToSelector:@selector(emojiAction:)]){
        [self.delegate emojiAction:EmojiActionDel];
    }
}

- (void)sendEmoji{
    if(self.delegate && [self.delegate respondsToSelector:@selector(emojiAction:)]){
        [self.delegate emojiAction:EmojiActionSend];
    }
}

@end
