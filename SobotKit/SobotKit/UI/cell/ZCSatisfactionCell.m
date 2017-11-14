//
//  ZCSatisfactionCell.m
//  SobotKit
//
//  Created by lizhihui on 16/1/21.
//  Copyright © 2016年 zhichi. All rights reserved.
//

#import "ZCSatisfactionCell.h"
#import "ZCLIbGlobalDefine.h"
#import "ZCUIColorsDefine.h"

#import "ZCUIRatingView.h"
#import "ZCSatisfactionButton.h"

#import "ZCStoreConfiguration.h"
#import "ZCLibServer.h"
#import "ZCIMChat.h"


@interface ZCSatisfactionCell ()<RatingViewDelegate>{

}

@property (nonatomic,strong) ZCUIRatingView * ratingView;

@property (nonatomic,strong) UILabel * resolvelab;

@property (nonatomic,strong) ZCSatisfactionButton * resolveBtn;// 已解决

@property (nonatomic,strong) UILabel * satisfactionlab;

@property (nonatomic,strong) UILabel * tiplab;

@property (nonatomic,strong) UIView * bglayerView;

@property (nonatomic,strong) UIView * selctedView;

@property (nonatomic,strong) UITapGestureRecognizer * tap ;

@property (nonatomic,strong) ZCSatisfactionButton * isresolveBtn;// 未解决

@property (nonatomic,strong) ZCSatisfactionButton * correctBtn;// 对勾

@property (nonatomic,assign) BOOL  isShowAction;

@property (nonatomic,strong) ZCLibMessage * model;

@property (nonatomic,assign) int rating;

@property (nonatomic,assign) int isResolved;// 0 已解决 1 未解决  2.没有选择

@property (nonatomic,strong) UIView *topview;//萌层

@end


@implementation ZCSatisfactionCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

//
//        //设置点击事件
//        UITapGestureRecognizer *tapGesturer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(satisfactionAction:)];
//        self.userInteractionEnabled=YES;
//        [self addGestureRecognizer:tapGesturer];
        
        _bglayerView = [[UIView alloc]init];
        _bglayerView.backgroundColor = [UIColor whiteColor];
        _bglayerView.layer.borderWidth = 0.75f;
        _bglayerView.layer.cornerRadius = 3.0f;
        _bglayerView.layer.masksToBounds = YES;
        _bglayerView.layer.borderColor = [ZCUITools zcgetNoSatisfactionTextColor].CGColor;
        
        [self.contentView addSubview:_bglayerView];
        
        
        _selctedView = [[UIView alloc]init];
//        _selctedView.backgroundColor = UIColorFromRGB(BgSatisfactionView);
        [_bglayerView addSubview:_selctedView];
//        _selctedView.backgroundColor = [UIColor clearColor];
        
        
        // 是否解决问题lab
        _resolvelab = [[UILabel alloc]init];
        [_resolvelab setBackgroundColor:[UIColor clearColor]];
        [_resolvelab setTextAlignment:NSTextAlignmentCenter];
        [_resolvelab setFont:[ZCUITools zcgetVoiceButtonFont]];
        [_resolvelab setTextColor:UIColorFromRGB(TextBlackColor)];
        _resolvelab.numberOfLines=0;
        [_selctedView addSubview:_resolvelab];
        

        
        
        // satisfactionlab
        _satisfactionlab = [[UILabel alloc]init];
        [_satisfactionlab setBackgroundColor:[UIColor clearColor]];
        [_satisfactionlab setTextAlignment:NSTextAlignmentCenter];
        [_satisfactionlab setFont:[ZCUITools zcgetVoiceButtonFont]];
        [_satisfactionlab setTextColor:UIColorFromRGB(TextBlackColor)];
        _satisfactionlab.numberOfLines=0;
        [_selctedView addSubview:_satisfactionlab];
      
        // _ratingView
