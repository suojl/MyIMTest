//
//  KNBOrderViewController.m
//  SobotKit
//
//  Created by suojl on 2017/11/1.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "KNBOrderViewController.h"
//#import "UIView+SDAutoLayout.h"
#import "ZCUIColorsDefine.h"
#import "ZCLIbGlobalDefine.h"
#import "KNBHistoryOrderCell.h"
#import "AFNetworking.h"
#import "KNBOrderInfo.h"
#import "NSObject+YYModel.h"
#import "ZCLibClient.h"
#import "ZCUIConfigManager.h"

#define kHistoryOrderCell @"KNBHistoryOrderCell"

@interface KNBOrderViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UILabel     *_titleLabel;       // 显示标题
    UIButton    *_closeBtn;         // 关闭按钮

    NSMutableArray  *_goodsInfoArray;
}

@end

@implementation KNBOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    _goodsInfoArray = [[NSMutableArray alloc] initWithCapacity:10];

    [self getDatasourceByNetwork];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/**
 初始化UI界面
 */
-(void)setupUI{
    CGFloat viewWidth = self.view.frame.size.width;
//    CGFloat viewHeight = self.view.frame.size.height;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, 45)];
    [_topView setBackgroundColor:UIColorFromRGB(0xffffff)];
    _topView.layer.borderWidth = 1.0f;
    _topView.layer.borderColor = UIColorFromRGB(0xe6e7e5).CGColor;
    [self.view addSubview:_topView];

    // 初始化订单TableView
    _orderTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 45, ScreenWidth, 227) style:UITableViewStylePlain];
    _orderTableView.delegate = self;
    _orderTableView.dataSource = self;
//    [_orderTableView setSeparatorColor:UIColorFromRGB(0xe6e7e5)];
    [_orderTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [_orderTableView registerClass:[KNBHistoryOrderCell class] forCellReuseIdentifier:kHistoryOrderCell];
    _orderTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_orderTableView];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:14];
    _titleLabel.numberOfLines = 1;
    _titleLabel.text = @"请点击想要发送的订单";
    _titleLabel.textColor = UIColorFromRGB(0x999999);
    _titleLabel.frame = CGRectMake(15, 15, ScreenWidth - 45, 15);
    [self.topView addSubview:_titleLabel];

    _closeBtn = [[UIButton alloc] init];
    [_closeBtn setImage:[ZCUITools knbUiGetBundleImage:@"KeFu_close"] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_closeBtn setFrame:CGRectMake(ScreenWidth - 30, 15, 15, 15)];
    [self.topView addSubview:_closeBtn];

    // 布局界面frame
//    _titleLabel.sd_layout.leftSpaceToView(_topView, 15).centerYEqualToView(_topView)
//    .widthIs(ScreenWidth - 45).heightIs(15);
//    _closeBtn.sd_layout.rightSpaceToView(_topView, 15).centerYEqualToView(_topView)
//    .widthIs(15).heightIs(15);

}

-(void)getDatasourceByNetwork{

    NSString *versionNumber = [ZCUIConfigManager getInstance].kitInfo.versioNumber;
    NSString *orderStatusFlag = [ZCUIConfigManager getInstance].kitInfo.orderStatusFlag;
    NSString *md5MixPrefix = [ZCUIConfigManager getInstance].kitInfo.md5MixPrefix;
    NSString *md5MixPostfix = [ZCUIConfigManager getInstance].kitInfo.md5MixPostfix;
    NSString *requestURL =  [ZCUIConfigManager getInstance].kitInfo.queryOrderListForKF;
//    NSString * requestURL = @"http://10.10.8.22:9214/blln-app/order/queryOrderListForKF.do";

    NSString *userId = [ZCLibClient getZCLibClient].libInitInfo.userId;

    NSString *paramters = [NSString stringWithFormat:@"{\"version\" : \"%@\", \"flag\" : %@, \"user_id\" : %@, \"page\" : 1}",versionNumber,orderStatusFlag,userId];
    NSString *paramterString = [NSString stringWithFormat:@"%@%@%@",md5MixPrefix,paramters,md5MixPostfix];
    NSString *signMd5String = zcLibMd5(paramterString);
    NSString *jsonParamters = [NSString stringWithFormat:@"%@%@",md5MixPrefix,paramters];


    AFHTTPSessionManager *sessionManager = [AFHTTPSessionManager manager];
    sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];

