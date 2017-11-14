//
//  ZCOrderContentCell.m
//  SobotApp
//
//  Created by zhangxy on 2017/7/12.
//  Copyright © 2017年 com.sobot.chat.app. All rights reserved.
//

#import "ZCOrderContentCell.h"
#import "ZCUploadImageModel.h"
#import "ZCUIColorsDefine.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIImageView.h"
#import "ZCLibConfig.h"
#import "ZCIMChat.h"

@interface ZCOrderContentCell()<UITextViewDelegate,UITextFieldDelegate>{
    ZCUIImageView * imageView;
}
@end

@implementation ZCOrderContentCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
//        _viewContent = [[UIView alloc]init];
//        _viewContent.backgroundColor = [UIColor whiteColor];
//        [self.contentView addSubview:_viewContent];
        
        _textDesc = [[ZCUIPlaceHolderTextView alloc]init];
        _textDesc.placeholder = @"问题描述提示文案";
        [_textDesc setPlaceholderColor:UIColorFromRGB(TextPlaceHolderColor)];
        [_textDesc setFont:DetGoodsFont];
        [_textDesc setTextColor:UIColorFromRGB(TextUnPlaceHolderColor)];
        _textDesc.delegate = self;
        _textDesc.placeholederFont = DetGoodsFont;
//        _textDesc.backgroundColor = [UIColor blueColor];
        [self.contentView addSubview:_textDesc];
        
        _fileScrollView = [[UIScrollView alloc]init];
        _fileScrollView.scrollEnabled = YES;
        _fileScrollView.userInteractionEnabled = YES;
        _fileScrollView.pagingEnabled = NO;
        _fileScrollView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_fileScrollView];
        
        _tipLab = [[UILabel  alloc]init];
        _tipLab.textColor = UIColorFromRGB(TextWordOrderListTextColor);
         [_tipLab setFont:DetGoodsFont];
        _tipLab.text = @"问题描述*";
        [self.contentView addSubview:_tipLab];
        self.backgroundColor = [UIColor whiteColor];

    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (NSMutableArray *)imageArr{
    if (!_imageArr) {
        _imageArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _imageArr;
}

-(void)initDataToView:(NSDictionary *)dict{
    
    self.frame = CGRectMake(0, 0, ScreenWidth, 0 );
    _tipLab.frame = CGRectMake(15, 12, ScreenWidth - 30, 20);
    _tipLab.attributedText = [self getOtherColorString:@"*" Color:[UIColor redColor] withString:ZCSTLocalString(@"问题描述*")];
    ZCLibConfig *libConfig = [ZCIMChat getZCIMChat].libConfig;
    //    enclosureShowFlag 附件是否显示
    //    enclosureFlag 附件是否必填
    if (!libConfig.enclosureShowFlag) {
       self.frame = CGRectMake(0, 0, ScreenWidth, 144);
    }else{
        
        _fileScrollView.frame = CGRectMake(15, 114 +42, ScreenWidth, 80);
        [self reloadScrollView];
        self.frame = CGRectMake(0, 0, ScreenWidth,  114 +42 + 80);

    }
    CGRect tf = self.frame;
    _textDesc.text   = @"";
    _textDesc.placeholder = dict[@"placeholder"];
    _textDesc.frame = CGRectMake(10, CGRectGetMaxY(_tipLab.frame) + 10, ScreenWidth-20, 102);
    
    UILabel * detailLab = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_tipLab.frame) + 10, ScreenWidth-20, 102)];
    detailLab.text = dict[@"placeholder"];
    detailLab.numberOfLines = 0;
//    [self autoHeightOfLabel:detailLab with: ScreenWidth-20 -16];
    [self getTextRectWith:dict[@"placeholder"] WithMaxWidth:ScreenWidth WithlineSpacing:0 AddLabel:detailLab];
    
    CGFloat DH = CGRectGetHeight(detailLab.frame);
    
    
    if (DH > 102) {
        _textDesc.frame = CGRectMake(10, CGRectGetMaxY(_tipLab.frame) + 10, ScreenWidth-20, DH);
        tf.size.height = tf.size.height + (DH - 102);
        if (libConfig.enclosureShowFlag) {
            _fileScrollView.frame = CGRectMake(15, CGRectGetMaxY(_textDesc.frame) +10, ScreenWidth, 80);
            self.frame = CGRectMake(0, 0, ScreenWidth, CGRectGetMaxY(_fileScrollView.frame));
        }else{
            self.frame = CGRectMake(0, 0, ScreenWidth, CGRectGetMaxY(_textDesc.frame) );
        }
        
        
    }
    
    [_textDesc setText:zcLibConvertToString(self.tempModel.ticketDesc)];
    
    
