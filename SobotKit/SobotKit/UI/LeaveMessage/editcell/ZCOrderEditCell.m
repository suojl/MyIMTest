//
//  ZCOrderEditCell.m
//  SobotApp
//
//  Created by zhangxy on 2017/7/12.
//  Copyright © 2017年 com.sobot.chat.app. All rights reserved.
//  多行文本的编辑状态

#import "ZCOrderEditCell.h"
#import "ZCUIColorsDefine.h"
#import "ZCLIbGlobalDefine.h"

@interface ZCOrderEditCell()<UITextViewDelegate>

@end

@implementation ZCOrderEditCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        _labelName = [[UILabel alloc]init];
        _labelName.backgroundColor = [UIColor clearColor];
        [_labelName setFont:DetGoodsFont];
        [_labelName setTextColor:UIColorFromRGB(TextWordOrderListTextColor)];
        [_labelName setNumberOfLines:0];
        
        [self.contentView addSubview:_labelName];
        
        _textContent = [[ZCUIPlaceHolderTextView alloc]init];
        _textContent.placeholder = @"";
        _textContent.placeholederFont = DetGoodsFont;
        [_textContent setPlaceholderColor:UIColorFromRGB(TextPlaceHolderColor)];
        [_textContent setTextColor:UIColorFromRGB(TextUnPlaceHolderColor)];
        [_textContent setFont:DetGoodsFont];
        _textContent.delegate = self;
        [self.contentView addSubview:_textContent];
    }
    
    return self;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)initDataToView:(NSDictionary *)dict{
//    [_labelName setText:dict[@"dictDesc"]];
    _labelName.attributedText = [self getOtherColorString:@"*" Color:[UIColor redColor] withString:dict[@"dictDesc"]];
    
        _labelName.frame = CGRectMake(15, 12, 80, 0);
    [self autoHeightOfLabel:_labelName with:80.0f];
    
//    CGFloat TH = CGRectGetHeight(_labelName.frame);
//    if (TH < 60) {
//        TH = 60;
//    }
    
    _textContent.frame = CGRectMake(CGRectGetMaxX(_labelName.frame) + 6, 5, ScreenWidth - 90 - 15 -22, 104-5 -10);
    [_textContent setPlaceholder:dict[@"placeholder"]];
    if(!zcLibIs_null(dict[@"dictValue"])){
        [_textContent setText:dict[@"dictValue"]];
    }
        
    [self setFrame:CGRectMake(0, 0, ScreenWidth, 104)];

}


-(void)textViewDidChange:(ZCUIPlaceHolderTextView *)textView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCusCellOnClick:dictValue:dict:indexPath:)]) {
        [self.delegate itemCreateCusCellOnClick:ZCOrderCreateItemTypeOnlyEdit dictValue:zcLibConvertToString(textView.text) dict:self.tempDict indexPath:self.indexPath];
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didKeyboardWillShow:view1:view2:)]){
        [self.delegate didKeyboardWillShow:self.indexPath view1:textView view2:nil];
    }
}


/**
 计算Label高度
 
 @param label 要计算的label，设置了值
 @param width label的最大宽度
 @param type 是否从新设置宽，1设置，0不设置
 */
- (CGSize )autoHeightOfLabel:(UILabel *)label with:(CGFloat )width{
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(width, FLT_MAX);
    
    CGSize expectedLabelSize = [label sizeThatFits:maximumLabelSize];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    [label updateConstraintsIfNeeded];
    
    return expectedLabelSize;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