//        _ratingView = [[ZCUIRatingView alloc]init];
//        [_selctedView addSubview:_ratingView];
//        self.rating = 0;
//        [_ratingView displayRating:.0f];

    
        
        _tiplab = [[UILabel alloc]init];
        [_tiplab setBackgroundColor:[UIColor clearColor]];
        [_tiplab setTextAlignment:NSTextAlignmentCenter];
        [_tiplab setFont:[ZCUITools zcgetCustomListKitDetailFont]];
        [_tiplab setTextColor:UIColorFromRGB(SatisfactionTextColor)];
        _tiplab.numberOfLines=0;
        [_bglayerView addSubview:_tiplab];
        
        
        // 对勾
        _correctBtn = [ZCSatisfactionButton buttonWithType:UIButtonTypeCustom];
        [_correctBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"ZCIcon_satisfaction_correct")] forState:UIControlStateNormal];
        [_correctBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"ZCIcon_satisfaction_correct")] forState:UIControlStateSelected];
        [_correctBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"ZCIcon_satisfaction_correct")] forState:UIControlStateHighlighted];
        [_correctBtn setTitle:@" " forState:UIControlStateNormal];
        
//        _isresolveBtn.userInteractionEnabled = NO;
//        [_isresolveBtn.titleLabel setFont:[ZCUITools zcgetCustomListKitDetailFont]];
//        [_isresolveBtn setTitleColor:UIColorFromRGB(SatisfactionTextColor) forState:UIControlStateHighlighted];
//        [_isresolveBtn setTitleColor:UIColorFromRGB(SatisfactionTextColor) forState:UIControlStateSelected];
//        [_isresolveBtn setTitleColor:UIColorFromRGB(SatisfactionTextColor) forState:UIControlStateNormal];
//        [_bglayerView addSubview:_isresolveBtn];
        
        
    }
    return self;
}

