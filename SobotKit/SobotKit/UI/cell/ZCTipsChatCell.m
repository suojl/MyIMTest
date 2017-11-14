//
//  ZCTipsChatCell.m
//  SobotApp
//
//  Created by 张新耀 on 15/10/15.
//  Copyright © 2015年 com.sobot.chat. All rights reserved.
//

#import "ZCTipsChatCell.h"

#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"

#import "ZCUIConfigManager.h"

#import "ZCMLEmojiLabel.h"
#import "ZCIMChat.h"

@interface ZCTipsChatCell()<ZCMLEmojiLabelDelegate>{
    
}

@end

@implementation ZCTipsChatCell{

    ZCMLEmojiLabel *_lblTextMsg;
    UIImageView     *_lineView;
    CGPoint centerX;

}


- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _lineView = [[UIImageView alloc] init];
        [_lineView setBackgroundColor:UIColorFromRGB(LineTextMenuColor)];
        [self.contentView insertSubview:_lineView belowSubview:self.ivBgView];
        _lineView.hidden = YES;
    }
    return self;
}



- (ZCMLEmojiLabel *)emojiLabel
{
    if (!_lblTextMsg) {
        _lblTextMsg = [ZCMLEmojiLabel new];
        _lblTextMsg.numberOfLines = 0;
        _lblTextMsg.font = [ZCUITools zcgetListKitDetailFont];
        _lblTextMsg.delegate = self;
        _lblTextMsg.lineBreakMode = NSLineBreakByTruncatingTail;
        _lblTextMsg.textColor = [UIColor whiteColor];
        _lblTextMsg.backgroundColor = [UIColor clearColor];
        
        //        _lblTextMsg.textInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        
        _lblTextMsg.isNeedAtAndPoundSign = NO;
        _lblTextMsg.disableEmoji = NO;
        _lblTextMsg.lineSpacing = 3.0f;
        _lblTextMsg.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
//        [_lblTextMsg setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
        [self.contentView addSubview:_lblTextMsg];
    }
    return _lblTextMsg;
}

