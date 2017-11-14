//
//  ZCOrderCusFieldController.m
//  SobotApp
//
//  Created by zhangxy on 2017/7/21.
//  Copyright © 2017年 com.sobot.chat.app. All rights reserved.
//

#import "ZCOrderCusFieldController.h"

//#import "ZCOrderCustomCell.h"

#import "ZCUIColorsDefine.h"

#import "ZCLIbGlobalDefine.h"

#import "ZCLibOrderCusFieldsModel.h"

#define cellIdentifier @"ZCUITableViewCell"


@interface ZCOrderCusFieldController ()<UITableViewDelegate,UITableViewDataSource>{
    
    NSMutableDictionary *checkDict;
    
}
@property(nonatomic,strong) UITableView *listTable;
@property(nonatomic,strong) NSMutableArray *mulArr;

@end

@implementation ZCOrderCusFieldController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createTitleView];
    [self.moreButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.moreButton setImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, NavBarHeight, ScreenWidth, ScreenHeight - NavBarHeight) style:UITableViewStylePlain];
    _listTable.delegate = self;
    _listTable.dataSource = self;
    [self.view addSubview:_listTable];
    [_listTable setBackgroundColor:UIColorFromRGB(BgSystemColor)];
    UIView * bgview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 100)];
    bgview.backgroundColor = UIColorFromRGB(0xEFF3FA);
    _listTable.tableFooterView = bgview;
    
    
    [_listTable setSeparatorColor:UIColorFromRGB(0xdce0e5)];
    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    
    [self setTableSeparatorInset];
    
    if(!zcLibIs_null(_preModel) && [_preModel.fieldType intValue] == 7){
        _mulArr = [NSMutableArray arrayWithCapacity:0];
        for (ZCLibOrderCusFieldsDetailModel *model in _preModel.detailArray) {
            if (model.isChecked) {
                [_mulArr addObject:model];
            }
        }
        
        self.moreButton.hidden = NO;
        [self.moreButton setTitle:@"提交" forState:UIControlStateNormal];
        
    }
    _listArray = _preModel.detailArray;
    checkDict  = [NSMutableDictionary dictionaryWithCapacity:0];
    if(!zcLibIs_null(_listArray)){
        [_listTable reloadData];
    }
}

-(void)buttonClick:(UIButton *)sender{
//    [super buttonClick:sender];
    if(sender.tag == BUTTON_MORE){
        if(_orderCusFiledCheckBlock){
            _orderCusFiledCheckBlock(nil,_mulArr);
        }

    }

    [self.navigationController popViewControllerAnimated:YES];
    
}

/**
 *  设置UITableView分割线空隙
 */
-(void)setTableSeparatorInset{
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 10, 0, 0);
    if ([_listTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [_listTable setSeparatorInset:inset];
    }
    
    if ([_listTable respondsToSelector:@selector(setLayoutMargins:)]) {
        [_listTable setLayoutMargins:inset];
    }
}


#pragma mark -- tableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if(indexPath.row==_listArray.count-1){
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        
        if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
    }
    
//        [cell setSelectedBackgroundView:[[UIView alloc] initWithFrame:cell.bounds]];
//        [cell.selectedBackgroundView setBackgroundColor:UIColorFromRGB(LineListColor)];
    if(_listArray.count < indexPath.row){
        return cell;
    }
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [cell.contentView addSubview:imageView];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, ScreenWidth - 50, 21)];
    textLabel.font = DetGoodsFont;
    textLabel.textColor = UIColorFromRGB(TextWordOrderListNolTextColor);
    [cell.contentView addSubview:textLabel];
    
    
    ZCLibOrderCusFieldsDetailModel *model = [_listArray objectAtIndex:indexPath.row];
    
    textLabel.text = model.dataName;
    
    
    CGRect imgf = imageView.frame;
    
    imgf.size = CGSizeMake(14, 14);
    
    
    if (!zcLibIs_null(_preModel) && [_preModel.fieldType intValue] == 7) {
        
        if (model.isChecked) {
            imageView.image =  [ZCUITools zcuiGetBundleImage:@"ZCIcon_app_Moreselected_sel"];

        }else{
            imageView.image =  [ZCUITools zcuiGetBundleImage:@"ZCIcon_app_Moreselected_nol"];
        }
        imgf.origin.x = 15;
        imgf.origin.y = (44 - imgf.size.height)/2;
        
        CGRect titleF = textLabel.frame;
        titleF.origin.x = 39;
        titleF.size.width = ScreenWidth - 39-20;//20为右间距
        textLabel.frame = titleF;
        
    }else{
        
        if([model.dataValue isEqual:_preModel.fieldSaveValue]){
            imageView.image = [ZCUITools zcuiGetBundleImage:@"icon_ordertype_sel"];
        }
        
        imgf.origin.x = ScreenWidth - imgf.size.width - 15;
        imgf.origin.y = (44 - imgf.size.height)/2;
    }
    
    
    imageView.frame = imgf;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ZCLibOrderCusFieldsDetailModel *model = [_listArray objectAtIndex:indexPath.row];
    
    
    if([_preModel.fieldType intValue] != 7){
        if(_orderCusFiledCheckBlock){
            _orderCusFiledCheckBlock(model,_mulArr);
        }

        [self.navigationController popViewControllerAnimated:YES];
        
    }else{
        // 复选框
        if(model.isChecked){
            model.isChecked = NO;
            [_mulArr removeObject:model];
        }else{
            model.isChecked = YES;
            [_mulArr addObject:model];
        }
        [_listTable reloadData];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
