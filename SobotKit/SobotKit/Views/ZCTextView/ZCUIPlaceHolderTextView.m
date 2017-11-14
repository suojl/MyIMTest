//
//  UIPlaceHolderTextView.m
//  Tutu
//
//  Created by zhangxinyao on 14-11-21.
//  Copyright (c) 2014年 zxy. All rights reserved.
//

#import "ZCUIPlaceHolderTextView.h"

@interface ZCUIPlaceHolderTextView  ()

@end

@implementation ZCUIPlaceHolderTextView
@synthesize placeholder =_placeholder;
@synthesize placeholderColor;
@synthesize LineSpacing;
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _placeHolderLabel = nil;
    placeholderColor = nil;
   _placeholder = nil;
    
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setPlaceholder:@""];
    [self setPlaceholderColor:[UIColor lightGrayColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    if( (self = [super initWithFrame:frame]) )
    {
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0)
    {
        return;
    }
    
    if([[self text] length] == 0)
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    else
    {
        [[self viewWithTag:999] setAlpha:0];
    }
    [self setNeedsDisplay];
}



- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

- (void)drawRect:(CGRect)rect
{
    if( [[self placeholder] length] > 0 )
    {
        if ( _placeHolderLabel == nil )
        {
            _placeHolderLabel = [[ZCMLEmojiLabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0)];
            CGRect phlab = _placeHolderLabel.frame;
            _placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _placeHolderLabel.font = self.placeholederFont ? self.placeholederFont:[ZCUITools zcgetListKitDetailFont];
            _placeHolderLabel.backgroundColor = [UIColor clearColor];
            _placeHolderLabel.textColor = self.placeholderColor;
            _placeHolderLabel.alpha = 0;
            _placeHolderLabel.tag = 999;
            
            NSString *text =self.placeholder;
//            text = [text stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
//            text = [text stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
//            text = [text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];
//            text = [text stringByReplacingOccurrencesOfString:@"<BR/>" withString:@"\n"];
//            text = [text stringByReplacingOccurrencesOfString:@"<BR />" withString:@"\n"];
//            text = [text stringByReplacingOccurrencesOfString:@"<p " withString:@"\n<p "];
//            text = [text stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
//            while ([text hasPrefix:@"\n"]) {
//                text=[text substringWithRange:NSMakeRange(1, text.length-1)];
//            }
            _placeHolderLabel.text = text;
            
            CGSize optimalSize = [self.placeHolderLabel preferredSizeWithMaxWidth:self.bounds.size.width-18];
            phlab.size.height = optimalSize.height;
           
            
            _placeHolderLabel.frame = CGRectMake(8, 8, phlab.size.width-8, phlab.size.height);
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(textViewBeginEditing:)];
            [_placeHolderLabel addGestureRecognizer:tap];
            [self addSubview:_placeHolderLabel];
        }
      
        [self sendSubviewToBack:_placeHolderLabel];
    }
    
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    
    [super drawRect:rect];
}
- (void)setPlaceholederFont:(UIFont *)placeholederFont{
    _placeholederFont = placeholederFont;
    [self setNeedsDisplay];
}
-(void)setPlaceholder:(NSString *)textPlaceholder{
    _placeholder = textPlaceholder;
    
    [self setNeedsDisplay];
}

// 点击占位文字的label 让textview成为第一响应者
- (void)textViewBeginEditing:(UITapGestureRecognizer *)tap{
    [self becomeFirstResponder];
}
@end
