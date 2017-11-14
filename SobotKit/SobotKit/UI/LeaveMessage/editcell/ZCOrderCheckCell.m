//
//  ZCOrderCheckCell.m
//  SobotApp
//
//  Created by zhangxy on 2017/7/12.
//  Copyright © 2017年 com.sobot.chat.app. All rights reserved.
//

#import "ZCOrderCheckCell.h"
#import "ZCUIColorsDefine.h"
#import "ZCLIbGlobalDefine.h"

@implementation ZCOrderCheckCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        _labelName = [[UILabel alloc]init];
        [_labelName setFont:DetGoodsFont];
        [_labelName setTextColor:UIColorFromRGB(TextWordOrderListTextColor)];
        [_labelName setNumberOfLines:0];
        [self.contentView addSubview:_labelName];
        
        _labelContent = [[UILabel alloc]init];
        [_labelContent setTextColor:UIColorFromRGB(TextPlaceHolderColor)];
        [_labelContent setFont:DetGoodsFont];
        [self.contentView addSubview:_labelContent];
        
        _imgArrow = [[UIImageView alloc]init];
        _imgArrow.image = [ZCUITools zcuiGetBundleImage:@"ZCicon_web_next_disabled"];
        [self.contentView addSubview:_imgArrow];
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
    if(!zcLibIs_null(dict[@"dictValue"])){
        [_labelContent setText:dict[@"dictValue"]];
        [_labelContent setTextColor:UIColorFromRGB(TextUnPlaceHolderColor)];
    }else{
        [_labelContent setText:dict[@"placeholder"]];
        [_labelContent setTextColor:UIColorFromRGB(TextPlaceHolderColor)];
    }
    if([dict[@"propertyType"] intValue] == 3){
        _imgArrow.hidden = YES;
    }else{
        _imgArrow.hidden = NO;
    }
    
    
    _labelName.frame = CGRectMake(15, 12, 80, 20);
    
    CGRect labelF = _labelName.frame;
    CGSize size = [self autoHeightOfLabel:_labelName with:80.0f];
    _labelContent.frame = CGRectMake(CGRectGetMaxX(_labelName.frame) + 10, 12, ScreenWidth - 95 -10 - 22 -10, 20);
    _imgArrow.frame = CGRectMake(CGRectGetMaxX(_labelContent.frame) + 10, 12, 20, 21);
    CGFloat cellheight = 44;
    if(size.height > labelF.size.height){
        cellheight = size.height + 24;
    }
    
    [self setFrame:CGRectMake(0, 0, ScreenWidth, cellheight)];
    CGPoint  NC = _labelName.center;
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
