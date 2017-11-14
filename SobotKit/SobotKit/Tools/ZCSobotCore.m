//
//  ZCSobotCore.m
//  SobotKit
//
//  Created by zhangxy on 2017/2/14.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "ZCSobotCore.h"
#import "ZCStoreConfiguration.h"
#import "ZCIMChat.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCLibServer.h"

@implementation ZCSobotCore


+(BOOL) checkInitParameterChanged{
    // 如果杀进程了，此时通道中应该没有数据
    if([ZCIMChat getZCIMChat].messageArr == nil || [ZCIMChat getZCIMChat].messageArr.count <= 0 || [ZCIMChat getZCIMChat].libConfig == nil || [@"" isEqual:[ZCIMChat getZCIMChat].libConfig.uid]){
        [ZCStoreConfiguration cleanLocalParamter];
        
        [ZCStoreConfiguration setZCParamter:KEY_ZCCONFIGMESSAGE value:[self getCheckConfigMsg]];
        return YES;
    }
        
    if(![[self getCheckConfigMsg] isEqual:[ZCStoreConfiguration getZCParamter:KEY_ZCCONFIGMESSAGE]]){
        // 当前是仅机器人或更换了appkey，使用户离线
        if ([ZCLibClient getZCLibClient].libInitInfo.serviceMode == 1 || ![zcLibConvertToString([ZCStoreConfiguration getZCParamter:KEY_ZCCONFIGMESSAGE]) hasPrefix:zcLibConvertToString([ZCLibClient getZCLibClient].libInitInfo.appKey)]){
            // 断开通道，重新初始化
            [ZCLibClient closeAndoutZCServer:YES];
        }
        
        [ZCStoreConfiguration setZCParamter:KEY_ZCCONFIGMESSAGE value:[self getCheckConfigMsg]];
        [ZCStoreConfiguration setZCParamter:KEY_ZCISEVALUATIONSERVICE value:@"0"];
        [ZCStoreConfiguration setZCParamter:KEY_ZCISEVALUATIONROBOT value:@"0"];
        return YES;
    }
   
    
    return NO;
}


/**
 按顺序拼接初始化判断条件
 【必须调用此方法判断，保持顺序统一】

 @return 判断字符串
 */
+(NSString *) getCheckConfigMsg{
    
    ZCLibInitInfo *initInfo = [ZCLibClient getZCLibClient].libInitInfo;
    if(initInfo){
        // appkey，技能组、用户id，客服id，对接机器人编号、接入模式
        return [NSString stringWithFormat:@"%@|%@|%@|%@|%@|%d|%@|%@",initInfo.appKey,initInfo.skillSetId,initInfo.userId,initInfo.receptionistId,initInfo.robotId,initInfo.serviceMode,initInfo.customInfo,initInfo.customerFields];
    }
    return @"";
}


+(void)getPhotoByType:(NSInteger) buttonIndex byUIImagePickerController:(UIImagePickerController*)zc_imagepicker Delegate:(id)delegate {
    switch (buttonIndex) {
        case 2:
        {
            if ([ZCUITools isHasCaptureDeviceAuthorization]) {

                zc_imagepicker.sourceType=UIImagePickerControllerSourceTypeCamera;
                zc_imagepicker.allowsEditing=NO;
                [(UIViewController *)delegate presentViewController:zc_imagepicker animated:YES completion:^{
                }];
                
            }else{
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:ZCSTLocalString(@"请在iPhone的“设置-隐私-相机”选项中，允许访问你的手机相机") message:@"" delegate:nil cancelButtonTitle:ZCSTLocalString(@"好") otherButtonTitles: nil];
                [alert show];
            }
            break;
        }
        case 1:
        {
            //                从相册选择
            
            if ([ZCUITools isHasPhotoLibraryAuthorization]) {

                zc_imagepicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
                
                // 处理导航栏和状态栏的透明的问题,并重写他的navc代理方法
                if (iOS7) {
                    zc_imagepicker.edgesForExtendedLayout = UIRectEdgeNone;
                }
                
                if ([zc_imagepicker.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
                    // 是否设置相册背景图片
                    if ([ZCUITools zcgetPhotoLibraryBgImage]) {
                        // 图片是否存在
                        if ([ZCUITools zcuiGetBundleImage:@"ZCIcon_navcBgImage"]) {
                            
                            [zc_imagepicker.navigationBar setBarTintColor:[UIColor colorWithPatternImage:[ZCUITools zcuiGetBundleImage:@"ZCIcon_navcBgImage"]]];
                        }else{
                            [zc_imagepicker.navigationBar setBarTintColor:[ZCUITools zcgetImagePickerBgColor]];
                            [zc_imagepicker.navigationBar setTranslucent:YES];
                            [zc_imagepicker.navigationBar setTintColor:[ZCUITools  zcgetImagePickerTitleColor]];
                        }
                    }else{
                        // 不设置默认治随主题色
                        [zc_imagepicker.navigationBar setBarTintColor:[ZCUITools zcgetImagePickerBgColor]];
                    }
                    
                    [zc_imagepicker.navigationBar setTranslucent:YES];
                    [zc_imagepicker.navigationBar setTintColor:[ZCUITools  zcgetImagePickerTitleColor]];
                }else{
                    [zc_imagepicker.navigationBar setBackgroundColor:[ZCUITools zcgetImagePickerBgColor]];
                }
                // 设置系统相册导航条标题文字的大小
                //[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0]
                [zc_imagepicker.navigationBar setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[ZCUITools zcgetImagePickerTitleColor], NSForegroundColorAttributeName,[ZCUITools zcgetTitleFont], NSFontAttributeName, nil]];
                
                zc_imagepicker.allowsEditing=NO;
                
                [(UIViewController *)delegate presentViewController:zc_imagepicker animated:YES completion:^{
                    
                }];
            }else{
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:ZCSTLocalString(@"请在iPhone的“设置-隐私-照片”选项中，允许访问你的手机相册") message:@"" delegate:nil cancelButtonTitle:ZCSTLocalString(@"好") otherButtonTitles: nil];
                [alert show];
            }
            break;
        }
        default:
            break;
    }

}

