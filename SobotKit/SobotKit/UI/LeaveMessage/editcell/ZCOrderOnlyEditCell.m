//
//  ZCOrderOnlyEditCell.m
//  SobotApp
//
//  Created by zhangxy on 2017/7/21.
//  Copyright © 2017年 com.sobot.chat.app. All rights reserved.
//

#import "ZCOrderOnlyEditCell.h"
#import "ZCUIColorsDefine.h"
#import "ZCLIbGlobalDefine.h"
@interface ZCOrderOnlyEditCell()<UITextFieldDelegate>

@end

@implementation ZCOrderOnlyEditCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        _labelName = [[UILabel alloc]init];
        [_labelName setFont:DetGoodsFont];
        [_labelName setTextColor:UIColorFromRGB(TextWordOrderListTextColor)];
        [_labelName setNumberOfLines:0];
        [self.contentView addSubview:_labelName];
        
        _fieldContent = [[UITextField alloc]init];
        [_fieldContent setTextColor:UIColorFromRGB(TextUnPlaceHolderColor)];
        [_fieldContent setFont:DetGoodsFont];
        [_fieldContent setBorderStyle:UITextBorderStyleNone];
        [_fieldContent addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

        [_fieldContent addTarget:self action:@selector(textFieldDidChangeBegin:) forControlEvents:UIControlEventEditingDidBegin];
        [self.contentView addSubview:_fieldContent];
    }
    
    return self;
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)initDataToView:(NSDictionary *)dict{
    self.tempDict = dict;
//    [_labelName setText:dict[@"dictDesc"]];
    _labelName.attributedText = [self getOtherColorString:@"*" Color:[UIColor redColor] withString:dict[@"dictDesc"]];
  
    if([dict[@"dictType"] intValue] == 5 || [dict[@"dictName"] isEqualToString:@"ticketTel"]){
        _fieldContent.keyboardType = UIKeyboardTypeNumberPad;
    }else{
        _fieldContent.keyboardType = UIKeyboardTypeDefault;
    }
    
    
    [_fieldContent setPlaceholder:dict[@"placeholder"]];
    if(!zcLibIs_null(dict[@"dictValue"])){
        [_fieldContent setText:dict[@"dictValue"]];
    }
    
    _labelName.frame = CGRectMake(15, 12, 80, 20);
    
    CGRect labelF = _labelName.frame;
    CGSize size = [self autoHeightOfLabel:_labelName with:80.0f];
   
    
    _fieldContent.frame = CGRectMake(CGRectGetMaxX(_labelName.frame) +10, 12, ScreenWidth - 95 - 10 -15 , 20);
    
    CGFloat cellheight = 44;
    if(size.height > labelF.size.height){
        cellheight = size.height + 24;
    }
    
    CGPoint FC = _fieldContent.center ;
    FC.y = cellheight/2 ;
    _fieldContent.center = FC;
    
    [self setFrame:CGRectMake(0, 0, ScreenWidth, cellheight)];
    
    
    CGPoint NC = _labelName.center;
    NC.y = self.frame.size.height/2;
    _labelName.center = NC;
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



-(void)textFieldDidChangeBegin:(UITextField *) textField{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didKeyboardWillShow:view1:view2:)]){
        [self.delegate didKeyboardWillShow:self.indexPath view1:nil view2:textField];
    }
}

-(void)textFieldDidChange:(UITextField *)textField{
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCusCellOnClick:dictValue:dict:indexPath:)]) {
        [self.delegate itemCreateCusCellOnClick:ZCOrderCreateItemTypeOnlyEdit dictValue:zcLibConvertToString(textField.text) dict:self.tempDict indexPath:self.indexPath];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
