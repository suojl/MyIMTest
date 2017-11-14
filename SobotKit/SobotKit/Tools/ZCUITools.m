//
//  ZCUITools.m
//  SobotKit
//
//  Created by zhangxy on 15/11/11.
//  Copyright © 2015年 zhichi. All rights reserved.
//

#import "ZCUITools.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "ZCUIConfigManager.h"
#import "zcuiColorsDefine.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCStoreConfiguration.h"

@implementation ZCUITools


+(UIImage *)zcuiGetBundleImage:(NSString *)imageName{
//    NSString *bundlePath=[self zcuiFullBundlePath:imageName];
//    return [UIImage imageWithContentsOfFile:bundlePath];
    NSString *bundleName=[NSString stringWithFormat:@"SobotKit.bundle/%@",imageName];
    return [UIImage imageNamed:bundleName];
}

+(UIImage *)knbUiGetBundleImage:(NSString *)imageName{
    NSString *bundleName=[NSString stringWithFormat:@"KeFuSDK.bundle/%@",imageName];
    return [UIImage imageNamed:bundleName];
}

+(UIImage *)zcuiGetExpressionBundleImage:(NSString *)imageName{
    //    NSString *bundlePath=[self zcuiFullBundlePath:imageName];
    //    return [UIImage imageWithContentsOfFile:bundlePath];
    NSString *bundleName=[NSString stringWithFormat:@"ZCEmojiExpression.bundle/%@",imageName];
    return [UIImage imageNamed:bundleName];
}


+ (NSArray *)allExpressionArray {
    NSString *filePath =  [[NSBundle mainBundle] pathForResource:@"ZCEmojiExpression.bundle/expression.json" ofType:nil];
    if(filePath==nil){
        return nil;
    }
    //根据文件路径读取数据
    NSData *jdata = [[NSData alloc]initWithContentsOfFile:filePath];
    if(jdata == nil){
        return nil;
    }
    //格式化成json数据
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:jdata options:NSJSONReadingMutableLeaves error:nil];
    return arr;
}

+ (NSString*) zcuiFullBundlePath:(NSString*)bundlePath{
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:bundlePath];
}


+(ZCKitInfo *)getZCKitInfo{
    return [ZCUIConfigManager getInstance].kitInfo;
}

+(BOOL) zcgetOpenRecord{
    ZCKitInfo * configModel = [self getZCKitInfo];
    if (configModel!= nil) {
        return configModel.isOpenRecord;
    }
    return YES;
}


+(BOOL) zcgetPhotoLibraryBgImage{
    ZCKitInfo * configModel = [self getZCKitInfo];
    if (configModel!= nil) {
        return configModel.isSetPhotoLibraryBgImage;
    }
    return NO;
}

+(UIFont *)zcgetTitleFont{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.titleFont!=nil){
        return configModel.titleFont;
    }
    return TitleFont;
}

+(UIFont *)zcgetTitleGoodsFont{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.goodsTitleFont) {
        return configModel.goodsTitleFont;
    }
    return TitleGoodsFont;
}


+(UIFont *)zcgetDetGoodsFont{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel !=nil && configModel.goodsDetFont) {
        return configModel.goodsDetFont;
    }
    return DetGoodsFont;
}


+(UIFont *)zcgetListKitTitleFont{
    
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.listTitleFont!=nil){
        return configModel.listTitleFont;
    }
    return ListTitleFont;
}
+(UIFont *)zcgetListKitDetailFont{
    
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.listDetailFont!=nil){
        return configModel.listDetailFont;
    }
    return ListTimeFont;
}

+(UIFont *)zcgetCustomListKitDetailFont{
    
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.customlistDetailFont!=nil){
        return configModel.customlistDetailFont;
    }
    return CustomListDetailFont;
}



+(UIFont *)zcgetListKitTimeFont{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.listTimeFont!=nil){
        return configModel.listTimeFont;
    }
    return ListTimeFont;
}
+(UIFont *)zcgetKitChatFont{
    
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.chatFont!=nil){
        return configModel.chatFont;
    }
    return [UIFont systemFontOfSize:15];
}

+(UIFont *)zcgetVoiceButtonFont{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.voiceButtonFont!=nil){
        return configModel.voiceButtonFont;
    }
    return VoiceButtonFont;
}