//    [self setFrame:CGRectMake(0, 0, ScreenWidth, tf.size.height + tf.origin.y)];
}



- (void)reloadScrollView{
    
    // 先移除，后添加
    [[self.fileScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // 加一是为了有个添加button
    NSUInteger assetCount = self.imageArr.count +1 ;
    
    CGFloat width = 60;
    for (NSInteger i = 0; i < assetCount; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        btn.frame = CGRectMake((width + 5)*i,0, width, width);
        imageView.frame = btn.frame;
        
        // UIButton
        if (i == self.imageArr.count){
            // 最后一个Button
            [btn setImage: [ZCUITools zcuiGetBundleImage:@"zcicon_add_photo"]  forState:UIControlStateNormal];
            // 添加图片的点击事件
            [btn addTarget:self action:@selector(photoSelecte) forControlEvents:UIControlEventTouchUpInside];
            if (assetCount ==6) {
                btn.frame = CGRectZero;
            }
        }else{
            // 就从本地取
//            ZCUploadImageModel *model = [_imageArr objectAtIndex:i];
            if(zcLibCheckFileIsExsis([_imagePathArr objectAtIndex:i])){
                UIImage *localImage=[UIImage imageWithContentsOfFile:[_imagePathArr objectAtIndex:i]];
                [btn setImage:localImage forState:UIControlStateNormal];
            }
            btn.tag = i;
            // 点击放大图片，进入图片
            [btn addTarget:self action:@selector(tapBrowser:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self.fileScrollView addSubview:btn];
    }
    self.fileScrollView.scrollEnabled = NO;
    // 设置contentSize
    self.fileScrollView.contentSize = CGSizeMake(ScreenWidth, CGRectGetMaxY([[self.fileScrollView.subviews lastObject] frame]));
}


#pragma mark - 选择图片
// 添加图片
- (void)photoSelecte{
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCellOnClick:dictKey:model:)]) {
        if(self.isReply){
            [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeAddReplyPhoto dictKey:@"dictContentImages" model:self.tempModel];
        }else{
        [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeAddPhoto dictKey:@"dictContentImages" model:self.tempModel];
        }
    }
    [_textDesc resignFirstResponder];
}


//预览图片
- (void)tapBrowser:(UIButton *)btn{
    // 点击图片浏览器 放大图片
//    NSLog(@"点击图片浏览器 放大图片");
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCellOnClick:dictKey:model:)]) {
        if(self.isReply){
            [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeLookAtReplyPhoto dictKey: [NSString stringWithFormat:@"%d",(int)btn.tag]  model:self.tempModel];
        }else{
            [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeLookAtPhoto dictKey:[NSString stringWithFormat:@"%d",(int)btn.tag]   model:self.tempModel];
        }
    }
    [_textDesc resignFirstResponder];
}

-(void)textViewDidChange:(ZCUIPlaceHolderTextView *)textView{
    
    self.tempModel.ticketDesc = zcLibConvertToString(textView.text);
   
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCreateCellOnClick:dictKey:model:)]) {
        
        [self.delegate  itemCreateCellOnClick:ZCOrderCreateItemTypeTitle dictKey:@"dictDesc" model:self.tempModel];
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didKeyboardWillShow:view1:view2:)]){
        [self.delegate didKeyboardWillShow:self.indexPath view1:textView view2:nil];
    }
}

-(void)textFieldDidChangeBegin:(UITextField *) textField{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didKeyboardWillShow:view1:view2:)]){
        [self.delegate didKeyboardWillShow:self.indexPath view1:nil view2:textField];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(CGRect)getTextRectWith:(NSString *)str WithMaxWidth:(CGFloat)width  WithlineSpacing:(CGFloat)LineSpacing AddLabel:(UILabel *)label{
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]initWithString:str];
    NSMutableParagraphStyle * parageraphStyle = [[NSMutableParagraphStyle alloc]init];
    [parageraphStyle setLineSpacing:LineSpacing];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:parageraphStyle range:NSMakeRange(0, [str length])];
    [attributedString addAttribute:NSFontAttributeName value:label.font range:NSMakeRange(0, str.length)];
    
    label.attributedText = attributedString;
    
    // 这里的高度的计算，不能在按 attributedString的属性去计算了，需要拿到label中的
    CGSize size = [self autoHeightOfLabel:label with:width];
    
    CGRect labelF = label.frame;
    labelF.size.height = size.height;
    label.frame = labelF;
    
    
    return labelF;
}


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


@end
