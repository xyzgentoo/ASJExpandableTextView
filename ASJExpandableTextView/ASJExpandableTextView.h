// ASJExpandableTextView.h
// 
// Copyright (c) 2015 Sudeep Jaiswal
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

@import UIKit;

typedef void (^HeightChangedBlock)(CGFloat newHeight);

@interface ASJExpandableTextView : UITextView

/**
 *  Sets the placeholder text when no text has been input.
 */
@property(copy, nonatomic) IBInspectable NSString *placeholder;

/**
 * 设置placeholder text label font color
 */
@property(nonatomic, strong) UIColor *placeholderTextColor;

/**
 *  Sets whether the text view should increase and decrease
 *  in height according to its content.
 */
@property(nonatomic) IBInspectable BOOL isExpandable;

/**
 *  This property is only of use when 'isExpandable' is YES.
 *  Sets the maximum number of visible lines of text.
 */
@property(nonatomic) IBInspectable NSUInteger maximumLineCount;

/**
 *  Set this property "YES" to show a "Done" button over the
 *  keyboard.  Tapping it will hide the keyboard.
 */
@property(nonatomic) IBInspectable BOOL shouldShowDoneButtonOverKeyboard;

/**
 *  A block that will be executed when the height of the text view changes.
 *  Unusable if the text view is not expandable.
 */
@property(copy) HeightChangedBlock heightChangedBlock;

- (void)setHeightChangedBlock:(HeightChangedBlock)heightChangedBlock;

@end
