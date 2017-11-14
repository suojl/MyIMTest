//
//  ViewController.m
//  MyIMTest
//
//  Created by suojl on 2017/11/9.
//  Copyright © 2017年 com.dengyun. All rights reserved.
//

#import "ViewController.h"
#import <SobotKit/SobotKit.h>
#import <UserNotifications/UserNotifications.h>


#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.


}
- (IBAction)btnClick:(id)sender {
    ZCLibInitInfo *initInfo = [ZCLibInitInfo new];

#pragma mark 设置默认APPKEY
    initInfo.appKey         = @"6daf80b9ba1b48ed90f4c80f88bc3ab0";
    //    initInfo.appKey = @"11ca04926d4449e1a827349b153f37d7";
    //    initInfo.userId         =  @"1019728";
    initInfo.userId = @"1007391";
    //    initInfo.serviceMode    = 4;
    // 组ID: 0abc24fed103436285cb9d3e40a9525f
    // 客服ID: 060001d0527d4996bfdb7a843b53c2ac
    //    initInfo.skillSetId = @"";
    //    initInfo.skillSetName = @"";
    //    initInfo.receptionistId = @"";
    //    initInfo.titleType = @"2";
    initInfo.nickName = @"小锁";
    initInfo.userSex = @"0";
    //    initInfo.zx = @"自定义字段测试";

    // 设置用户信息参数
    [self customUserInformationWith:initInfo];

    ZCKitInfo *uiInfo=[ZCKitInfo new];
    uiInfo.isCloseAfterEvaluation = YES;
    // 点击返回是否触发满意度评价（符合评价逻辑的前提下）
    uiInfo.isOpenEvaluation = YES;

    /**   设置订单查询接口   **/

    // 设置md5加密格式
    //    uiInfo.md5MixPrefix = @"blln";
    //    uiInfo.md5MixPostfix = @"blln";
    //    uiInfo.versioNumber = @"1.3.0";
    ////    // 设置订单查询接口
    //    uiInfo.queryOrderListForKF = @"http://10.10.8.22:9214/blln-app/order/queryOrderListForKF.do";

    uiInfo.md5MixPrefix = @"mtmy";
    uiInfo.md5MixPostfix = @"mtmy";
    uiInfo.versioNumber = @"1.3.0";
    uiInfo.orderStatusFlag = @"5";
    //    // 设置订单查询接口http://60.205.112.197/mtmy-app/queryMyOrder150.do
    uiInfo.queryOrderListForKF = @"http://60.205.112.197/mtmy-app/order/queryMyOrder150.do";

    /**   ----------------------END----------------------   **/

    [self customUnReadNumber:uiInfo];

    //     切换服务器地址，默认https://api.sobot.com
    uiInfo.apiHost = @"http://www.baidu.com";

    // 测试模式
    [ZCSobot setShowDebug:NO];

    [self customerGoodAndLeavePageWithParameter:uiInfo];
    // 关键设置，必须设置了参数才生效
    [[ZCLibClient getZCLibClient] setLibInitInfo:initInfo];
    NSLog(@"----%@",[[NSBundle mainBundle] pathForResource:@"SobotKit" ofType: @"bundle"]);
    // 启动
    [ZCSobot startZCChatView:uiInfo with:self target:nil pageBlock:^(ZCUIChatController *object, ZCPageBlockType type) {
        // 点击返回
        if(type==ZCPageBlockGoBack){
            NSLog(@"点击了关闭按钮");

            //            [[ZCLibClient getZCLibClient] removePush:^(NSString *uid, NSData *token, NSError *error) {
            //                NSLog(@"退出了,%@==%@",uid,error);
            //            }];
        }

        // 页面UI初始化完成，可以获取UIView，自定义UI
        if(type==ZCPageBlockLoadFinish){
            NSLog(@"啦啦啦啦阿拉啦");
        }
    } messageLinkClick:nil];
}

// 设置用户信息参数
- (void)customUserInformationWith:(ZCLibInitInfo *)initInfo{

    //    initInfo.customInfo = @{@"标题1":@"自定义1",@"内容1":@"我是一个自定义字段。",@"标题2":@"自定义字段2",@"内容2":@"我是一个自定义字段，我是一个自定义字段，我是一个自定义字段，我是一个自定义字段。",@"标题3":@"自定义字段字段3",@"内容3":@"<a href=\"www.baidu.com\" target=\"_blank\">www.baidu.com</a>",@"标题4":@"自定义4",@"内容4":@"我是一个自定义字段 https://www.sobot.com/chat/pc/index.html?sysNum=9379837c87d2475dadd953940f0c3bc8&partnerId=112"};
    initInfo.customInfo = @{

                            @"zx":@"自定义1",
                            @"内容1":@"我是一个自定义字段。",
                            @"标题2":@"自定义字段2",
                            @"AppAcronym":@"blln"
                            };
    initInfo.customerFields = @{@"customField1":@"自定义字段"};

}