-(CGFloat) InitDataToView:(ZCLibMessage *) model time:(NSString *) showTime{
    [self resetCellView];
    // 添加时间（触发新会话时）
    CGFloat timeHeight = 12 ;
    if(![@"" isEqual:zcLibConvertToString(showTime)]){
        [self.lblTime setText:showTime];
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
        self.lblTime.hidden=NO;
        timeHeight = 30;
    }
    
    // 调整提示cell的行间距
    CGFloat cellHeight = timeHeight;
    
    // 设置提示气泡的背景颜色
    if(model.tipStyle == 2){
        _lineView.hidden = NO;
        [self.emojiLabel setTextColor:[ZCUITools zcgetTimeTextColor]];
        [self.ivBgView setBackgroundColor:UIColorFromRGB(BgSystemColor)];
    }else{
        _lineView.hidden = YES;
        [self.emojiLabel setTextColor:[ZCUITools zcgetTipLayerTextColor]];
        [self.emojiLabel setTextColor:[ZCUITools zcgetTipLayerTextColor]];
        [self.ivBgView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
    }
    
    if(model){
        CGRect msgF = CGRectMake(0, cellHeight+5, self.viewWidth-40, 0);
        [_lblTextMsg setFrame:msgF];
        if(
           [model.sysTips hasSuffix:ZCSTLocalString(@"您已完成评价")] ||
           [model.sysTips hasSuffix:ZCSTLocalString(@"咨询后才能评价服务质量")] ||
           [model.sysTips hasPrefix:ZCSTLocalString(@"排队中，您在队伍中")]    ||
           [model.sysTips hasPrefix:ZCSTLocalString(@"您好,本次会话已结束")]){
            // 处理动画样式
            [self setTipCellAnimateTransformWith:model];
            
            
            // 留言标签的处理
            NSString *tempStr = model.sysTips;
            tempStr = [tempStr stringByReplacingOccurrencesOfString:@"[" withString:@""];
            tempStr = [tempStr stringByReplacingOccurrencesOfString:@"]" withString:@""];
            
            [_lblTextMsg setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
            _lblTextMsg.text = tempStr;
            if ([tempStr hasSuffix:ZCSTLocalString(@"留言")]) {
                [_lblTextMsg addLinkToURL:[NSURL URLWithString:ZCSTLocalString(@"留言")] withRange:NSMakeRange(tempStr.length-ZCSTLocalString(@"留言").length, ZCSTLocalString(@"留言").length)];
            }
            
        }else{
            [self HandleHTMLTagsWith:model];
        }
        
        CGSize optimalSize = [[self emojiLabel] preferredSizeWithMaxWidth:self.viewWidth - 40];
//        NSLog(@"一次计算文本的高度%f",optimalSize.height);
        msgF.size.height = optimalSize.height;
        msgF.size.width  = optimalSize.width;
        [_lblTextMsg setFrame:msgF];
        
        
        CGRect lf      = _lblTextMsg.frame;
        lf.origin.x    = self.viewWidth/2-lf.size.width/2;
        
        [_lblTextMsg setFrame:lf];
       
        lf.origin.x=lf.origin.x-7;
        lf.origin.y=lf.origin.y-5;
        lf.size.width=lf.size.width+14;
        lf.size.height=lf.size.height+10;
        [self.ivBgView setFrame:lf];
        
        if(model.tipStyle == 2){
            CGFloat x = self.viewWidth * 13/75;
            CGRect lineF = CGRectMake(x, 0, self.viewWidth-2*x, 0.75f);
            lineF.origin.y = lf.origin.y + (lf.size.height/2);
            [_lineView setFrame:lineF];
        }
        
        self.ivBgView.layer.cornerRadius=2.0f;
        self.ivBgView.layer.masksToBounds=YES;

        cellHeight=lf.size.height + lf.origin.y ;
//        NSLog(@"第一次计算之后的cell 搞%f",cellHeight);
        self.frame=CGRectMake(0, 0, self.viewWidth, cellHeight + 10 +3);
    
    }
    
//    NSLog(@"再加上15%f",cellHeight);
    return cellHeight +3;
}


- (void)setTipCellAnimateTransformWith:(ZCLibMessage *)model{
    //*2.0.0版本新加 新会话键盘样式出现时，未发送成功的消息不能在发送，提示离线或者会话结束。
    if ((model.tipStyle>0 && !model.isRead)|| ((model.tipStyle==2042 || model.tipStyle == 2044) && !model.isRead)){
        [UIView animateWithDuration:0.1 animations:^{
            
            self.ivBgView.layer.transform = CATransform3DMakeTranslation(-20, 0, 0);
            _lblTextMsg.layer.transform = CATransform3DMakeTranslation(-20, 0, 0);
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.1 animations:^{
                
                self.ivBgView.layer.transform = CATransform3DMakeTranslation(20, 0, 0);
                _lblTextMsg.layer.transform = CATransform3DMakeTranslation(20, 0, 0);
            } completion:^(BOOL finished) {
                model.isRead = YES;
                [UIView animateWithDuration:0.1 animations:^{
                    
                    self.ivBgView.layer.transform = CATransform3DMakeTranslation(-20, 0, 0);
                    _lblTextMsg.layer.transform = CATransform3DMakeTranslation(-20, 0, 0);
                } completion:nil];
            }];
            
        }];
        
        
    }

}


- (void)turnLeverMessageVC{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]) {
        [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeLeaveMessage obj:_lblTextMsg];
    }
}


-(void)resetCellView{
    [super resetCellView];
    
    [self emojiLabel].text = @"";
    [self.lblNickName setText:@""];
}




