//
//  ZCUploadImageModel.h
//  SobotApp
//
//  Created by lizhihui on 16/5/23.
//  Copyright © 2016年 com.sobot.chat.app. All rights reserved.
//
//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ZCUploadImageModel : NSObject

@property (nonatomic,strong) NSString *fileNumKey;
@property (nonatomic,strong) NSString *fileType;
@property (nonatomic,strong) NSString *fileUrl;

-(id)initWithMyDict:(NSDictionary *)dict;
@end
