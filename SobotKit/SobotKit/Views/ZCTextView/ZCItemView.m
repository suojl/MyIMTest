//
//  ItemView.m
//  CollectionViewDemo
//
//  Created by on 2017/6/18.
//  Copyright © 2017年 . All rights reserved.
//

#import "ZCItemView.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"
#import "ZCUIImageTools.h"

// 一行中最3列
#define MaxCols 2

@interface ZCItemView()
@property(nonatomic,strong)NSMutableArray *titles;
@end
@implementation ZCItemView

-(void)layoutSubviews{
    
    [super layoutSubviews];
    CGFloat inset = 30;
    NSUInteger count = self.subviews.count;
    CGFloat btnW = (self.frame.size.width - 2.5 * inset) / MaxCols;
    CGFloat btnH = 36;
    for (int i = 0; i<count; i++) {
        UIView *tempView = self.subviews[i];
        
        tempView.frame = CGRectMake(inset+ (i%MaxCols)*(15 +  btnW), inset/2*(i/MaxCols) + (i/MaxCols) * btnH, btnW, btnH);
    }
    self.userInteractionEnabled = YES;
}
+(CGFloat)getHeightWithArray:(NSArray *)titles{
    
    CGFloat btHeight = 36;
    
    CGFloat margin = 0;
    
    if (titles.count == 3 || titles.count == 4) {
        margin = 15;
        btHeight = 36*2 + margin;
    }else if(titles.count == 5 || titles.count == 6 || titles.count >6){
        margin = 30;
        btHeight = 36*3 + margin;
    }else if(titles.count == 1 || titles.count == 2){
        btHeight = 36 ;
    }
    return    btHeight;

}

-(void)InitDataWithArray:(NSArray *)titles{
    [self.titles removeAllObjects];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    int tagI = 100;
    for (NSString *title in titles) {
        UIButton *titleBT= [UIButton buttonWithType:UIButtonTypeCustom];
        [titleBT setTitle:title forState:UIControlStateNormal];
        [titleBT setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [titleBT setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
        titleBT.layer.cornerRadius = 7.5f;
        titleBT.layer.borderWidth = 0.75f;
        titleBT.layer.borderColor=UIColorFromRGB(LineCommentLineColor).CGColor;
        titleBT.layer.masksToBounds=YES;
        [titleBT.titleLabel setFont:[ZCUITools zcgetDetGoodsFont]];
        [titleBT setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [titleBT setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [titleBT setTitleColor:UIColorFromRGB(TextNameColor) forState:UIControlStateNormal];
        [titleBT setBackgroundImage:[ZCUIImageTools zcimageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        [titleBT setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUITools zcgetCommentButtonLineColor]] forState:UIControlStateSelected];
        [titleBT setBackgroundImage:[ZCUIImageTools zcimageWithColor:[ZCUITools zcgetCommentButtonLineColor]] forState:UIControlStateHighlighted];
        tagI = tagI + 1;
        titleBT.tag = tagI;
        [self  addSubview:titleBT];
        [titleBT addTarget:self action:@selector(Click:) forControlEvents:UIControlEventTouchUpInside];
        
    }
}
-(void)Click:(UIButton *)bt{
 
    bt.selected = !bt.selected;
    
    if (bt.selected) {
        bt.layer.borderColor = [UIColor clearColor].CGColor;
        [self.titles addObject:bt.titleLabel.text];
    }else{
       [self.titles removeObject:bt.titleLabel.text];
        bt.layer.borderColor=UIColorFromRGB(LineCommentLineColor).CGColor;
    }

    
}
-(NSString *)getSeletedTitle{
    
   __block NSString *title = @"";
    
    [self.titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        title  =[title stringByAppendingFormat:@"%@",obj];
    }];
    
    return title;
    
}
-(NSMutableArray *)titles{
    
    if (!_titles) {
        _titles = [NSMutableArray arrayWithCapacity:0];
    }
    return _titles;
    
}
@end
