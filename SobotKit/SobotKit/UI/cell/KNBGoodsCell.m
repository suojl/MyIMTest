//
//  KNBGoodsCell.m
//  SobotKit
//
//  Created by suojl on 2017/10/26.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "KNBGoodsCell.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIXHImageViewer.h"
#import "ZCUIConfigManager.h"

@implementation KNBGoodsCell{
    KNBGoodsInfo *_goodsInfo;
    CGFloat _cellHeight;
}

@synthesize goodsInfo = _goodsInfo;
@synthesize cellHeight = _cellHeight;
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//-(void)setGoodsInfo:(KNBGoodsInfo *)goodsInfo{
//    if (goodsInfo) {
//        self.orderNumber.text = goodsInfo.orderNumber;
//        self.orderDate.text = goodsInfo.orderDate;
//        self.orderPrice.text = goodsInfo.goodsPrice;
//        self.orderState.text = goodsInfo.orderState;
//        self.orderTitle.text = goodsInfo.goodsTitle;
////        [self.goodsImageView loadWithURL:[NSURL URLWithString:goodsInfo.goodsImgUrl] placeholer:[ZCUITools zcuiGetBundleImage:@"ZCicon_default_bg"] showActivityIndicatorView:YES];
//    }
//    _goodsInfo = goodsInfo;
//}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if(self){
        // _orderTitle 商品 描述
        _orderTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        [_orderTitle setTextAlignment:NSTextAlignmentLeft];
//        [_orderTitle setFont: [ZCUITools knbGetGoodsTitleLabelFont]];
//        [_orderTitle setTextColor:[ZCUITools knbGetGoodsTitleLabelColor]];
//        [_orderTitle setFont: [UIFont fontWithName:@"Helvetica Neue" size:15.0]];
        [_orderTitle setFont: [UIFont systemFontOfSize:15]];
        [_orderTitle setTextColor:UIColorFromRGB(0x333333)];
        [_orderTitle setBackgroundColor:[UIColor clearColor]];
        _orderTitle.numberOfLines = 1;
        _orderTitle.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.ivBgView addSubview:_orderTitle];

        // _orderPrice 订单金额
        _orderPrice = [[UILabel alloc] initWithFrame:CGRectZero];
        [_orderPrice setTextAlignment:NSTextAlignmentLeft];
//        [_orderPrice setFont: [ZCUITools knbGetGoodsPriceLabelFont]];
//        [_orderPrice setTextColor:[ZCUITools knbGetGoodsPriceLabelColor]];
//        [_orderPrice setFont: [UIFont fontWithName:@"Helvetica Neue" size:16.0]];
        [_orderPrice setFont: [UIFont systemFontOfSize:16]];
        [_orderPrice setTextColor:UIColorFromRGB(0xef508d)];
        [_orderPrice setBackgroundColor:[UIColor clearColor]];
        _orderPrice.numberOfLines = 1;
        _orderPrice.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.ivBgView addSubview:_orderPrice];

        // _orderDate 订单日期
//        _orderDate = [[UILabel alloc] initWithFrame:CGRectZero];
//        [_orderDate setTextAlignment:NSTextAlignmentLeft];
////        [_orderDate setFont: [ZCUITools knbGetOrderDateLabelFont]];
////        [_orderDate setTextColor:[ZCUITools knbGetOrderDateLabelColor]];
////        [_orderDate setFont: [UIFont fontWithName:@"Helvetica Neue" size:13.0]];
//          [_orderDate setFont:[UIFont systemFontOfSize:13.0]];
//        [_orderDate setTextColor:UIColorFromRGB(0x999999)];
//        [_orderDate setBackgroundColor:[UIColor clearColor]];
//        _orderDate.numberOfLines = 1;
//        _orderDate.lineBreakMode = NSLineBreakByTruncatingTail;
//        [self.ivBgView addSubview:_orderDate];

        _goodsImageView = [[ZCUIImageView alloc] init];
        [_goodsImageView setBackgroundColor:[UIColor clearColor]];
        [_goodsImageView setContentMode:UIViewContentModeScaleAspectFill];
        _goodsImageView.layer.masksToBounds=YES;
        _goodsImageView.layer.borderColor = UIColorFromRGB(LineGoodsImageColor).CGColor;
        _goodsImageView.layer.borderWidth = 1.0f;

        [self.ivBgView addSubview:_goodsImageView];

        // 发送
        _btnSendGoods = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnSendGoods setBackgroundColor:[UIColor clearColor]];
        [_btnSendGoods setTitle:ZCSTLocalString(@"发送") forState:UIControlStateNormal];
        [_btnSendGoods setTitleColor:UIColorFromRGB(0xef508d) forState:UIControlStateNormal];

//        _btnSendGoods.titleLabel.font = [ZCUITools zcgetTitleGoodsFont];
//        [_btnSendGoods setBackgroundColor:[ZCUITools zcgetGoodSendBtnColor]];
        _btnSendGoods.titleLabel.font = [UIFont systemFontOfSize:15];
        [_btnSendGoods setBackgroundColor:[UIColor clearColor]];
        [_btnSendGoods setFrame:CGRectMake(0, 0,70, 26)];
        [_btnSendGoods setUserInteractionEnabled:YES];
        [_btnSendGoods addTarget:self action:@selector(sendMessageToUser) forControlEvents:UIControlEventTouchUpInside];
        _btnSendGoods.layer.cornerRadius = 4;
        _btnSendGoods.layer.masksToBounds = YES;

        [self.ivBgView addSubview:_btnSendGoods];
        [self.ivBgView setUserInteractionEnabled:YES];
        [self.contentView setBackgroundColor:[UIColor clearColor]];


        self.ivBgView.layer.borderWidth = 1;
        self.ivBgView.layer.borderColor = UIColorFromRGB(0xe6e7e5).CGColor;
        self.ivBgView.layer.cornerRadius = 4;
        self.ivBgView.layer.masksToBounds = YES;
    }
    return self;
}