+(void)imagePickerController:(UIImagePickerController *)zc_imagepicker didFinishPickingMediaWithInfo:(NSDictionary *)info WithView:(UIView *)zc_sourceView Delegate:(id)delegate  block:(DidFinishPickingMediaBlock)finshBlock{
//    [zc_imagepicker dismissViewControllerAnimated:YES completion:^{
//        NSLog(@"页面消失了");
//    }];
    
    if (zc_imagepicker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        UIImage * oriImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        oriImage = [self normalizedImage:oriImage];
        // 发送图片
        if (oriImage) {
            NSData * imageData =UIImageJPEGRepresentation(oriImage, 0.75f);
            NSString * fname = [NSString stringWithFormat:@"/sobot/image100%ld.jpg",(long)[NSDate date].timeIntervalSince1970];
            zcLibCheckPathAndCreate(zcLibGetDocumentsFilePath(@"/sobot/"));
            NSString *fullPath=zcLibGetDocumentsFilePath(fname);
            [imageData writeToFile:fullPath atomically:YES];
            CGFloat mb=imageData.length/1024/1024;
            if(mb>6){
                if(((UIViewController *)delegate).navigationController){
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"图片大小需小于8M!") duration:1.0 view:zc_sourceView.window.rootViewController.view  position:ZCToastPositionCenter];
                    });
                }else{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"图片大小需小于8M!") duration:1.0 view:zc_sourceView  position:ZCToastPositionCenter];
                    });
                }
                return;
            }
//            [self sendMessageOrFile:fullPath type:ZCMessageTypePhoto duration:@""];
            if (finshBlock) {
                finshBlock(fullPath,ZCMessageTypePhoto,@"");
            }
        }
        
    }
    if (zc_imagepicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        UIImage * originImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        originImage = [self normalizedImage:originImage];
        if (originImage) {
            NSData * imageData =UIImageJPEGRepresentation(originImage, 0.75f);
            NSString * fname = [NSString stringWithFormat:@"/sobot/image100%ld.jpg",(long)[NSDate date].timeIntervalSince1970];
            zcLibCheckPathAndCreate(zcLibGetDocumentsFilePath(@"/sobot/"));
            NSString *fullPath=zcLibGetDocumentsFilePath(fname);
            [imageData writeToFile:fullPath atomically:YES];
            CGFloat mb=imageData.length/1024/1024;
            if(mb>6){
                if(((UIViewController *)delegate).navigationController){
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"图片大小需小于8M!") duration:1.0 view:zc_sourceView.window.rootViewController.view  position:ZCToastPositionCenter];
                    });
                }else{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[ZCUIToastTools shareToast] showToast:ZCSTLocalString(@"图片大小需小于8M!") duration:1.0 view:zc_sourceView  position:ZCToastPositionCenter];
                    });
                }
                return;
            }
//            [self sendMessageOrFile:fullPath type:ZCMessageTypePhoto duration:@""];
            if (finshBlock) {
                finshBlock(fullPath,ZCMessageTypePhoto,@"");
            }
        }
    }

}


+ (UIImage *)normalizedImage:(UIImage *) image {
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}



@end
