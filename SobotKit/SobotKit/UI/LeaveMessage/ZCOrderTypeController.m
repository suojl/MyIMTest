//
//  ZCOrderTypeController.m
//  SobotApp
//
//  Created by zhangxy on 2017/7/18.
//  Copyright © 2017年 com.sobot.chat.app. All rights reserved.
//

#import "ZCOrderTypeController.h"
#import "ZCUIColorsDefine.h"
#import "ZCLIbGlobalDefine.h"

#define cellIdentifier @"ZCUITableViewCell"


@interface ZCOrderTypeController ()<UITableViewDelegate,UITableViewDataSource>


@property(nonatomic,strong)UITableView      *listTable;


@end

@implementation ZCOrderTypeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self createTitleMenu];
    [self createTitleView];
    if([@"" isEqual:zcLibConvertToString(_pageTitle)]){
        self.titleLabel.text = @"选择分类";
    }else{
        self.titleLabel.text = _pageTitle;
    }
    [self.backButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.backButton setTitle:@" 返回" forState:UIControlStateNormal];
    [self.moreButton setHidden:YES];
    [self createTableView];
    if([@"" isEqual:zcLibConvertToString(_typeId)]){
        _typeId = @"-1";
    }
//    [self loadMoreData];
}

-(void)buttonClick:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)createTableView{
    
    
    _listTable = [[UITableView alloc]initWithFrame:CGRectMake(0, NavBarHeight, ScreenWidth, ScreenHeight - NavBarHeight) style:UITableViewStylePlain];
    _listTable.delegate = self;
    _listTable.dataSource = self;
    [self.view addSubview:_listTable];
    
    [_listTable setBackgroundColor:UIColorFromRGB(BgSystemColor)];
    
    if (iOS7) {
        _listTable.backgroundView = nil;
    }
    
    [_listTable setSeparatorColor:UIColorFromRGB(0xdce0e5)];
    [_listTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [self setTableSeparatorInset];
    
    UIView * bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 100)];
    bgView.backgroundColor = UIColorFromRGB(0xEFF3FA);
    _listTable.tableFooterView = bgView;
    
}



#pragma mark UITableView delegate Start
// 返回section数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

// 返回section高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section==0){
        return 0;
    }else{
        return 25;
    }
}

// 返回section 的View
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section==1){
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 25)];
        [view setBackgroundColor:UIColorFromRGB(BgSystemColor)];
        
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(12, 0, ScreenWidth-24, 25)];
        [label setFont:ListDetailFont];
        [label setText:@"gansha a"];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setTextColor:UIColorFromRGB(TextBlackColor)];
        [view addSubview:label];
        return view;
    }
    return nil;
}

// 返回section下得行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_listArray==nil){
        return 0;
    }
    return _listArray.count;
}

// cell
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
    
    
    if(_listArray.count < indexPath.row){
        return cell;
    }
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [cell.contentView addSubview:imageView];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, ScreenWidth - 50, 21)];
    textLabel.font = DetGoodsFont;
    textLabel.textColor = UIColorFromRGB(TextUnPlaceHolderColor);
    [cell.contentView addSubview:textLabel];
    
    ZCLibTicketTypeModel *model=[_listArray objectAtIndex:indexPath.row];
    textLabel.text = model.typeName;
    
    
    CGRect imgf = imageView.frame;
    if([model.nodeFlag intValue] == 1){
        imageView.image =  [ZCUITools zcuiGetBundleImage:@"ZCicon_web_next_disabled"];
        imgf.size = CGSizeMake(15, 21);
    }

    imgf.origin.x = ScreenWidth - imgf.size.width - 15;
    imgf.origin.y = (44 - imgf.size.height)/2;
    imageView.frame = imgf;
    return cell;
}



// 是否显示删除功能
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

// 删除清理数据
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    editingStyle = UITableViewCellEditingStyleDelete;
}


// table 行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
    //    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    //    return cell.frame.size.height;
}

// table 行的点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_listArray==nil || _listArray.count<indexPath.row){
        return;
    }
    
    ZCLibTicketTypeModel *model = [_listArray objectAtIndex:indexPath.row];
    if([model.nodeFlag intValue] == 1){
        ZCOrderTypeController *typeVC = [[ZCOrderTypeController alloc] init];
        typeVC.typeId = model.typeId;
        typeVC.pageTitle = model.typeName;
        typeVC.orderTypeCheckBlock =  _orderTypeCheckBlock;
        typeVC.parentVC = _parentVC;
        typeVC.listArray = model.items;

        [self.navigationController pushViewController:typeVC animated:YES];
        
    }else{
        if(_orderTypeCheckBlock){
            _orderTypeCheckBlock(model);

            [self.navigationController popToViewController:_parentVC animated:YES];
            
        }
    }
    
}

//设置分割线间距
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if((indexPath.row+1) < _listArray.count){
        UIEdgeInsets inset = UIEdgeInsetsMake(0, 10, 0, 0);
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:inset];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:inset];
        }
    }
}

-(void)viewDidLayoutSubviews{
    [self setTableSeparatorInset];
}

#pragma mark UITableView delegate end

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
