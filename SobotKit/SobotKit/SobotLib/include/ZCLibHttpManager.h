//
//  HttpManager.h
//  SobotSDK
//
//  Created by 张新耀 on 15/8/4.
//  Copyright (c) 2015年 sobot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZCLibHttpConstants.h"

/**
 *  网络请求管理
 */
@interface ZCLibHttpManager : NSObject


/**
 *  异步Get请求
 *
 *  @param stringURL
 *  @param startBlock
 *  @param finishBlock
 *  @param completeBlock
 *  @param failBlock
 */
+(void)get:(NSString *) stringURL
     start:(StartBlock) startBlock
    finish:(FinishBlock) finishBlock
  complete:(CompleteBlock) completeBlock
      fail:(FailBlock) failBlock;

+(void)get:(NSString *) stringURL
     start:(StartBlock) startBlock
    finish:(FinishBlock) finishBlock
  complete:(CompleteBlock) completeBlock
      fail:(FailBlock) failBlock
  progress:(ProgressBlock) progressBlock;


/**
 *  异步post请求
 *
 *  @param stringURL
 *  @param dict post参数，暂未处理文件
 *  @param startBlock
 *  @param finishBlock
 *  @param completeBlock
 *  @param failBlock
 */
+(void)post:(NSString *) stringURL
      param:(NSDictionary *) dict
    timeOut:(CGFloat) timeOut
      start:(StartBlock) startBlock
     finish:(FinishBlock) finishBlock
   complete:(CompleteBlock) completeBlock
       fail:(FailBlock) failBlock;

+(void)post:(NSString *) stringURL
      param:(NSDictionary *) dict
      start:(StartBlock) startBlock
     finish:(FinishBlock) finishBlock
   complete:(CompleteBlock) completeBlock
       fail:(FailBlock) failBlock
   progress:(ProgressBlock) progressBlock;

+(void)post:(NSString *) stringURL
      param:(NSDictionary *) dict
    timeOut:(CGFloat) timeOut
      start:(StartBlock) startBlock
     finish:(FinishBlock) finishBlock
   complete:(CompleteBlock) completeBlock
       fail:(FailBlock) failBlock
   progress:(ProgressBlock) progressBlock;



@end