- (CGFloat)InitDataToView:(ZCLibMessage *)model time:(NSString *)showTime{
    [self resetCellView];
   
    self.isResolved = 2;
    
//    CGFloat cellHeight = [super InitDataToView:model time:showTime];
    
    _bglayerView.frame = CGRectMake(36, 10, ScreenWidth - 36*2, 0);
    _selctedView.frame = CGRectMake(0, 0, _bglayerView.frame.size.width, 0);
    _selctedView.backgroundColor = [UIColor whiteColor];
    
    if (_resolveBtn !=nil) {
        _resolveBtn.selected = NO;
    }
    
    if (_isresolveBtn!=nil) {
//        [_isresolveBtn removeFromSuperview];
        _isresolveBtn.selected = NO;
    }
    

    
    if (_resolvelab != nil) {
        _resolvelab.text = @"";
    }
    
    if (_satisfactionlab != nil) {
        _satisfactionlab.text = @"";
    }
    // 添加 是否解决
    if ([model.isQuestionFlag intValue] > 0 ) {
        
        _resolvelab.frame = CGRectMake(0, 20 ,_bglayerView.frame.size.width ,21);
        _resolvelab.text = [NSString stringWithFormat:ZCSTLocalString(@"请问 [%@] 是否解决了您的问题？"),model.senderName];
//        cellHeight = cellHeight + 21 + 15;
        if (model.satisfactionCommtType >0) {
            if (model.satisfactionCommtType == 1) {
                
                if(_resolveBtn !=nil){
                    [_resolveBtn removeFromSuperview];
                }
                _resolveBtn = [ZCSatisfactionButton buttonWithType:UIButtonTypeCustom];
                _isresolveBtn.hidden =YES;
                _resolveBtn .hidden =NO;
                _resolveBtn.tag = 101;
                [_resolveBtn setFrame:CGRectMake(_bglayerView.frame.size.width/2 -120/2, 56, 120, 36)];
                [_resolveBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"ZCIcon_sf_zan_blue_nol")] forState:UIControlStateNormal];
                [_resolveBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"ZCIcon_sf_zan_sel")] forState:UIControlStateSelected];
                [_resolveBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"ZCIcon_sf_zan_sel")] forState:UIControlStateHighlighted];
                [_resolveBtn setTitle:ZCSTLocalString(@"已解决") forState:UIControlStateNormal];
                _resolveBtn.selected = YES;
                _resolveBtn.userInteractionEnabled = NO;
                
                [_resolveBtn.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
                [_resolveBtn setTitleColor:[ZCUITools zcgetSatisfactionTextSelectedColor] forState:UIControlStateHighlighted];
                [_resolveBtn setTitleColor:[ZCUITools zcgetSatisfactionTextSelectedColor] forState:UIControlStateSelected];
                [_resolveBtn setTitleColor:[ZCUITools zcgetSatisfactionTextSelectedColor] forState:UIControlStateNormal];
                [_resolveBtn setBackgroundColor:[ZCUITools zcgetSatisfactionBgSelectedColor]];
                _resolveBtn.layer.cornerRadius = 7.5f;
                _resolveBtn.layer.masksToBounds = YES;
//                _resolveBtn.layer.borderColor = UIColorFromRGB(SatisfactionTextColor).CGColor;
                _resolveBtn.layer.borderColor = [UIColor clearColor].CGColor;
                _resolveBtn.layer.borderWidth = 0.5f;
                _resolveBtn.userInteractionEnabled = NO;
                [_selctedView addSubview:_resolveBtn];
                
            }else if(model.satisfactionCommtType == 2){
                if(_isresolveBtn !=nil){
                    [_isresolveBtn removeFromSuperview];
                }
                _isresolveBtn = [ZCSatisfactionButton buttonWithType:UIButtonTypeCustom];

                _resolveBtn.hidden =YES;
                _isresolveBtn .hidden =NO;
                _isresolveBtn.tag = 102;
                [_isresolveBtn setFrame:CGRectMake(_bglayerView.frame.size.width/2 -120/2, 56, 120, 36)];
                [_isresolveBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"ZCIcon_sf_no_gray_sel")] forState:UIControlStateNormal];
                [_isresolveBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"ZCIcon_sf_no_gray_sel")] forState:UIControlStateSelected];
                [_isresolveBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"ZCIcon_sf_no_gray_sel")] forState:UIControlStateHighlighted];
                [_isresolveBtn setTitle:ZCSTLocalString(@"未解决") forState:UIControlStateNormal];
                _isresolveBtn.selected = YES;
                _isresolveBtn.userInteractionEnabled = NO;
                [_isresolveBtn.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
                [_isresolveBtn setTitleColor:[ZCUITools zcgetSatisfactionTextSelectedColor] forState:UIControlStateHighlighted];
                [_isresolveBtn setTitleColor:[ZCUITools zcgetSatisfactionTextSelectedColor] forState:UIControlStateSelected];
                [_isresolveBtn setTitleColor:[ZCUITools zcgetSatisfactionTextSelectedColor] forState:UIControlStateNormal];
                [_isresolveBtn setBackgroundColor:[ZCUITools zcgetSatisfactionBgSelectedColor]];
                _isresolveBtn.layer.cornerRadius = 7.5f;
                _isresolveBtn.layer.masksToBounds = YES;
//                _isresolveBtn.layer.borderColor = UIColorFromRGB(SatisfactionTextColor).CGColor;
                _isresolveBtn.layer.borderColor = [UIColor clearColor].CGColor;
                _isresolveBtn.layer.borderWidth = 0.5f;
                _isresolveBtn.userInteractionEnabled = NO;
                [_selctedView addSubview:_isresolveBtn];
            }
            
        }else{
            // 已解决 未解决
            for (int i=0; i<2; i++) {
                
                if(i==0){
                    if (_resolveBtn !=nil) {
                        [_resolveBtn removeFromSuperview];
                    }
                    _resolveBtn = [ZCSatisfactionButton buttonWithType:UIButtonTypeCustom];
                    [_resolveBtn setFrame:CGRectMake(_bglayerView.frame.size.width/2 - 8 -120, 56, 120, 36)];
                    _resolveBtn.tag= 101;
                    [_resolveBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"ZCIcon_sf_zan_blue_nol")] forState:UIControlStateNormal];
                    [_resolveBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"ZCIcon_sf_zan_sel")] forState:UIControlStateSelected];
                    [_resolveBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"ZCIcon_sf_zan_sel")] forState:UIControlStateHighlighted];
                    _resolveBtn.selected=NO;
                    [_resolveBtn setTitle:ZCSTLocalString(@"已解决") forState:UIControlStateNormal];
                    [_resolveBtn.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
                    
                    [_resolveBtn setTitleColor:[ZCUITools zcgetSatisfactionBgSelectedColor] forState:UIControlStateNormal];
                    [_resolveBtn setTitleColor:[ZCUITools zcgetSatisfactionTextSelectedColor] forState:UIControlStateHighlighted];
                    [_resolveBtn setTitleColor:[ZCUITools zcgetSatisfactionTextSelectedColor] forState:UIControlStateSelected];
                    [_resolveBtn setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [_resolveBtn setBackgroundColor:[ZCUITools zcgetSatisfactionBgSelectedColor] forState:UIControlStateSelected];
                    [_resolveBtn setBackgroundColor:[ZCUITools zcgetSatisfactionBgSelectedColor] forState:UIControlStateHighlighted];
                    _resolveBtn.layer.cornerRadius = 3.0f;
                    _resolveBtn.layer.masksToBounds = YES;
                    _resolveBtn.layer.borderColor = UIColorFromRGB(SatisfactionTextColor).CGColor;
                    _resolveBtn.layer.borderWidth = 0.75f;
                    [_resolveBtn addTarget:self action:@selector(robotServerButton:) forControlEvents:UIControlEventTouchUpInside];
                    _resolveBtn.userInteractionEnabled = YES;
                    [_selctedView addSubview:_resolveBtn];
                    
                    
                }else{
                    if (_isresolveBtn !=nil) {
                        [_isresolveBtn removeFromSuperview];
                    }
                    _isresolveBtn = [ZCSatisfactionButton buttonWithType:UIButtonTypeCustom];
                    [_isresolveBtn setFrame:CGRectMake(_bglayerView.frame.size.width/2 + 8, 56,120, 36)];
                    _isresolveBtn.tag= 102;
                    [_isresolveBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"ZCIcon_sf_no_gray_nol")] forState:UIControlStateNormal];
                    [_isresolveBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"ZCIcon_sf_no_gray_sel")] forState:UIControlStateSelected];
                    [_isresolveBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"ZCIcon_sf_no_gray_sel")] forState:UIControlStateHighlighted];
                    _isresolveBtn.selected=NO;
                    [_isresolveBtn setTitle:ZCSTLocalString(@"未解决") forState:UIControlStateNormal];
                    [_isresolveBtn setTitleColor:UIColorFromRGB(SatisfactionTextColor) forState:UIControlStateNormal];
                  
                    [_isresolveBtn.titleLabel setFont:[ZCUITools zcgetListKitTitleFont]];
                    [_isresolveBtn setTitleColor:[ZCUITools zcgetSatisfactionTextSelectedColor] forState:UIControlStateHighlighted];
                    [_isresolveBtn setTitleColor:[ZCUITools zcgetSatisfactionTextSelectedColor] forState:UIControlStateSelected];
                    
                    [_isresolveBtn setBackgroundColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [_isresolveBtn setBackgroundColor:[ZCUITools zcgetSatisfactionBgSelectedColor] forState:UIControlStateSelected];
                    [_isresolveBtn setBackgroundColor:[ZCUITools zcgetSatisfactionBgSelectedColor] forState:UIControlStateHighlighted];
                    
                    _isresolveBtn.layer.cornerRadius = 3.0f;
                    _isresolveBtn.layer.masksToBounds = YES;
                    
                    _isresolveBtn.layer.borderColor = UIColorFromRGB(SatisfactionTextColor).CGColor;
                    _isresolveBtn.layer.borderWidth = 0.75f;
                    [_isresolveBtn addTarget:self action:@selector(robotServerButton:) forControlEvents:UIControlEventTouchUpInside];
                    
                    _isresolveBtn.userInteractionEnabled = YES;
                    [_selctedView addSubview:_isresolveBtn];
                }
               
                
            }
            
        }
        
        
