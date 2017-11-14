//
//  KNBHistoryOrderCell.m
//  SobotKit
//
//  Created by suojl on 2017/11/2.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "KNBHistoryOrderCell.h"
#import "UIView+SDAutoLayout.h"
#import "ZCLIbGlobalDefine.h"

@implementation KNBHistoryOrderCell
{
    UILabel     *_orderNumberLabel;
    UILabel     *_orderStateLabel;
    UILabel     *_goodsTitleLabel;
    UILabel     *_goodsPriceLabel;
    UILabel     *_orderDateLabel;
    ZCUIImageView       *_goodsImageView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    self.contentView.backgroundColor = UIColorFromRGB(0xf9f9f9);
    // 订单号
    _orderNumberLabel = [UILabel new];
    _orderNumberLabel.textColor = UIColorFromRGB(0x333333);
    _orderNumberLabel.font = [UIFont systemFontOfSize:15];
    _orderNumberLabel.textAlignment = NSTextAlignmentLeft;

    // 订单状态
    _orderStateLabel = [[UILabel alloc] init];
    _orderStateLabel.textColor = UIColorFromRGB(0xef508d);
    _orderStateLabel.font = [UIFont systemFontOfSize:12];
    _orderStateLabel.textAlignment = NSTextAlignmentCenter;
    _orderStateLabel.layer.masksToBounds = YES;
    _orderStateLabel.layer.cornerRadius = 2.f;
    _orderStateLabel.layer.borderColor = UIColorFromRGB(0xef508d).CGColor;
    _orderStateLabel.layer.borderWidth = 1.0f;

    // 商品描述
    _goodsTitleLabel = [UILabel new];
    _goodsTitleLabel.textColor = UIColorFromRGB(0x666666);
    _goodsTitleLabel.font = [UIFont systemFontOfSize:15];
    _goodsTitleLabel.textAlignment = NSTextAlignmentLeft;
    _goodsTitleLabel.numberOfLines = 1;
    _goodsTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    // 商品金额
    _goodsPriceLabel = [[UILabel alloc] init];
    _goodsPriceLabel.textColor = UIColorFromRGB(0xef508d);
    _goodsPriceLabel.font = [UIFont systemFontOfSize:16];
    _goodsPriceLabel.textAlignment = NSTextAlignmentLeft;
    _goodsPriceLabel.numberOfLines = 1;

    // 订单时间
    _orderDateLabel = [[UILabel alloc] init];
    _orderDateLabel.textColor = UIColorFromRGB(0x999999);
    _orderDateLabel.font = [UIFont systemFontOfSize:13];
    _orderDateLabel.textAlignment = NSTextAlignmentLeft;
    _orderDateLabel.numberOfLines = 1;

    // 商品首图
    _goodsImageView = [[ZCUIImageView alloc] init];
    [_goodsImageView setContentMode:UIViewContentModeScaleToFill];
    _goodsImageView.backgroundColor = [UIColor redColor];

    [self.contentView addSubview:_orderNumberLabel];
    [self.contentView addSubview:_goodsTitleLabel];
    [self.contentView addSubview:_goodsPriceLabel];
    [self.contentView addSubview:_orderStateLabel];
    [self.contentView addSubview:_orderDateLabel];
    [self.contentView addSubview:_goodsImageView];

    /*       设置ui控件的frame    */
    _orderNumberLabel.sd_layout.leftSpaceToView(self.contentView, 15)
                                .topSpaceToView(self.contentView, 15)
                                .rightSpaceToView(self.contentView, 65)
                                .autoHeightRatio(0);

    _orderStateLabel.sd_layout.rightSpaceToView(self.contentView, 15)
                                .topSpaceToView(self.contentView, 15)
                                .heightIs(17)
                                .widthIs(45);

    _goodsImageView.sd_layout.leftSpaceToView(self.contentView, 15)
                                .topSpaceToView(_orderNumberLabel, 15)
                                .heightIs(45).widthIs(45);

    _goodsTitleLabel.sd_layout.leftSpaceToView(_goodsImageView, 15)
                                .topEqualToView(_goodsImageView)
                                .rightSpaceToView(self.contentView, 15).heightIs(15);

    _orderDateLabel.sd_layout.rightSpaceToView(self.contentView, 15)
                                .bottomSpaceToView(self.contentView, 17)
                                .widthIs(80).heightIs(15);

    _goodsPriceLabel.sd_layout.leftSpaceToView(_goodsImageView, 15)
                                .bottomSpaceToView(self.contentView, 17)
                                .rightSpaceToView(_orderDateLabel, 15).autoHeightRatio(0);

    
}

-(void)setGoodsInfo:(KNBGoodsInfo *)goodsInfo{
    if (goodsInfo && _goodsInfo != goodsInfo) {
        _goodsInfo = goodsInfo;

        _orderNumberLabel.text = [NSString stringWithFormat:@"订单号: %@",goodsInfo.orderNumber];
        _orderDateLabel.text = goodsInfo.orderDate;
        _orderStateLabel.text = goodsInfo.orderState;
        _goodsTitleLabel.text = goodsInfo.goodsTitle;
        _goodsPriceLabel.text = [NSString stringWithFormat:@"￥%@",goodsInfo.goodsPrice];
        [_goodsImageView loadWithURL:[NSURL URLWithString:goodsInfo.goodsImgUrl]
                          placeholer:[ZCUITools zcuiGetBundleImage:@"ZCicon_default_bg"] showActivityIndicatorView:YES];
    }
}
@end
