//
// Created by lihong on 16/1/30.
// Copyright (c) 2016 Sudeep Jaiswal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ASJExpandableTextView.h"

/**
 * 高度变化后的回调block
 *
 * @param newHeight 改变后的高度
 */
typedef void (^HeightChangedBlock)(CGFloat newHeight);


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