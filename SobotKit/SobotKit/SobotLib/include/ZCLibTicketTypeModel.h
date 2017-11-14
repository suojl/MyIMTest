//
//  ZCLibTicketTypeModel.h
//  SobotKit
//
//  Created by lu on 2017/9/12.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZCLibTicketTypeModel : NSObject


//"companyId":"d2f208880c1b4bbb8a451dff2b23497a",
//"createId":"",
//"createTime":1496990255,
//"nodeFlag":0,
//"parentId":"-1",
//"remark":"",
//"typeId":"0",
//"typeLevel":1,
//"typeName":"投诉",
//"updateId":"",
//"updateTime":1496990255,
//"validFlag":1

/** 类型名称 */
@property (nonatomic,copy) NSString * typeName;

/**  工单类型 ID*/
@property (nonatomic,copy) NSString * typeId;

/**  子集 */
@property (nonatomic,strong) NSMutableArray * items;

/** 1 有下一级， 0 当前是最后一级 */
@property (nonatomic,copy) NSString * nodeFlag ;

-(id)initWithMyDict:(NSDictionary *)dict;

@end
