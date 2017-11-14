//
//  HttpConstants.h
//  SobotSDK
//
//  Created by 张新耀 on 15/8/5.
//  Copyright (c) 2015年 sobot. All rights reserved.
//

#import <CoreText/CoreText.h>
/**
 *  超时时间
 */
#define HttpGetTimeOut       10
#define HttpPostTimeOut      30
#define HttpPostSmallTimeOut 10

// 1,ASI(赞不使用) 2,NSURLConnection 3,NSURLSession
#define HttpRequestType  2


#define HttpNetWorkError    @"网络错误"
#define HttpNetWorkTimeOut  @"网络连接超时"

/**
 *  开始请求，每次发送请求时调用
 */
typedef void(^StartBlock)(void);

/**
 *  请求成功
 *
 *  @param dict 成功后，解析的返回
 */
typedef void(^CompleteBlock)(NSDictionary *dict);

/**
 *  请求完成，不管失败、成功，只要完成都会执行，可为nil
 *
 *  @param response 请求返回NSURLResponse
 */
typedef void(^FinishBlock)(id response,NSData  *data);

/**
 *  请求失败
 *
 *  @param response     请求返回NSURLResponse
 *  @param connectError 失败的connectError
 */
typedef void(^FailBlock)(id response,NSString *errorMsg,NSError *connectError);


/**
 *  上传、下载进度
 *
 *  @param progress 上传、下载进度，如0.2，0.5
 */
typedef void(^ProgressBlock)(CGFloat progress);


