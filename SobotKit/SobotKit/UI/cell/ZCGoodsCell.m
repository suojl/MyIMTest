//
//  ZCGoodsCell.m
//  SobotKit
//
//  Created by zhangxy on 16/3/18.
//  Copyright © 2016年 zhichi. All rights reserved.
//

#import "ZCGoodsCell.h"

#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIXHImageViewer.h"
#import "ZCUIImageView.h"
#import "ZCStoreConfiguration.h"
#import "ZCUIConfigManager.h"

@implementation ZCGoodsCell{
    // 商品图片
    ZCUIImageView   *_imgPhoto;

    // 标题
    UILabel         *_lblTextTitle;

    // 发送
    UIButton        *_btnSendMsg;

    // 摘要
    UILabel         *_lblTextDet;

    // 标签
    UILabel         *_lblTextTip;
}

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _imgPhoto = [[ZCUIImageView alloc] init];
        [_imgPhoto setBackgroundColor:[UIColor clearColor]];
        [_imgPhoto setContentMode:UIViewContentModeScaleAspectFill];
        _imgPhoto.layer.masksToBounds=YES;
        _imgPhoto.layer.borderColor = UIColorFromRGB(LineGoodsImageColor).CGColor;
        _imgPhoto.layer.borderWidth = 1.0f;

        [self.contentView addSubview:_imgPhoto];

        // title
        _lblTextTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_lblTextTitle setTextAlignment:NSTextAlignmentLeft];
        [_lblTextTitle setFont:[ZCUITools zcgetTitleGoodsFont]];
        [_lblTextTitle setTextColor:[ZCUITools zcgetGoodsTextColor]];
        [_lblTextTitle setBackgroundColor:[UIColor clearColor]];
        _lblTextTitle.numberOfLines = 1;
        _lblTextTitle.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_lblTextTitle];

        // 摘要
        _lblTextDet = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_lblTextDet setTextAlignment:NSTextAlignmentLeft];
        [_lblTextDet setFont:[ZCUITools zcgetDetGoodsFont]];
        [_lblTextDet setTextColor:[ZCUITools zcgetGoodsDetColor]];
        [_lblTextDet setBackgroundColor:[UIColor clearColor]];
        _lblTextDet.numberOfLines = 2;
        _lblTextDet.lineBreakMode = NSLineBreakByTruncatingTail|NSLineBreakByClipping;
        [self.contentView addSubview:_lblTextDet];


        // 标签
        _lblTextTip = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_lblTextTip setTextAlignment:NSTextAlignmentLeft];
        [_lblTextTip setFont:[ZCUITools zcgetTitleGoodsFont]];
        [_lblTextTip setBackgroundColor:[UIColor clearColor]];
        [_lblTextTip setTextColor:[ZCUITools zcgetGoodsTipColor]];
        _lblTextTip.numberOfLines = 1;
        _lblTextTip.lineBreakMode = NSLineBreakByTruncatingTail|NSLineBreakByClipping;
        [self.contentView addSubview:_lblTextTip];


        // 发送
        _btnSendMsg = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnSendMsg setBackgroundColor:[UIColor clearColor]];
        [_btnSendMsg setTitle:ZCSTLocalString(@"发送") forState:UIControlStateNormal];
        [_btnSendMsg setTitleColor:[ZCUITools zcgetGoodsSendColor] forState:UIControlStateNormal];

        _btnSendMsg.titleLabel.font = [ZCUITools zcgetTitleGoodsFont];
        [_btnSendMsg setBackgroundColor:[ZCUITools zcgetGoodSendBtnColor]];
        [_btnSendMsg setFrame:CGRectMake(0, 0,70, 26)];
        [_btnSendMsg setUserInteractionEnabled:YES];
        [_btnSendMsg addTarget:self action:@selector(sendMessageToUser) forControlEvents:UIControlEventTouchUpInside];
        _btnSendMsg.layer.cornerRadius = 4;
        _btnSendMsg.layer.masksToBounds = YES;

        [self.contentView addSubview:_btnSendMsg];

        [self.contentView setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (ZCProductInfo *)getZCproductInfo{
    ZCProductInfo *productInfo  = [ZCUIConfigManager getInstance].kitInfo.productInfo;
    return productInfo;
}

-(CGFloat) InitDataToView:(ZCLibMessage *) model time:(NSString *) showTime{
    [self resetCellView];

    // 时间
    CGFloat cellHeight = 22;
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
//        [self.lblTime setFrame:CGRectMake(0, 0, self.viewWidth, 30)];
        self.lblTime.hidden=NO;
        cellHeight = cellHeight + 30 ;
    }

    CGFloat BY = cellHeight;


    // 图片隐藏
    _imgPhoto.hidden = YES;
    _lblTextDet.hidden = YES;
    _lblTextTip.hidden = YES;

    self.maxWidth = self.viewWidth - 20;
    CGFloat textX = 10;

    if([self getZCproductInfo].thumbUrl!=nil  && ![@"" isEqualToString:[self getZCproductInfo].thumbUrl]){
        [_imgPhoto setFrame:CGRectMake(10, cellHeight, 80, 80)];

        [_imgPhoto loadWithURL:[NSURL URLWithString:[self getZCproductInfo].thumbUrl] placeholer:[ZCUITools zcuiGetBundleImage:@"ZCicon_default_bg"]  showActivityIndicatorView:YES];
        _imgPhoto.hidden = NO;
        self.maxWidth = self.viewWidth - 113;
        textX = 103;

    }

    // 有图片
    [_lblTextTitle setFrame:CGRectMake(textX, cellHeight, self.maxWidth, 18)];

    _lblTextTitle.text = zcLibConvertToString([self getZCproductInfo].title);
    // 获取 添加标题之后的商品cell
    cellHeight = CGRectGetMaxY(_lblTextTitle.frame) + 10 ;

    // 摘要
    if (zcLibConvertToString([self getZCproductInfo].desc)!=nil && ![@"" isEqualToString:[self getZCproductInfo].desc]) {
        [_lblTextDet setFrame:CGRectMake(textX, cellHeight , self.maxWidth, 0)];
        _lblTextDet.hidden = NO;

        _lblTextDet.text = zcLibConvertToString([self getZCproductInfo].desc);
        // 获取摘要的内容大小
        CGRect textDetF = _lblTextDet.frame;
        if (zcLibConvertToString([self getZCproductInfo].label)!=nil && ![@"" isEqualToString:[self getZCproductInfo].label]) {
            textDetF.size.height = 44;
            textDetF.origin.y = cellHeight - 10;

            cellHeight = CGRectGetMaxY(textDetF);
        }else{
            CGSize size = [_lblTextDet.text boundingRectWithSize:CGSizeMake(_lblTextDet.frame.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[ZCUITools zcgetTitleFont]} context:nil].size;
            textDetF.origin.y = cellHeight;
            textDetF.size.height = size.height;

            cellHeight = CGRectGetMaxY(textDetF) + 10;
        }
        _lblTextDet.frame = textDetF;

    }

    // 标签
    if (zcLibConvertToString([self getZCproductInfo].label)!=nil && ![@"" isEqualToString:[self getZCproductInfo].label]) {
        [_lblTextTip setFrame:CGRectMake(textX, cellHeight, self.maxWidth, 18)];
        _lblTextTip.hidden = NO;

        _lblTextTip.text = zcLibConvertToString([self getZCproductInfo].label);
        cellHeight = CGRectGetMaxY(_lblTextTip.frame) +15;
    }


    // 发送按钮（计算发送按钮的在这8中商品展示的位置）
    CGRect bf = _btnSendMsg.frame;
    bf.origin.x = self.viewWidth - _btnSendMsg.frame.size.width -10;
    if(textX>10 && ((BY + 90)- cellHeight) > 31){
        bf.origin.y = BY + 90 - 26;
    }else{
        bf.origin.y = cellHeight + 5;
    }
    [_btnSendMsg setFrame:bf];

    cellHeight = CGRectGetMaxY(_btnSendMsg.frame) +12;

    // 时间的显示这里需要在处理一下
    if (!self.lblTime.hidden) {
        [self.ivBgView setFrame:CGRectMake(0, 40, self.viewWidth, cellHeight - 40)];
    }else{
        [self.ivBgView setFrame:CGRectMake(0, 10, self.viewWidth, cellHeight - 10)];
    }
    [self.ivBgView setBackgroundColor:[UIColor whiteColor]];

    // 12为增加的间隙(气泡和整个frame)
    self.frame = CGRectMake(0, 0, self.viewWidth, cellHeight +12);

    return cellHeight + 24;
}