//    NSString *requestURL =  [ZCUIConfigManager getInstance].kitInfo.queryOrderListForKF;
//    NSString *jsonParamters = [ZCUIConfigManager getInstance].kitInfo.jsonRequestParamters;
//    NSString *signMd5String = [ZCUIConfigManager getInstance].kitInfo.signMd5String;
    NSDictionary *parameters = @{@"sign": signMd5String,
                                 @"jsonStr": jsonParamters};
    NSLog(@"----%@",signMd5String);
    NSLog(@"----%@",jsonParamters);
    [sessionManager POST:requestURL parameters:parameters progress:nil
                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

                     KNBQueryBackInfo *orderData = [KNBQueryBackInfo yy_modelWithJSON:responseObject];

                     NSArray<KNBOrderInfo *> *orderArray = orderData.data;

                     for (KNBOrderInfo *orderInfo in orderArray) {
                         for (KNBGoodsInfo *goodsInfo in orderInfo.goodsList) {
                             goodsInfo.orderNumber = orderInfo.orderNo;
                             goodsInfo.orderDate = orderInfo.createData;
                             goodsInfo.orderId = orderInfo.orderId;
                             goodsInfo.orderState = [NSString stringWithFormat:@"%ld",(long)orderInfo.orderStatus];
                             [_goodsInfoArray addObject:goodsInfo];
                         }
                     }
                     NSLog(@"----%@",responseObject);
                     [self.orderTableView reloadData];
                 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                     DLog(@"----%@",error);
                 }];
}
-(void)closeBtnClick:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _goodsInfoArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    KNBHistoryOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:kHistoryOrderCell];
    if (cell == nil) {
        cell = [[KNBHistoryOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHistoryOrderCell];
    }
    cell.goodsInfo = [_goodsInfoArray objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    KNBGoodsInfo *goodsInfo = [_goodsInfoArray objectAtIndex:indexPath.row];
    NSString *sendMessageString = [self makeGoodsToMessage:goodsInfo];
    if (self.vcDelegate && [self.vcDelegate respondsToSelector:@selector(dismissViewController:andSendOrderMessage:)]) {
        [self.vcDelegate dismissViewController:self andSendOrderMessage:sendMessageString];
    }
}
#pragma mark- UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 113;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = UIColorFromRGB(0xe6e7e5);
    return bottomView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

-(NSString *)makeGoodsToMessage:(KNBGoodsInfo *)goodsInfo{
//        [消息类型]:[123]
//        [订单编号]:[18264532919127139187478]
//        [商品编号]:[023823]
//        [订单状态]:[代收货]
//        [商品首图]:[http://f12.baidu.com/it/u=3087422712,1174175413&fm=72]
//        [商品金额]:[1232323]
//        [订单日期]:[2017-10-23]
    NSString *contextStr = @"[消息类型]:[订单]\n";
    contextStr = [contextStr stringByAppendingFormat:@"[订单编号]:[%@]\n",goodsInfo.orderNumber];
    contextStr = [contextStr stringByAppendingFormat:@"[订单状态]:[%@]\n",goodsInfo.orderState];
    contextStr = [contextStr stringByAppendingFormat:@"[下单时间]:[%@]\n",goodsInfo.orderDate];
    contextStr = [contextStr stringByAppendingFormat:@"[商品名称]:[%@]\n",goodsInfo.goodsTitle];
    contextStr = [contextStr stringByAppendingFormat:@"[商品价格]:[%@]\n",goodsInfo.goodsPrice];
    contextStr = [contextStr stringByAppendingFormat:@"[商品首图]:[%@]",goodsInfo.goodsImgUrl];

    return contextStr;
}

@end
