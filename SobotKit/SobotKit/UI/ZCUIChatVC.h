//
//  ZCUIChatVC.h
//  SobotKit
//
//  Created by zhangxy on 16/8/1.
//  Copyright © 2016年 zhichi. All rights reserved.
//

#import <SobotKit/SobotKit.h>

/**
 *  智齿 聊天页面VC
 */
@interface ZCUIChatVC : ZCUIBaseController


/**
 *  初始化信息
 */
@property(nonatomic,strong) ZCKitInfo  *zckitInfo;

/**
 *  聊天列表
 */
@property (nonatomic,strong)UITableView *listTable;

/**
 *  初始化
 *
 *  @param info ZCKitInfo
 *
 *  @return ZCUIChatController
 */
-(id)initWithInitInfo:(ZCKitInfo *)info;


/**
 *  仅限于对UI大小有自定义的需求使用
 *
 *  @param info  初始化参数
 *  @param width 宽
 *  @param h     高
 *
 *  @return <#return value description#>
 */
-(id)initWithInitInfo:(ZCKitInfo *)info width:(CGFloat )width height:(CGFloat) h;



/**
 *  点击返回后的回调（注意：实现此方法后，sdk不自动实现返回事件）
 *
 *  @param pageClick  返回事件的回调
 *  @param linkBlock  超链的点击回调
 */
-(void)setPageBlock:(void (^)(ZCUIChatController *object,ZCPageBlockType type))pageClick messageLinkClick:(void (^)(NSString *link)) linkBlock;

@end
