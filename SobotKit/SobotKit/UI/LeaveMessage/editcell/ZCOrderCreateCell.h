//
//  ZCOrderCreateCell.h
//  SobotApp
//
//  Created by zhangxy on 2017/7/12.
//  Copyright © 2017年 com.sobot.chat.app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZCOrderModel.h"

#import "ZCUIPlaceHolderTextView.h"
typedef NS_ENUM(NSInteger,ZCOrderCreateItemType) {
    ZCOrderCreateItemTypeAddPhoto        = 1,// 添加内容图片
    ZCOrderCreateItemTypeAddReplyPhoto   = 2,// 添加内容回复图片
    ZCOrderCreateItemTypeTitle           = 3,// 添加标题
    ZCOrderCreateItemTypeDesc            = 4,// 添加描述
    ZCOrderCreateItemTypeLookAtPhoto     = 5,// 查看大图
    ZCOrderCreateItemTypeLookAtReplyPhoto= 6,// 查看大图
    ZCOrderCreateItemTypeOnlyEdit        = 7,// 单行编辑
    ZCOrderCreateItemTypeMulEdit         = 8,// 多行编辑
    ZCOrderCreateItemTypeReplyType       = 9,// 多行编辑
};

@protocol ZCOrderCreateCellDelegate <NSObject>
@optional
-(void)itemCreateCellOnClick:(ZCOrderCreateItemType) type dictKey:(NSString *) key model:(ZCOrderModel *) model;

-(void)itemCreateCusCellOnClick:(ZCOrderCreateItemType) type dictValue:(NSString *) value dict:(NSDictionary *) dict indexPath:(NSIndexPath *)indexPath;


-(void)didKeyboardWillShow:(NSIndexPath *)indexPath view1:(UITextView *)textview view2:(UITextField *) textField;



@end


@interface ZCOrderCreateCell : UITableViewCell

@property(nonatomic,weak) id<ZCOrderCreateCellDelegate> delegate;

@property(nonatomic,assign) BOOL isReply;
@property(nonatomic,weak) NSIndexPath  *indexPath;
@property(nonatomic,weak) ZCOrderModel   *tempModel;
@property(nonatomic,strong) NSDictionary *tempDict;

-(void)initDataToView:(NSDictionary *) dict;
-(NSMutableAttributedString *)getOtherColorString:(NSString *)string Color:(UIColor *)Color withString:(NSString *)originalString;
@end
