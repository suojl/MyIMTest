//
//  ZCActionSheet.m
//  wash
//
//  Created by lizhihui on 15/10/21.
//
//

#import "ZCActionSheet.h"
#import "ZCUIColorsDefine.h"
#import "ZCLIbGlobalDefine.h"

// 每个按钮的高度
#define BtnHeight 48
// 取消按钮上面的间隔高度
#define Margin 6

@interface ZCActionSheet ()
{
    int _btnTag;
    UIColor *_selectColor;
}

@property (nonatomic, weak) UIView *sheetView;

@end

@implementation ZCActionSheet

- (instancetype)initWithDelegate:(id<ZCActionSheetDelegate>)delegate selectedColor:(UIColor *)color CancelTitle:(NSString *)cancelTitle OtherTitles:(NSString *)otherTitles, ...{
    
    self = [super init];
    
    _delegate = delegate;
    _selectColor = color;
    if(_selectColor == nil){
        _selectColor = UIColorFromRGB(TextLinkColor);
    }
    
    self.userInteractionEnabled = YES;
    // 黑色遮盖
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverClick)];
    [self addGestureRecognizer:tap];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    // sheet
    UIView *sheetView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    sheetView.backgroundColor = UIColorFromRGB(BgGlobeColor);
    [self addSubview:sheetView];
    self.sheetView = sheetView;
    sheetView.hidden = YES;
    sheetView.userInteractionEnabled = YES;
    
    NSString* curStr;
    va_list list;
    _btnTag = 1;
    if(otherTitles!=nil)
    {
        [self setupBtnWithTitle:otherTitles];
        
        va_start(list, otherTitles);
        while ((curStr = va_arg(list, NSString*))) {
            [self setupBtnWithTitle:curStr];
            
        }
        va_end(list);
    }
    
    CGRect sheetViewF = sheetView.frame;
    sheetViewF.size.height = BtnHeight * _btnTag + Margin;
    sheetView.frame = sheetViewF;
    
    // 取消按钮
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, sheetView.frame.size.height - BtnHeight, ScreenWidth, BtnHeight)];
    [btn setBackgroundImage:[self createImageWithColor:UIColorFromRGB(TextWhiteColor)] forState:UIControlStateNormal];
    [btn setBackgroundImage:[self createImageWithColor:UIColorFromRGB(highImageColor)] forState:UIControlStateHighlighted];
    [btn setTitle:cancelTitle forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = HeitiLight(17);
    btn.tag = 0;
    [btn addTarget:self action:@selector(sheetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.sheetView addSubview:btn];
    
    return self;
}

-(instancetype)initWithDelegate:(id<ZCActionSheetDelegate>)delegate selectedColor:(UIColor *)color showTitle:(NSString *)title CancelTitle:(NSString *)cancelTitle OtherTitles:(NSString *)otherTitles, ...{
    self = [super init];
    
    _delegate = delegate;
    _selectColor = color;
    if(_selectColor == nil){
        _selectColor = UIColorFromRGB(TextLinkColor);
    }
    
    self.userInteractionEnabled = YES;
    // 黑色遮盖
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverClick)];
    [self addGestureRecognizer:tap];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    // sheet
    UIView *sheetView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    sheetView.backgroundColor = UIColorFromRGB(BgGlobeColor);
    [self addSubview:sheetView];
    self.sheetView = sheetView;
    sheetView.hidden = YES;
    sheetView.userInteractionEnabled = YES;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, BtnHeight)];
    [titleLabel setText:title];
    [titleLabel setFont:ListTitleFont];
    [titleLabel setBackgroundColor:UIColorFromRGB(TextWhiteColor)];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.sheetView addSubview:titleLabel];
    
    // 最上面画分割线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
    line.backgroundColor = UIColorFromRGB(SeparatorColor);
    [titleLabel addSubview:line];
    
    
    NSString* curStr;
    va_list list;
    _btnTag = 2;
    if(otherTitles!=nil)
    {
        [self setupBtnWithTitle:otherTitles];
        
        va_start(list, otherTitles);
        while ((curStr = va_arg(list, NSString*))) {
            [self setupBtnWithTitle:curStr];
            
        }
        va_end(list);
    }
    
    CGRect sheetViewF = sheetView.frame;
    sheetViewF.size.height = BtnHeight * _btnTag + Margin;
    sheetView.frame = sheetViewF;
    
    // 取消按钮
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, sheetView.frame.size.height - BtnHeight, ScreenWidth, BtnHeight)];
    [btn setBackgroundImage:[self createImageWithColor:UIColorFromRGB(TextWhiteColor)] forState:UIControlStateNormal];
    [btn setBackgroundImage:[self createImageWithColor:UIColorFromRGB(highImageColor)] forState:UIControlStateHighlighted];
    [btn setTitle:cancelTitle forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = HeitiLight(17);
    btn.tag = 0;
    [btn addTarget:self action:@selector(sheetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.sheetView addSubview:btn];
    
    return self;
}

-(void)setSelectIndex:(int)selectIndex{
    if(selectIndex > 0){
        UIButton *btn=[self.sheetView viewWithTag:selectIndex];
        [btn setTitleColor:_selectColor forState:UIControlStateNormal];
    }
}

- (void)show{
    self.sheetView.hidden = NO;

    CGRect sheetViewF = self.sheetView.frame;
    sheetViewF.origin.y = ScreenHeight;
    self.sheetView.frame = sheetViewF;
    
    CGRect newSheetViewF = self.sheetView.frame;
    newSheetViewF.origin.y = ScreenHeight - self.sheetView.frame.size.height;
    
    [UIView animateWithDuration:0.3 animations:^{

        self.sheetView.frame = newSheetViewF;
        
    }];
}

- (void)setupBtnWithTitle:(NSString *)title{
    // 创建按钮
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, BtnHeight * (_btnTag - 1) , ScreenWidth, BtnHeight)];
    [btn setBackgroundImage:[self createImageWithColor:UIColorFromRGB(TextWhiteColor)] forState:UIControlStateNormal];
    [btn setBackgroundImage:[self createImageWithColor:UIColorFromRGB(highImageColor)] forState:UIControlStateHighlighted];
    [btn setTitle:title forState:UIControlStateNormal];
    if(_selectIndex==_btnTag){
        [btn setTitleColor:_selectColor forState:UIControlStateNormal];
    }else{
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    btn.titleLabel.font = HeitiLight(17);
    btn.tag = _btnTag;
    [btn addTarget:self action:@selector(sheetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.sheetView addSubview:btn];
    
    
    // 最上面画分割线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
    line.backgroundColor = UIColorFromRGB(SeparatorColor);
    [btn addSubview:line];
    
    _btnTag ++;
}

- (void)coverClick{
    CGRect sheetViewF = self.sheetView.frame;
    sheetViewF.origin.y = ScreenHeight;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.0f;
        self.sheetView.frame = sheetViewF;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.sheetView removeFromSuperview];
    }];
}
// button的点击事件
- (void)sheetBtnClick:(UIButton *)btn{
    if (btn.tag == 0) {
        [self coverClick];
        return;
    }
    // 让代理去执行方法
    if ([self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
        [self.delegate actionSheet:self clickedButtonAtIndex:btn.tag];
        [self coverClick];
    }
}

- (UIImage*)createImageWithColor:(UIColor*)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