+(UIColor *)zcgetBackgroundColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.backgroundColor!=nil){
        return configModel.backgroundColor;
    }
    return UIColorFromRGB(BgSystemColor);
}

/**
 *  商品中发送按钮的背景色
 *
 *
 */
+(UIColor *)zcgetGoodSendBtnColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if(configModel!=nil && configModel.goodSendBtnColor!=nil){
        return configModel.goodSendBtnColor;
    }
    return UIColorFromRGB(BgTitleColor);
}

+(UIColor *) zcgetDynamicColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.customBannerColor!=nil){
        return configModel.customBannerColor;
    }
    return UIColorFromRGB(BgTitleColor);
}

+(UIColor *) zcgetImagePickerBgColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.imagePickerColor!=nil){
        return configModel.imagePickerColor;
    }
    return UIColorFromRGB(BgTitleColor);
}


+(UIColor *)zcgetsocketStatusButtonBgColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.socketStatusButtonBgColor) {
        return configModel.socketStatusButtonBgColor;
    }
    return  UIColorFromRGB(BgTitleColor);
}


+(UIColor *)zcgetsocketStatusButtonTitleColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.socketStatusButtonTitleColor) {
        return configModel.socketStatusButtonTitleColor;
    }
    return  UIColorFromRGB(TextBlackColor);
}


+(UIColor *)zcgetScoreExplainTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.scoreExplainTextColor) {
        return configModel.scoreExplainTextColor;
    }
    return  UIColorFromRGB(ScoreExplainTextColor);
}


+(UIColor *)zcgetImagePickerTitleColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.imagePickerTitleColor!=nil){
        return configModel.imagePickerTitleColor;
    }
    return UIColorFromRGB(TextTopColor);
}

+(UIColor *)zcgetLeftChatColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.leftChatColor!=nil){
        return configModel.leftChatColor;
    }
    return [UIColor whiteColor];
}

+(UIColor *)zcgetRightChatColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.rightChatColor!=nil){
        return configModel.rightChatColor;
    }
    return UIColorFromRGB(BgRightChatColor);
}

+(UIColor *)zcgetBackgroundBottomColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.backgroundBottomColor!=nil){
        return configModel.backgroundBottomColor;
    }
    return UIColorFromRGB(BgTextEditColor);
}



// 复制选中的背景色
+(UIColor *)zcgetRightChatSelectdeColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.rightChatSelectedColor!=nil){
        return configModel.rightChatSelectedColor;
    }
    return UIColorFromRGB(BgChatRightSelectedColor);
}


+(UIColor *)zcgetLeftChatSelectedColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.leftChatSelectedColor!=nil){
        return configModel.leftChatSelectedColor;
    }
    return UIColorFromRGB(BgChatLeftSelectedColor);
}






+(UIColor *)zcgetBackgroundBottomLineColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.bottomLineColor!=nil){
        return configModel.bottomLineColor;
    }
    return UIColorFromRGBAlpha(LineTextMenuColor, 0.7);
}

+(UIColor *)zcgetCommentButtonLineColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.commentOtherButtonBgColor!=nil){
        return configModel.commentOtherButtonBgColor;
    }
    //    return UIColorFromRGB(LineCommentLineColor);
    return [self zcgetDynamicColor];
}


+(UIColor *)zcgetCommentButtonBgColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.commentCommitButtonBgColor!=nil){
        return configModel.commentCommitButtonBgColor;
    }
    return [self zcgetDynamicColor];
}
+(UIColor *)zcgetCommentButtonBgHighColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.commentCommitButtonBgHighColor!=nil){
        return configModel.commentCommitButtonBgHighColor;
    }
    
    return UIColorFromRGBAlpha(0x089899, 0.95);
}

+(UIColor *)zcgetCommentCommitButtonColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.commentCommitButtonColor!=nil){
        return configModel.commentCommitButtonColor;
    }
    //    return UIColorFromRGB(BgTitleColor);
    return [self zcgetDynamicColor];
}


+(UIColor *)zcgetBgTipAirBubblesColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.BgTipAirBubblesColor!=nil){
        return configModel.BgTipAirBubblesColor;
    }
    return UIColorFromRGB(BgOffLineColor);
}

+(UIColor *)zcgetSubmitEvaluationButtonColor{
    ZCKitInfo *configModel=[self getZCKitInfo];
    if(configModel!=nil && configModel.submitEvaluationColor!=nil){
        return configModel.submitEvaluationColor;
    }
    return UIColorFromRGB(TextTopColor);
}