- (KNBGoodsInfo *)getGoodsInfo{
    if (_goodsInfo) {
        return _goodsInfo;
    }
    KNBGoodsInfo *goodsInfo  = [ZCUIConfigManager getInstance].kitInfo.orderGoodsInfo;
    return goodsInfo;
}

-(CGFloat) InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    [self resetCellView];
    // 当前cell的高度
    _cellHeight = 22;


    // 时间Label
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
    }

    // 背景的宽度 和 高度
    CGFloat ivBgViewWidth = self.viewWidth - 34;
    CGFloat ivBgViewHeight = _cellHeight;

    // 显示 商品图片
    if (zcLibConvertToString([self getGoodsInfo].goodsImgUrl)!=nil && ![@"" isEqualToString:[self getGoodsInfo].goodsImgUrl]) {
        [_goodsImageView setFrame: CGRectMake(15, ivBgViewHeight, 55, 55)];

        [self.goodsImageView loadWithURL:[NSURL URLWithString:[self getGoodsInfo].goodsImgUrl] placeholer:[ZCUITools zcuiGetBundleImage:@"ZCicon_default_bg"] showActivityIndicatorView:YES];
    }

    // 显示 商品描述
    if (zcLibConvertToString([self getGoodsInfo].goodsTitle)!=nil && ![@"" isEqualToString:[self getGoodsInfo].goodsTitle]) {
        [_orderTitle setFrame:CGRectMake(85, ivBgViewHeight,(ivBgViewWidth - 100), 15)];
        _orderTitle.text = zcLibConvertToString([self getGoodsInfo].goodsTitle);
    }
    // 显示 商品金额
    CGFloat y = CGRectGetMaxY(_orderTitle.frame) + 25;
    if (zcLibConvertToString([self getGoodsInfo].goodsPrice)!=nil && ![@"" isEqualToString:[self getGoodsInfo].goodsPrice]) {
        [_orderPrice setFrame:CGRectMake(85, y,(ivBgViewWidth - 178), 15)];
        _orderPrice.text = [NSString stringWithFormat:@"￥%@",zcLibConvertToString([self getGoodsInfo].goodsPrice)];
    }


    ivBgViewHeight = ivBgViewHeight + 55 + 15;

    /*-----------是否显示发送按钮-----------*/
    if (!_btnSendGoods.isHidden) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, ivBgViewHeight, ivBgViewWidth, 1)];
        [lineView setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
        [self.ivBgView addSubview:lineView];

        CGFloat centerX = ivBgViewWidth/2;
        CGFloat centerY = ivBgViewHeight + 20;
        [_btnSendGoods setFrame:CGRectMake((centerX - 35), (centerY - 13), 70, 26)];
        ivBgViewHeight = ivBgViewHeight + 40;
    }
    /*-----------------------end--------------*/

    // 根据时间是否显示来设置背景的 Frame
    if (!self.lblTime.hidden) {
        [self.ivBgView setFrame:CGRectMake(17, 40, ivBgViewWidth, ivBgViewHeight)];
        _cellHeight = ivBgViewHeight + 40;
    }else{
        [self.ivBgView setFrame:CGRectMake(17, 10, ivBgViewWidth, ivBgViewHeight)];
        _cellHeight = ivBgViewHeight + 10;
    }
    [self.ivBgView setBackgroundColor:UIColorFromRGB(0xffffff)];

    _cellHeight += 10;
    return _cellHeight;
}

- (void)sendMessageToUser{
    DLog(@"------------------------------");
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:type:obj:)]) {

//        [消息类型]:[123]
//        [订单编号]:[18264532919127139187478]
//        [订单状态]:[代收货]
//        [商品首图]:[http://f12.baidu.com/it/u=3087422712,1174175413&fm=72]
//        [商品价格]:[1232323]
//        [下单时间]:[2017-10-23]
//        [商品名称]:[]

        KNBGoodsInfo *goodsInfo = [self getGoodsInfo];

        NSString *contextStr = @"[消息类型]:[商品]\n";
        contextStr = [contextStr stringByAppendingFormat:@"[订单编号]:[%@]\n",goodsInfo.orderNumber];
        contextStr = [contextStr stringByAppendingFormat:@"[订单状态]:[%@]\n",goodsInfo.orderState];
        contextStr = [contextStr stringByAppendingFormat:@"[下单时间]:[%@]\n",goodsInfo.orderDate];
        contextStr = [contextStr stringByAppendingFormat:@"[商品名称]:[%@]\n",goodsInfo.goodsTitle];
        contextStr = [contextStr stringByAppendingFormat:@"[商品价格]:[%@]\n",goodsInfo.goodsPrice];
        contextStr = [contextStr stringByAppendingFormat:@"[商品首图]:[%@]",goodsInfo.goodsImgUrl];

        [self.delegate cellItemClick:nil type:ZCChatCellClickTypeSendGoosText obj:contextStr];
    }
}

-(void)resetCellView{
    [super resetCellView];

    [self.lblNickName setText:@""];
}
@end