// 自定义参数 商品信息相关
- (void)customerGoodAndLeavePageWithParameter:(ZCKitInfo *)uiInfo{

    ZCProductInfo *productInfo = [ZCProductInfo new];
    productInfo.thumbUrl = @"http://f12.baidu.com/it/u=3087422712,1174175413&fm=72";
    productInfo.title = @"我是商品标题我是商品标题我是商品标题我是商品标题";
    productInfo.desc = @"商品描述商品描述商品描述商品描述商品描述商品描述商品描述";
    productInfo.label = @"商品标签，价格、分类等商品标签，价格、分类等";
    productInfo.link = @"http://f12.baidu.com/it/u=3087422712,1174175413&fm=72";
    productInfo.testAdd = @"自定义的添加字段";
    uiInfo.productInfo = productInfo;

    KNBGoodsInfo *goodsInfo = [KNBGoodsInfo new];
    goodsInfo.orderNumber = @"fads49534959032234";
    goodsInfo.orderState = @"待收货";
    goodsInfo.orderDate = @"2017-01-23";
    goodsInfo.goodsTitle = @"卡萨丁佛闻风丧胆";
    goodsInfo.goodsPrice = @"2434535";
    goodsInfo.goodsImgUrl = @"http://f12.baidu.com/it/u=3087422712,1174175413&fm=72";
    goodsInfo.cardType = @"商品";
    uiInfo.orderGoodsInfo = goodsInfo;

    //mtmy订单状态（-2：取消订单；-1：待付款；1：待发货；2：待收货；3：已退款（退货并退款使用）；4：已完成；）
    //blln定制订单状态（-2：取消订单；-1：待支付；1：待量体；2：量体完成；3：待审核；4：打版；
    //5：裁剪；6：制作；7：质检；8：快递；9：试穿；10：待评价；11：完成）
    NSDictionary *mtmyOrderDictionary = @{
                                          @"-2":@"已取消",
                                          @"-1":@"待付款",
                                          @"1":@"待发货",
                                          @"2":@"待收货",
                                          @"3":@"已退款",
                                          @"4":@"已完成"
                                          };
    NSDictionary *bllnOrderDictionary = @{
                                          @"-2":@"已取消",
                                          @"-1":@"待支付",
                                          @"1":@"待量体",
                                          @"2":@"已量体",
                                          @"3":@"待审核",
                                          @"4":@"打版",
                                          @"5":@"裁剪",
                                          @"6":@"制作",
                                          @"7":@"质检",
                                          @"8":@"快递",
                                          @"9":@"试穿",
                                          @"10":@"待评价",
                                          @"11":@"已完成"
                                          };
    uiInfo.orderStateDictionary = mtmyOrderDictionary;
}


// 未读消息数
- (void)customUnReadNumber:(ZCKitInfo *)uiInfo{

    // [[ZCLibClient getZCLibClient] setAutoNotification:YES];



    [ZCLibClient getZCLibClient].receivedBlock = ^(id obj,int unRead){
        NSLog(@"当前消息数：%d \n %@",unRead,obj);

        if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
            [self registerNotification:(NSString *)obj];
        }else{
            [self registerLocalNotificationInOldWay:(NSString *)obj];
        }

    };

}


//使用 iOS 10 UNNotification 本地通知
-(void)registerNotification:(NSString *)message{
    //需创建一个包含待通知内容的 UNMutableNotificationContent 对象，注意不是 UNNotificationContent ,此对象为不可变对象。
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    //    content.title = [NSString localizedUserNotificationStringForKey:@"新消息" arguments:nil];
    content.body = message;
    content.sound = [UNNotificationSound defaultSound];

    // 在 alertTime 后推送本地推送
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
                                                  triggerWithTimeInterval:1 repeats:NO];

    NSString *identifier = [NSString stringWithFormat:@"www.sobot.com%f",[[NSDate date] timeIntervalSinceNow]];
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:identifier
                                                                          content:content trigger:trigger];

    //添加推送成功后的处理！
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        //        NSLog(@"%@",error);
        //        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"本地通知" message:@"成功添加推送" preferredStyle:UIAlertControllerStyleAlert];
        //        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        //        [alert addAction:cancelAction];
        //        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    }];
}

- (void)registerLocalNotificationInOldWay:(NSString *) message {
    // ios8后，需要添加这个注册，才能得到授权
    // if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
    // UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
    // UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
    // categories:nil];
    // [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    // // 通知重复提示的单位，可以是天、周、月
    // }

    UILocalNotification *notification = [[UILocalNotification alloc] init];
    // 设置触发通知的时间
    notification.fireDate = [NSDate date];
    // 时区
    notification.timeZone = [NSTimeZone defaultTimeZone];
    // 设置重复的间隔
    notification.repeatInterval = kCFCalendarUnitSecond;

    // 通知内容
    notification.alertBody = message;
    notification.applicationIconBadgeNumber = 0;
    // 通知被触发时播放的声音
    notification.soundName = UILocalNotificationDefaultSoundName;
    // 通知参数
    NSString *identifier = [NSString stringWithFormat:@"www.sobot.com%f",[[NSDate date] timeIntervalSinceNow]];
    NSDictionary *userDict = [NSDictionary dictionaryWithObject:identifier forKey:@"pushType"];
    notification.userInfo = userDict;
    // 通知重复提示的单位，可以是天、周、月
    notification.repeatInterval = 0;

    // 执行通知注册
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];

}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{

    if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationMaskPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown)
    NSLog(@"\nvc=%zd\ndivice=%zd\napp=%zd",self.interfaceOrientation,[[UIDevice currentDevice] orientation],[[UIApplication sharedApplication] statusBarOrientation]);

    if([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown){
        NSLog(@" 竖排");
    }else{
        NSLog(@"横屏");
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