+(UIColor *)zcgetTopViewTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.topViewTextColor) {
        return configModel.topViewTextColor;
    }
    return  UIColorFromRGB(0x000000);
}


+(UIColor *)zcgetLeftChatTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.leftChatTextColor) {
        return configModel.leftChatTextColor;
    }
    return UIColorFromRGB(0x333333);
}


+(UIColor*)zcgetGoodsTextColor{
    ZCKitInfo * configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.goodsTitleTextColor) {
        return configModel.goodsTitleTextColor;
    }
    return UIColorFromRGB(TextBlackColor);
}

+(UIColor *)zcgetGoodsDetColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel !=nil && configModel.goodsDetTextColor) {
        return configModel.goodsDetTextColor;
    }
    return UIColorFromRGB(TextGoodDetColor);
}

+(UIColor *)zcgetGoodsTipColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel !=nil && configModel.goodsTipTextColor) {
        return configModel.goodsTipTextColor;
    }
    return UIColorFromRGB(TextGoodsTipColot);
}


+(UIColor *)zcgetGoodsSendColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel !=nil && configModel.goodsSendTextColor) {
        return configModel.goodsSendTextColor;
    }
    return UIColorFromRGB(TextTopColor);
}



+(UIColor *)zcgetSatisfactionColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.satisfactionTextColor) {
        return configModel.satisfactionTextColor;
    }
    return UIColorFromRGB(SatisfactionTextColor);
}


+(UIColor *)zcgetNoSatisfactionTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.noSatisfactionTextColor) {
        return configModel.noSatisfactionTextColor;
    }
    return UIColorFromRGB(NoSatisfactionTextColor);
}

+(UIColor *)zcgetSatisfactionTextSelectedColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.satisfactionTextSelectedColor) {
        return configModel.satisfactionTextSelectedColor;
    }
    return UIColorFromRGB(TextTopColor);
}
+(UIColor *)zcgetSatisfactionBgSelectedColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.satisfactionSelectedBgColor) {
        return configModel.satisfactionSelectedBgColor;
    }
    return UIColorFromRGB(BgTitleColor);
}



+(UIColor *)zcgetRightChatTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.rightChatTextColor) {
        return configModel.rightChatTextColor;
    }
    return UIColorFromRGB(0xfff9fb);
}


+(UIColor *)zcgetTimeTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.timeTextColor) {
        return configModel.timeTextColor;
    }
    return UIColorFromRGB(TextTimeColor);
}


+(UIColor *)zcgetTipLayerTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.tipLayerTextColor) {
        return configModel.tipLayerTextColor;
    }
    return UIColorFromRGB(TextTopColor);
}


+(UIColor *)zcgetServiceNameTextColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.serviceNameTextColor) {
        return configModel.serviceNameTextColor;
    }
    return UIColorFromRGB(TextNameColor);
}

+(UIColor *)zcgetNickNameColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.nickNameTextColor) {
        return configModel.nickNameTextColor;
    }
    return UIColorFromRGB(RClabelNickColor);
}


+(UIColor *)zcgetChatLeftLinkColor{
    
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.chatLeftLinkColor) {
        return configModel.chatLeftLinkColor;
    }
    return  UIColorFromRGB(RCLabelLinkColor);
}


+(UIColor *)zcgetChatRightlinkColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.chatRightLinkColor) {
        return configModel.chatRightLinkColor;
    }
    return  UIColorFromRGB(RCLabelRLinkColor);
}


+(UIColor *)zcgetChatRightVideoSelBgColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.videoCellBgSelColor) {
        return configModel.videoCellBgSelColor;
    }
    return  UIColorFromRGB(BgVideoCellSelColor);
}


+(UIColor *)zcgetLineRichColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.LineRichColor) {
        return configModel.LineRichColor;
    }
    return  UIColorFromRGB(LineRichColot);
}



+(UIColor *)getNotifitionTopViewBgColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.notificationTopViewBgColor) {
        return configModel.notificationTopViewBgColor;
    }
    return  UIColorFromRGB(notificationBgColor);
}


+(UIColor *)getNotifitionTopViewLabelColor{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.notificationTopViewLabelColor) {
        return configModel.notificationTopViewLabelColor;
    }
    return  UIColorFromRGB(TextWhiteColor);
}