//        cellHeight = cellHeight + 36 ;
    
    }
    CGFloat satisfactionlabY = 20;
    if (_isresolveBtn.frame.size.height >0 ) {
        satisfactionlabY = CGRectGetMaxY(_isresolveBtn.frame) +20;
    }else if(_resolveBtn.frame.size.height >0){
        satisfactionlabY = CGRectGetMaxY(_resolveBtn.frame) +20;
    }
    _satisfactionlab.frame = CGRectMake(0,satisfactionlabY , _bglayerView.frame.size.width, 21);
    [_satisfactionlab setText:[NSString stringWithFormat:ZCSTLocalString(@"请您对 [%@] 进行评价"),model.senderName]];
//    cellHeight = cellHeight + 21 + 15;

    if (_ratingView != nil) {
        [_ratingView removeFromSuperview];
    }
    _ratingView =[[ZCUIRatingView alloc]initWithFrame: CGRectMake(56, CGRectGetMaxY(_satisfactionlab.frame)+15, _bglayerView.frame.size.width -56*2, 29 )];
    [_ratingView setImagesDeselected:@"ZCStar_unsatisfied" partlySelected:@"ZCStar_satisfied" fullSelected:@"ZCStar_satisfied" andDelegate:self];
//    [_ratingView setBackgroundColor:[UIColor yellowColor]];
    if (model.satisfactionCommtType >0) {
        _isShowAction = NO;
        [_ratingView displayRating:model.ratingCount];
        self.rating = model.ratingCount;
//        _ratingView.userInteractionEnabled =NO;
//        [self removeGestureRecognizer:_tap];
        
        self.userInteractionEnabled = YES;
      
    }else{
        self.rating = 0;
       [_ratingView displayRating:.0f];
//        _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(robotServerButton)];
//        [_ratingView addGestureRecognizer:_tap];
//        _ratingView.userInteractionEnabled = YES;
//        _selctedView.userInteractionEnabled = YES;
//        _bglayerView.userInteractionEnabled = YES;
        self.userInteractionEnabled = YES;
        
        _isShowAction = YES;
    }
    [_selctedView addSubview:_ratingView];

