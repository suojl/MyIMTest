//
//  ZCButton.m
//  GCDtestDemo
//
//  Created by lizhihui on 2016/11/1.
//  Copyright © 2016年 lizhihui. All rights reserved.
//

#import "ZCButton.h"

@implementation ZCButton

- (void)layoutSubviews{
    [super layoutSubviews];
    if (self.type == 1) {
        // 图片靠右   语音cell的btn 设置样式
        CGPoint  imgCenter = self.imageView.center;
        imgCenter.x = (self.frame.size.width - 10) - self.imageView.frame.size.width/2;
        self.imageView.center = imgCenter;
        
        CGRect newFrame = [self titleLabel].frame;
        newFrame.origin.x = 5;
        newFrame.size.width = self.frame.size.width;
        self.titleLabel.frame = newFrame;
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
//        self.titleLabel.backgroundColor = [UIColor blueColor];
//        self.imageView.backgroundColor = [UIColor redColor];
        
    }else{
        CGPoint center = self.imageView.center;
        center.x = self.frame.size.width/2;
        center.y = self.imageView.frame.size.height*3/5;
        self.imageView.center = center;
        
        CGRect newFrame = [self titleLabel].frame;
        newFrame.origin.x = 0;
        newFrame.origin.y = self.imageView.frame.size.height + 5;
        newFrame.size.width = self.frame.size.width;
        self.titleLabel.frame = newFrame;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
//    self.backgroundColor = [UIColor yellowColor];
}


@end