+(UIFont *)zcgetNotifitionTopViewFont{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.notificationTopViewLabelFont) {
        return configModel.notificationTopViewLabelFont;
    }
    return ListTitleFont;
}

//+(NSString *)zcgetLinkColor:(BOOL) isRight{
//    if(isRight){
//        return RCLabelRLinkColor;
//    }
//    NSString *stringColor = [[ZCLibServer sharedZCLibServer] getZCLibConfig].color;
//    if (zcLibConvertToString(stringColor).length>4) {
//        return stringColor;
//    }
//    return RCLabelLinkColor;
//}



//检查是否有相册的权限
+(BOOL)isHasPhotoLibraryAuthorization{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied)
    {
        return NO;
    }
    return YES;
}
//检测是否有相机的权限
+(BOOL)isHasCaptureDeviceAuthorization{
    if (iOS7) {
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
            return NO;
        }
        return YES;
    }else{
        return YES;
    }
}



/**
 war获取录音设置
 @returns 录音设置
 */
+ (NSDictionary*)getAudioRecorderSettingDict
{
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey, //采样率
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt: 16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
                                   [NSNumber numberWithInt: AVAudioQualityMedium],AVEncoderAudioQualityKey,//音频编码质量
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,//大端还是小端 是内存的组织方式
                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,//采样信号是整数还是浮点数
                                   nil];
    return recordSetting;
}

+(BOOL)isOpenVoicePermissions{
    __block BOOL isOpen = NO;
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    if ([avSession respondsToSelector:@selector(requestRecordPermission:)]) {
        
      
        [avSession requestRecordPermission:^(BOOL available) {
            
            if (available) {
//                NSLog(@"语音权限开启");
                isOpen = YES;
            }
            else
            {
                isOpen = NO;
                
            }
        }];
        
    }

    return isOpen;
}

+ (UIColor *)getColor:(NSString *)hexColor
{
    if(hexColor!=nil && hexColor.length>6){
        hexColor=[hexColor stringByReplacingOccurrencesOfString:@"#" withString:@""];
    }
    
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    range.location = 0;
    
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:1.0f];
}



+ (int)IntervalDay:(NSString *)filePath
{
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    // [ZCLogUtils logHeader:LogHeader debug:@"create date:%@",[attributes fileModificationDate]];
    NSString *dateString = [NSString stringWithFormat:@"%@",[attributes fileModificationDate]];
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    
    NSDate *formatterDate = [inputFormatter dateFromString:dateString];
    
    // 矫正时区
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: formatterDate];
    NSDate *localeDate = [formatterDate  dateByAddingTimeInterval: interval];
    
    unsigned int unitFlags = NSDayCalendarUnit;
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *d = [cal components:unitFlags fromDate:localeDate toDate:[NSDate date] options:0];
    
    
    // [ZCLogUtils logHeader:LogHeader debug:@"%d,%d,%d,%d",[d year],[d day],[d hour],[d minute]];
    
    int result = (int)d.day;
    
    //	return 0;
    return result;
}


#define imageVALIDMINUTES 3
#define voiceVALIDMINUTES 3
+(BOOL)imageIsValid:(NSString *)filePath{
    if ([self IntervalDay:filePath] < imageVALIDMINUTES) { //VALIDDAYS = 有效时间分钟
        return YES;
    }
    return NO;
}

+(BOOL)videoIsValid:(NSString *)filePath{
    if ([self IntervalDay:filePath] < voiceVALIDMINUTES) { //VALIDDAYS = 有效时间分钟
        return YES;
    }
    return NO;
}


+ (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth withView:(UIView *) view{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, view.frame.size.width, borderWidth);
    [view.layer addSublayer:border];
}

+ (void)addTopBorderWithColor:(UIColor *)color andWidth:(CGFloat)borderWidth andViewWidth:(CGFloat)viewWidth withView:(UIView *) view{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, viewWidth, borderWidth);
    [view.layer addSublayer:border];
}