//    cellHeight = cellHeight + 40 + 15;
    
    CGRect selectedF = self.selctedView.frame;
    selectedF.size.height = CGRectGetMaxY(_ratingView.frame);
    self.selctedView.frame = selectedF;
    _tiplab.frame = CGRectMake(0, CGRectGetMaxY(_selctedView.frame) + 15, _bglayerView.frame.size.width, 20);
//    self.selctedView.backgroundColor = [UIColor blueColor];
//    [_tiplab setBackgroundColor:[UIColor redColor]];
//    _correctBtn.frame = CGRectMake(0, CGRectGetMaxY(_selctedView.frame)+15 , _bglayerView.frame.size.width, 20);
//    _correctBtn.backgroundColor = [UIColor redColor];
    if (model.satisfactionCommtType >0) {
        _tiplab.text = ZCSTLocalString(@"√ 您的评价已成功提交");
//         [_correctBtn setImage:[ZCUITools zcuiGetBundleImage:ZCSTLocalString(@"ZCIcon_sf_no_gray_nol")] forState:UIControlStateNormal];
//        [_correctBtn setTitle:@"您的评价已成功提交" forState:UIControlStateNormal];
//        [_correctBtn setTitle:@"您的评价已成功提交" forState:UIControlStateHighlighted];
//        [_correctBtn setTitle:@"您的评价已成功提交" forState:UIControlStateSelected];
    }else{
        _tiplab.text = ZCSTLocalString(@"您的评价会让我们做的更好");
//         [_correctBtn setImage:[ZCUITools zcuiGetBundleImage:@""] forState:UIControlStateNormal];
//        [_correctBtn setTitle:@"您的评价会让我们做的更好" forState:UIControlStateNormal];
//        [_correctBtn setTitle:@"您的评价会让我们做的更好" forState:UIControlStateHighlighted];
//        [_correctBtn setTitle:@"您的评价会让我们做的更好" forState:UIControlStateSelected];

    }
    
