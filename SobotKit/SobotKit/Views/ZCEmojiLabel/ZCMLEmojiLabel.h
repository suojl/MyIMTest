//
//  ZCMLEmojiLabel.h
//  ZCMLEmojiLabel
//
//  Created by molon on 5/19/14.
//  Copyright (c) 2014 molon. All rights reserved.
//

#import "ZCTTTAttributedLabel.h"

/**
 *  ZCMLEmojiLabelLinkType
 */
typedef NS_OPTIONS(NSUInteger, ZCMLEmojiLabelLinkType) {
    /** url type */
    ZCMLEmojiLabelLinkTypeURL = 0,
    /** Email type */
    ZCMLEmojiLabelLinkTypeEmail,
    /** PhoneNumber Type */
    ZCMLEmojiLabelLinkTypePhoneNumber,
    /** At Type */
    ZCMLEmojiLabelLinkTypeAt,
    /** PoundSign Type */
    ZCMLEmojiLabelLinkTypePoundSign,
};


@class ZCMLEmojiLabel;
@protocol ZCMLEmojiLabelDelegate <ZCTTTAttributedLabelDelegate>

@optional
- (void)ZCMLEmojiLabel:(ZCMLEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(ZCMLEmojiLabelLinkType)type;


@end

/**
 * ZCMLEmojiLabel
 */
@interface ZCMLEmojiLabel : ZCTTTAttributedLabel

@property (nonatomic, assign) BOOL disableEmoji; //禁用表情
@property (nonatomic, assign) BOOL disableThreeCommon; //禁用电话，邮箱，连接三者

@property (nonatomic, assign) BOOL isNeedAtAndPoundSign; //是否需要话题和@功能，默认为不需要

@property (nonatomic, copy) NSString *customEmojiRegex; //自定义表情正则
@property (nonatomic, copy) NSString *customEmojiPlistName; //xxxxx.plist 格式
@property (nonatomic, copy) NSString *customEmojiBundleName; //自定义表情图片所存储的bundleName xxxx.bundle格式

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-property-synthesis"
@property (nonatomic, weak) id<ZCMLEmojiLabelDelegate> delegate; //点击连接的代理方法
#pragma clang diagnostic pop

@property (nonatomic, copy, readonly) id emojiText; //外部能获取text的原始副本

- (CGSize)preferredSizeWithMaxWidth:(CGFloat)maxWidth;


-(void)setLinkColor:(UIColor *) color;

/**
 *  提取A标签中的内容
 *
 *  @param searchText 输入内容
 *   text,返回实际文本
 *   arr,返回的字典，包含内容
 *   realFromIndex:链接的点击坐标，长度同htmlText
 *   url:标签的URL
 *   htmlText:标签显示内容
 *
 *  @return NSMutableDictionary
 */
-(NSMutableDictionary *) getTextADict:(NSString *) searchText;


@end