+ (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth withView:(UIView *) view {
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    border.frame = CGRectMake(0, view.frame.size.height - borderWidth, view.frame.size.width, borderWidth);
    border.name=@"border";
    [view.layer addSublayer:border];
}
+ (void)addBottomBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth andViewWidth:(CGFloat)viewWidth withView:(UIView *) view{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    border.frame = CGRectMake(0, view.frame.size.height - borderWidth, viewWidth, borderWidth);
    border.name=@"border";
    [view.layer addSublayer:border];
}
+ (void)addLeftBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth  withView:(UIView *) view{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(0, 0, borderWidth, view.frame.size.height);
    [view.layer addSublayer:border];
}

+ (void)addRightBorderWithColor:(UIColor *)color andWidth:(CGFloat) borderWidth  withView:(UIView *) view{
    CALayer *border = [CALayer layer];
    border.backgroundColor = color.CGColor;
    
    border.frame = CGRectMake(view.frame.size.width - borderWidth, 0, borderWidth, view.frame.size.height);
    [view.layer addSublayer:border];
}


+(void)zcShakeView:(UIView*)viewToShake
{
    CGFloat t =2.0;
    CGAffineTransform translateRight  =CGAffineTransformTranslate(CGAffineTransformIdentity, t,0.0);
    CGAffineTransform translateLeft =CGAffineTransformTranslate(CGAffineTransformIdentity,-t,0.0);
    
    viewToShake.transform = translateLeft;
    
    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:2.0];
        viewToShake.transform = translateRight;
    } completion:^(BOOL finished){
        if(finished){
            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                viewToShake.transform =CGAffineTransformIdentity;
            } completion:NULL];
        }
    }];
}


+ (NSString *)zcTransformString:(NSString *)originalStr{
    NSString *text = originalStr;
    
    //解析http://短链接
    NSString *regex_http = @"(http(s)?://|www)([a-zA-Z|\\d]+\\.)+[a-zA-Z|\\d]+(/[a-zA-Z|\\d|\\-|\\+|_./?%&=]*)?";//http://短链接正则表达式
    
//        NSString *regex_http = @"http(s)?://[^\\s()<>]+(?:\\([\\w\\d]+\\)|(?:[^\\p{Punct}\\s]|/))+[a-zA-Z|\\d]+(/[a-zA-Z|\\d|\\-|\\+|_./?%&=]*)?";
    // 识别 www.的链接
//    NSString *regex_http =@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    
    NSString *regex_text=[NSString stringWithFormat:@"%@(?![^<]*>)(?![^>]*<)",regex_http];
    //    NSArray *array_http = [text componentsMatchedByRegex:regex_text];
    
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regex_text
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:originalStr options:0 range:NSMakeRange(0, [originalStr length])];
    
    NSInteger len = 0;
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        
        NSRange range = match.range;
        NSString* substringForMatch = [originalStr substringWithRange:range];
        
        //[ZCLogUtils logHeader:LogHeader debug:@"%@,%@",NSStringFromRange(range),substringForMatch];
        
        NSString *funUrlStr = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>",substringForMatch, substringForMatch];
        text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location+len, substringForMatch.length) withString:funUrlStr];
        len = 15+substringForMatch.length;
    }
    
    
    
    //解析表情
    NSString *tempText = text;
    NSError *err = nil;
    // 替换掉atuser后的text
    regex = [NSRegularExpression regularExpressionWithPattern:@"\\[(.*?)\\]" options:0 error:&err];
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    NSInteger mxLength = 0;
    
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = match.range;
        NSString  *key=[text substringWithRange:wordRange];
        if([[[ZCUIConfigManager getInstance] allExpressionDict] objectForKey:key]){
            NSString *imgText = [NSString stringWithFormat:@"<img src=%@.png>",[[[ZCUIConfigManager getInstance] allExpressionDict] objectForKey:key]];
            tempText = [tempText stringByReplacingOccurrencesOfString:key withString:imgText options:0 range:NSMakeRange(wordRange.location+mxLength, wordRange.length)];
            mxLength = mxLength + (imgText.length - key.length);
            
        }
    }
    text = tempText;
    
//    NSLog(@"%@",text);
    //返回转义后的字符串
    return text;
}