//    cellHeight = cellHeight + 20 ;
    CGRect bgF = self.bglayerView.frame;
    bgF.size.height = CGRectGetMaxY(_tiplab.frame) + _tiplab.frame.size.height ;
    self.bglayerView.frame = bgF;
    
//    NSLog([NSString stringWithFormat:@"当前------cell的高度%f  cellheight父类%f   ++ 20间距",self.bglayerView.frame.size.height,cellHeight]);
    
    if (model.satisfactionCommtType >0) {
        // 评价完成，关闭交互
        if (self.topview == nil) {
            self.topview= [[UIView alloc]initWithFrame:self.bglayerView.frame];
            _topview.backgroundColor = [UIColor clearColor];
            [self.contentView addSubview:_topview];
        }
       
    }else{
        if (self.topview != nil) {
           [self.topview removeFromSuperview];
            self.userInteractionEnabled = YES;
        }
        
    }
    
    return self.bglayerView.frame.size.height+20;
    
}

+(CGFloat)getCellHeight:(ZCLibMessage *)model time:(NSString *)showTime viewWith:(CGFloat)width{
//    CGFloat height=[super getCellHeight:model time:showTime viewWith:width];
//    NSLog([NSString stringWithFormat:@"当前+++++++cell的高度%f ", height]);
    if ([model.isQuestionFlag intValue]  == 0) {
        return  232 -92 +20 ;
    }
    return 232  + 20 ;
}

-(void)resetCellView{
    [super resetCellView];
    self.lblNickName = nil;
    self.ivHeader = nil;
    
}


- (void)robotServerButton:(ZCSatisfactionButton*)sender{
    sender.layer.borderColor = [UIColor clearColor].CGColor;
    if (sender.tag == 101) {
//        UIButton *btn=(UIButton *)[self.backgroundView viewWithTag:102];
//        [btn setSelected:NO];
        _isresolveBtn.layer.borderColor = UIColorFromRGB(LineCommentLineColor).CGColor;
        _resolveBtn.selected = YES;
        _isresolveBtn.selected = NO;
        self.isResolved = 0;
    }else{
        _resolveBtn.layer.borderColor = UIColorFromRGB(LineCommentLineColor).CGColor;
        _resolveBtn.selected = NO;
        _isresolveBtn.selected = YES;
        self.isResolved = 1;
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma delegate

-(void)ratingChanged:(float)newRating{

    if (!_isShowAction ) {
        return;
    }
    if (newRating == self.rating && !_isShowAction) {
        return;
    }
    self.rating = newRating;
    if (newRating > 0 && newRating < 5) {
        [self  commitAction:1];
    }else if(newRating == 5){
        // 直接提交评价
        [self commitAction:2];
    }
    _isShowAction = YES;
}

// 提交评价   type 1代表5星以下  2 代表5星提交
- (void)commitAction:(int)type{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellItemClick:IsResolved:Rating:)]) {
        [self.delegate cellItemClick:type IsResolved:self.isResolved Rating:self.rating];
    }
}



@end