- (void)sendMessageToUser{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]) {

//        [消息类型]:[123]
//        [订单编号]:[18264532919127139187478]
//        [商品编号]:[023823]
//        [订单状态]:[代收货]
//        [商品首图]:[http://f12.baidu.com/it/u=3087422712,1174175413&fm=72]
//                [商品金额]:[1232323]
//                [订单日期]:[2017-10-23]

        NSString *contextStr = @"[消息类型]:[123]\n[订单编号]:[18264532919127139187478]\n";
        contextStr = [contextStr stringByAppendingString:@"[商品编号]:[023823]\n[订单状态]:[代收货]\n"];
        contextStr = [contextStr stringByAppendingString:@"[商品首图]:[http://f12.baidu.com/it/u=3087422712,1174175413&fm=72]\n"];
        contextStr = [contextStr stringByAppendingString:@"[商品金额]:[1232323]\n[订单日期]:[2017-10-23]\n"];
//        if ([self getZCproductInfo].title !=nil && ![@"" isEqualToString:[self getZCproductInfo].title]) {
//            contextStr = [NSString stringWithFormat:@"[消息类型]:abc\n[%@]%@",ZCSTLocalString(@"标题"),[self getZCproductInfo].title];
//        }
//
//        if ([self getZCproductInfo].desc !=nil && ![@"" isEqualToString:[self getZCproductInfo].desc]) {
//            contextStr = [contextStr stringByAppendingString:[NSString stringWithFormat:@"\n[%@]%@",ZCSTLocalString(@"摘要"),[self getZCproductInfo].desc]];
//
//        }
//
//        if ([self getZCproductInfo].label !=nil && ![@"" isEqualToString:[self getZCproductInfo].label]) {
//            contextStr = [contextStr stringByAppendingString:[NSString stringWithFormat:@"\n[%@]%@",ZCSTLocalString(@"标签"),[self getZCproductInfo].label]];
//
//        }
//
//        if ([self getZCproductInfo].link !=nil && ![@"" isEqualToString:[self getZCproductInfo].link]) {
//            contextStr = [contextStr stringByAppendingString:[NSString stringWithFormat:@"\n[%@]%@",ZCSTLocalString(@"链接"),[self getZCproductInfo].link]];
//        }

        [self.delegate cellItemClick:nil type:ZCChatCellClickTypeSendGoosText obj:contextStr];
    }
}