+ (NSString *)zcAddTransformString:(NSString *)contentText{
    NSString *text = contentText;
    // 识别 www.的链接
        NSString *regex_http = @"(http(s)?://|www)([a-zA-Z|\\d]+\\.)+[a-zA-Z|\\d]+(/[a-zA-Z|\\d|\\-|\\+|_./?%&=]*)?";//http://短链接正则表达式
    
     NSString *regex_text=[NSString stringWithFormat:@"%@(?![^<]*>)(?![^>]*<)|([a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$^&*+?%%:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$^&*+?%%:_/=<>]*)?)",regex_http];
    
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regex_text
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:contentText options:0 range:NSMakeRange(0, [contentText length])];
    
    NSInteger len = 0;
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        
        NSRange range = match.range;
        NSString* substringForMatch = [contentText substringWithRange:range];
        
        [ZCLogUtils logHeader:LogHeader debug:@"%@,%@",NSStringFromRange(range),substringForMatch];

        
        NSString *funUrlStr = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>",substringForMatch, substringForMatch];
        text = [text stringByReplacingCharactersInRange:NSMakeRange(range.location+len, substringForMatch.length) withString:funUrlStr];
        len = 15+substringForMatch.length;
    }
    
    //    NSLog(@"%@",text);
    //解析表情
    NSString *tempText = text;
    NSError *err = nil;
    // 替换掉atuser后的text
    regex = [NSRegularExpression regularExpressionWithPattern:@"\\[(.*?)\\]" options:0 error:&err];
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    NSInteger mxLength = 0;
    
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = match.range;
        NSString  *key=[text substringWithRange:wordRange];
        if([[[ZCUIConfigManager getInstance] allExpressionDict] objectForKey:key]){
            NSString *imgText = [NSString stringWithFormat:@"<img src=%@.png>",[[[ZCUIConfigManager getInstance] allExpressionDict] objectForKey:key]];
            tempText = [tempText stringByReplacingOccurrencesOfString:key withString:imgText options:0 range:NSMakeRange(wordRange.location+mxLength, wordRange.length)];
            mxLength = mxLength + (imgText.length - key.length);
            
        }
    }
    text = tempText;
//    NSLog(@"%@",text);
    
    //返回转义后的字符串
    return text;
}

#pragma mark- 获取商品/订单 相关属性
/**
 商品/订单号

 @return 商品/订单号 字体和颜色
 */
+ (UIFont *)knbGetOrderNumberLabelFont{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.orderNumberLabelFont) {
        return configModel.orderNumberLabelFont;
    }
    return TitleGoodsFont;
}
+ (UIColor *)knbGetOrderNumberLabelColor{
    ZCKitInfo * configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.orderNumberLabelColor) {
        return configModel.orderNumberLabelColor;
    }
    return UIColorFromRGB(TextBlackColor);
}

/**
 商品/订单状态

 @return 商品/订单状态 字体和颜色
 */
+ (UIFont *)knbGetOrderStateLabelFont{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.orderStateLabelFont) {
        return configModel.orderStateLabelFont;
    }
    return TitleGoodsFont;
}
+ (UIColor *)knbGetOrderStateLabelColor{
    ZCKitInfo * configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.orderStateLabelColor) {
        return configModel.orderStateLabelColor;
    }
    return UIColorFromRGB(TextBlackColor);
}
/**
 商品/订单价钱 字体和颜色
 */
+ (UIFont *)knbGetGoodsPriceLabelFont{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.goodsPriceLabelFont) {
        return configModel.goodsPriceLabelFont;
    }
    return TitleGoodsFont;
}
+ (UIColor *)knbGetGoodsPriceLabelColor{
    ZCKitInfo * configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.goodsPriceLabelColor) {
        return configModel.goodsPriceLabelColor;
    }
    return UIColorFromRGB(TextBlackColor);
}
/**
 商品/订单日期 字体和颜色
 */
+ (UIFont *)knbGetOrderDateLabelFont{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.orderDateLabelFont) {
        return configModel.orderDateLabelFont;
    }
    return TitleGoodsFont;
}
+ (UIColor *)knbGetOrderDateLabelColor{
    ZCKitInfo * configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.orderDateLabelColor) {
        return configModel.orderDateLabelColor;
    }
    return UIColorFromRGB(TextBlackColor);
}
/**
 商品/订单描述 字体和颜色
 */
+ (UIFont *)knbGetGoodsTitleLabelFont{
    ZCKitInfo *configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.goodsTitleLabelFont) {
        return configModel.goodsTitleLabelFont;
    }
    return TitleGoodsFont;
}
+ (UIColor *)knbGetGoodsTitleLabelColor{
    ZCKitInfo * configModel = [self getZCKitInfo];
    if (configModel != nil && configModel.goodsTitleLabelColor) {
        return configModel.goodsTitleLabelColor;
    }
    return UIColorFromRGB(TextBlackColor);
}


@end