-(void)getSpecialRangeText:(NSString*)message arr:(NSMutableAttributedString *)attr
{
    NSRange range=[message rangeOfString:@"["];
    NSRange range1=[message rangeOfString:@"]"];
    
    NSUInteger len=0;
    //判断当前字符串是否还有表情的标志。
    if (range.length&&range1.length) {
        len=range1.location-(range.location+1);
        //        NSString *subString=[message substringWithRange:NSMakeRange(range.location+1, len)];
        
        //替换进行下一次查询
        message=[message stringByReplacingCharactersInRange:range1 withString:@""];
        message=[message stringByReplacingCharactersInRange:range withString:@""];
        
        //匹配一次正则，因为多了一个@字符
        range=NSMakeRange(range.location, len);
        [attr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(TextLinkColor) range:range];
        
        [self getSpecialRangeText:message arr:attr];
    }
}

#pragma mark EmojiLabel链接点击事件
// 链接点击
-(void)attributedLabel:(ZCTTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{

    
    if ([label.text hasSuffix:ZCSTLocalString(@"留言")] && (url.absoluteString.length ==0 || [ZCSTLocalString(@"留言") isEqual:url.absoluteString] )) {
        [self turnLeverMessageVC];
    }else{
         [self doClickURL:url.absoluteString text:@""];
    }
    
}

// 链接点击
-(void)ZCMLEmojiLabel:(ZCMLEmojiLabel *)emojiLabel didSelectLink:(NSString *)link withType:(ZCMLEmojiLabelLinkType)type{
    [self doClickURL:link text:@""];
}

// 链接点击
-(void)doClickURL:(NSString *)url text:(NSString * )htmlText{
    if(url){
        url=[url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        if([url hasPrefix:@"sobot:"]){
            int tag=[[url stringByReplacingOccurrencesOfString:@"sobot://" withString:@""] intValue];
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]){
                [self.delegate cellItemClick:self.tempModel type:ZCChatCellClickTypeItemChecked obj:[NSString stringWithFormat:@"%d",tag]];
            }
        }else{
            if(self.delegate && [self.delegate respondsToSelector:@selector(cellItemLinkClick:type:obj:)]){
                [self.delegate cellItemLinkClick:@"" type:ZCChatCellClickTypeOpenURL obj:url];
            }
        }
    }
}


#pragma mark - gesture delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return ![self.emojiLabel containslinkAtPoint:[touch locationInView:self.emojiLabel]];
}