-(void)resetCellView{
    [super resetCellView];

    [self.lblNickName setText:@""];
}


+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat)width{
    CGFloat cellHeight = 12;
    if(![@"" isEqual:zcLibConvertToString(showTime)]){
        cellHeight = cellHeight + 30;
    }

    ZCProductInfo *productInfo = [ZCUIConfigManager getInstance].kitInfo.productInfo;

    CGFloat maxWidth = width - 20;
    CGFloat imgHeight = cellHeight;
    if (productInfo.thumbUrl !=nil && ![@"" isEqualToString:productInfo.thumbUrl]) {
        maxWidth = width - 113;
        imgHeight = imgHeight + 90;
    }
    // 标题的高度
    cellHeight = cellHeight + 18 + 10;


    // 摘要
    if (zcLibConvertToString(productInfo.desc)!=nil && ![@"" isEqualToString:productInfo.desc]) {

        if (zcLibConvertToString(productInfo.label)!=nil && ![@"" isEqualToString:productInfo.label]) {
            cellHeight = cellHeight +34;
        }
        else{
            // 获取摘要的内容大小
            CGSize size = [zcLibConvertToString(productInfo.desc) boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[ZCUITools zcgetTitleFont]} context:nil].size;

            cellHeight = cellHeight + size.height + 10;
        }
    }


    // 标签
    if (zcLibConvertToString(productInfo.label)!=nil && ![@"" isEqualToString:productInfo.label]) {
        cellHeight = cellHeight + 18 +10;
    }


    // 发送按钮（计算发送按钮的在这8中商品展示的位置）
    if((imgHeight- cellHeight) > 31){
        cellHeight = imgHeight + 12;
    }else{
        cellHeight = cellHeight + 5 + 26 + 12;
    }


    return cellHeight + 24;
}


- (CGSize)sizeThatFits:(CGSize)size {

    CGSize rSize = [super sizeThatFits:size];
    rSize.height +=1;
    return rSize;
}


@end

