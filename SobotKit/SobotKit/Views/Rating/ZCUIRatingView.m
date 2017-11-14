//
//  RatingViewController.m
//  RatingController
//
//  Created by Ajay on 2/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ZCUIRatingView.h"

@implementation ZCUIRatingView

@synthesize s1, s2, s3, s4, s5;


-(void)setImagesDeselected:(NSString *)deselectedImage
			partlySelected:(NSString *)halfSelectedImage
			  fullSelected:(NSString *)fullSelectedImage
			   andDelegate:(id<RatingViewDelegate>)d {
    unselectedImage = [ZCUITools zcuiGetBundleImage:deselectedImage];// [UIImage imageNamed:deselectedImage];
    partlySelectedImage =  halfSelectedImage == nil ? unselectedImage : [ZCUITools zcuiGetBundleImage:halfSelectedImage]; //[UIImage imageNamed:halfSelectedImage];
    fullySelectedImage = [ZCUITools zcuiGetBundleImage:fullSelectedImage]; //[UIImage imageNamed:fullSelectedImage];
	viewDelegate = d;
	
	height= 29;
    width=  self.frame.size.width/5;
//	if (height < [fullySelectedImage size].height) {
//		height = [fullySelectedImage size].height;
//	}
//	if (height < [partlySelectedImage size].height) {
//		height = [partlySelectedImage size].height;
//	}
//	if (height < [unselectedImage size].height) {
//		height = [unselectedImage size].height;
//	}
//	if (width < [fullySelectedImage size].width) {
//		width = [fullySelectedImage size].width;
//	}
//	if (width < [partlySelectedImage size].width) {
//		width = [partlySelectedImage size].width;
//	}
//	if (width < [unselectedImage size].width) {
//		width = [unselectedImage size].width;
//	}
    
    
	starRating = 0;
	lastRating = 0;
    
	s1 = [[UIImageView alloc] initWithImage:unselectedImage];
	s2 = [[UIImageView alloc] initWithImage:unselectedImage];
	s3 = [[UIImageView alloc] initWithImage:unselectedImage];
	s4 = [[UIImageView alloc] initWithImage:unselectedImage];
	s5 = [[UIImageView alloc] initWithImage:unselectedImage];
	
    [s1 setContentMode:UIViewContentModeScaleAspectFit];
    [s2 setContentMode:UIViewContentModeScaleAspectFit];
    [s3 setContentMode:UIViewContentModeScaleAspectFit];
    [s4 setContentMode:UIViewContentModeScaleAspectFit];
    [s5 setContentMode:UIViewContentModeScaleAspectFit];
    
    
	[s1 setFrame:CGRectMake(0,         0, width, height)];
	[s2 setFrame:CGRectMake(width,     0, width, height)];
	[s3 setFrame:CGRectMake(2 * width, 0, width, height)];
	[s4 setFrame:CGRectMake(3 * width, 0, width, height)];
	[s5 setFrame:CGRectMake(4 * width, 0, width, height)];
	
	[s1 setUserInteractionEnabled:YES];
	[s2 setUserInteractionEnabled:YES];
	[s3 setUserInteractionEnabled:YES];
	[s4 setUserInteractionEnabled:YES];
	[s5 setUserInteractionEnabled:YES];
	
    
    s1.tag = 1001;
    s2.tag = 1002;
    s3.tag = 1003;
    s4.tag = 1004;
    s5.tag = 1005;
    
    UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    UITapGestureRecognizer * tap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    UITapGestureRecognizer * tap4 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    UITapGestureRecognizer * tap5 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    
    [s1 addGestureRecognizer:tap1];
    [s2 addGestureRecognizer:tap2];
    [s3 addGestureRecognizer:tap3];
    [s4 addGestureRecognizer:tap4];
    [s5 addGestureRecognizer:tap5];

    
	[self addSubview:s1];
	[self addSubview:s2];
	[self addSubview:s3];
	[self addSubview:s4];
	[self addSubview:s5];
	
	CGRect frame = [self frame];
	frame.size.width = width * 5;
	frame.size.height = height;
	[self setFrame:frame];
}

-(void)displayRating:(float)rating {
	[s1 setImage:unselectedImage];
	[s2 setImage:unselectedImage];
	[s3 setImage:unselectedImage];
	[s4 setImage:unselectedImage];
	[s5 setImage:unselectedImage];
	
	if (rating >= 0.5) {
		[s1 setImage:partlySelectedImage];
	}
	if (rating >= 1) {
		[s1 setImage:fullySelectedImage];
	}
	if (rating >= 1.5) {
		[s2 setImage:partlySelectedImage];
	}
	if (rating >= 2) {
		[s2 setImage:fullySelectedImage];
	}
	if (rating >= 2.5) {
		[s3 setImage:partlySelectedImage];
	}
	if (rating >= 3) {
		[s3 setImage:fullySelectedImage];
	}
	if (rating >= 3.5) {
		[s4 setImage:partlySelectedImage];
	}
	if (rating >= 4) {
		[s4 setImage:fullySelectedImage];
	}
	if (rating >= 4.5) {
		[s5 setImage:partlySelectedImage];
	}
	if (rating >= 5) {
		[s5 setImage:fullySelectedImage];
	}
    
 
	
	starRating = rating;
	lastRating = rating;
	[viewDelegate ratingChanged:rating];
}

//-(void) touchesBegan: (NSSet *)touches withEvent: (UIEvent *)event
//{
//    [super touchesBegan:touches withEvent:event];
//	[self touchesMoved:touches withEvent:event];
//}
//
//-(void) touchesMoved: (NSSet *)touches withEvent: (UIEvent *)event
//{
//    [super touchesMoved:touches withEvent:event];
//    
//	CGPoint pt = [[touches anyObject] locationInView:self];
//	int newRating = (int) (pt.x / width) + 1;
//	if (newRating < 1 || newRating > 5)
//		return;
//	
//	if (newRating != lastRating)
//    {
//        [self displayRating:newRating];
//    }else{
//        [self displayRating:newRating-1];
//    }
//}
//
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    [super touchesEnded:touches withEvent:event];
//	[self touchesMoved:touches withEvent:event];
//}

- (void)tapAction:(UITapGestureRecognizer*)tap{
    [self displayRating:tap.view.tag-1000];
}


-(float)rating {
	return starRating;
}

@end
