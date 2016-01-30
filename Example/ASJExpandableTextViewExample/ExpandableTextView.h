//
// Created by lihong on 16/1/30.
// Copyright (c) 2016
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * 高度变化后的回调block
 *
 * @param newHeight 改变的相对高度, 即变化了多少
 */
typedef void (^HeightChangedBlock)(CGFloat heightChange);


@interface ExpandableTextView : UITextView

// 允许扩展的最大行数
@property(nonatomic, assign) NSUInteger maxNumberOfLines;

// 高度变化的回调block
@property(nonatomic, copy) HeightChangedBlock heightChangedBlock;

// 占位的提示字符串 - 跟text用相同的字体
- (void)setPlaceholderText:(NSString *)placeholderText;

// 占位的字符串用的颜色
- (void)setPlaceholderTextColor:(UIColor *)placeholderTextColor;

@end