//
//  ZCSatisfactionButton.m
//  SobotKit
//
//  Created by lizhihui on 2017/6/15.
//  Copyright © 2017年 zhichi. All rights reserved.
//

#import "ZCSatisfactionButton.h"

@implementation ZCSatisfactionButton

- (void)layoutSubviews{
    
    [super layoutSubviews];
    CGPoint center = self.imageView.center;
    center.x = 34;
//    int languages = zcGetAppLanguages();
//    if (languages == 1) {
//        center.x = 17;
//    }
    //    center.y = self.imageView.frame.size.height*3/5;
    self.imageView.center = center;
    
    CGRect newFrame = [self titleLabel].frame;
    newFrame.origin.x = self.imageView.frame.origin.x + 10 + self.imageView.frame.size.width;
    newFrame.origin.y = 8;
    //    newFrame.size.width = self.frame.size.width;
    self.titleLabel.frame = newFrame;
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    [self setBackgroundImage:[self imageWithColor:backgroundColor] forState:state];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