-(ZCLibConfig *) getZCLibConfig{
    return [ZCIMChat getZCIMChat].libConfig;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(CGFloat) getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat)viewWidth{
    // 添加时间（触发新会话时）
    CGFloat timeHeight = 12 ;
    if(![@"" isEqual:zcLibConvertToString(showTime)]){
        timeHeight = 30;
    }
    
    if(model){
        timeHeight = timeHeight + 10;
        static ZCMLEmojiLabel *tempLabel = nil;
        if (!tempLabel) {
            tempLabel = [ZCMLEmojiLabel new];
            tempLabel.numberOfLines = 0;
            tempLabel.font = [ZCUITools zcgetListKitDetailFont];
            tempLabel.backgroundColor = [UIColor clearColor];
            tempLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            tempLabel.textColor = [UIColor whiteColor];
            tempLabel.isNeedAtAndPoundSign = YES;
            tempLabel.disableEmoji = NO;
            tempLabel.lineSpacing = 3.0f;
            tempLabel.verticalAlignment = ZCTTTAttributedLabelVerticalAlignmentCenter;
        }
        
        // 处理HTML标签
        NSString  *text = model.sysTips;
        
        //            NSLog(@"%@",model.sysTips);
        // 处理换行
        text = [text stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
        text = [text stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
        text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
        text = [text stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
        text = [text stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
        text = [text stringByReplacingOccurrencesOfString:@"<p " withString:@"\n<p "];
        text = [text stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
        while ([text hasPrefix:@"\n"]) {
            text=[text substringWithRange:NSMakeRange(1, text.length-1)];
        }

        if ([text hasPrefix:[NSString stringWithFormat:@"%@%@",ZCSTLocalString(@"您好，客服"),@"["]]) {
            // 留言标签的处理
            text = [text stringByReplacingOccurrencesOfString:@"[" withString:@""];
            text = [text stringByReplacingOccurrencesOfString:@"]" withString:@""];
        }
        
        tempLabel.text = text;
        
        CGSize optimalSize = [tempLabel preferredSizeWithMaxWidth:viewWidth - 40];
//        NSLog(@"计算后文本的高度%f",optimalSize.height);
        timeHeight = timeHeight + optimalSize.height + 10;
    }

    return timeHeight +3;
}


// 处理标签
- (void)HandleHTMLTagsWith:(ZCLibMessage *) model{
    NSString  *text = model.sysTips;
  
    // 处理换行
    text = [text stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
    text = [text stringByReplacingOccurrencesOfString:@"<p " withString:@"\n<p "];
    text = [text stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    while ([text hasPrefix:@"\n"]) {
        text=[text substringWithRange:NSMakeRange(1, text.length-1)];
    }
    
    
    // 正则的验证
    //            text = [ZCUITools zcAddTransformString:text];
    [_lblTextMsg setLinkColor:[ZCUITools zcgetChatLeftLinkColor]];
    NSMutableDictionary *dict = [_lblTextMsg getTextADict:text];
    if(dict){
        text = dict[@"text"];
    }
    
    _lblTextMsg.text = text;
    
    
    if (dict) {
        if ([model.sysTips hasPrefix:[self getZCLibConfig].adminNonelineTitle] || [model.sysTips hasSuffix:ZCSTLocalString(@"留言")]) {
           [self FilteringMessagesTagWith:text];
            
        }

        NSArray *arr =  dict[@"arr"];
        for (NSDictionary *item in arr) {
            NSString *text = item[@"htmlText"];
            int loc = [item[@"realFromIndex"] intValue];
            
            // 一定要在设置text文本之后设置
            [_lblTextMsg addLinkToURL:[NSURL URLWithString:item[@"url"]] withRange:NSMakeRange(loc, text.length)];
        }
        
    }else{
        if ([model.sysTips hasSuffix:ZCSTLocalString(@"留言")]) {
            
            [self FilteringMessagesTagWith:text];
            
        }

    }
    
    
    // 过滤客服昵称中的 “【 】”符号
    if ([text hasPrefix:[NSString  stringWithFormat:@"%@%@",ZCSTLocalString(@"您好，客服"),@"["]]) {
        NSRange range=[text rangeOfString:@"["];
        NSRange range1=[text rangeOfString:@"]"];
        NSUInteger len=0;
        if (range.location < range1.location) {
            len=range1.location+1 -(range.location+1);
        }
        
        // 留言标签的处理
        text = [text stringByReplacingOccurrencesOfString:@"[" withString:@""];
        text = [text stringByReplacingOccurrencesOfString:@"]" withString:@""];
        
        _lblTextMsg.text = text;
        
        NSRange range2 = NSMakeRange(range.location, len-1);
        
        [_lblTextMsg setLinkColor:[ZCUITools zcgetNickNameColor]];
        [_lblTextMsg addLinkToURL:[NSURL URLWithString:@"昵称"] withRange:range2];
    }
    
    if ([model.sysTips hasPrefix:zcLibConvertToString([self getZCLibConfig].userOutWord)] || [model.sysTips hasPrefix:zcLibConvertToString([self getZCLibConfig].adminNonelineTitle)]) {
        [self setTipCellAnimateTransformWith:model];
    }

}

// 留言标签的处理
- (void)FilteringMessagesTagWith:(NSString *)text{
    
    NSString *tempStr = text;
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"[" withString:@""];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"]" withString:@""];
    if ([tempStr hasSuffix:ZCSTLocalString(@"留言")]) {
        [_lblTextMsg addLinkToURL:[NSURL URLWithString:ZCSTLocalString(@"留言")] withRange:NSMakeRange(tempStr.length-ZCSTLocalString(@"留言").length, ZCSTLocalString(@"留言").length)];
    }

}


@end
