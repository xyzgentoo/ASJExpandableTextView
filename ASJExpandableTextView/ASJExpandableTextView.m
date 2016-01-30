// ASJExpandableTextView.m
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

#import "ASJExpandableTextView.h"
#import "SLogger.h"

typedef void (^AccessoryViewDoneBlock)(void);

@interface ASJInputAccessoryView : UIView

@property(copy) AccessoryViewDoneBlock doneTappedBlock;

@end

@implementation ASJInputAccessoryView

- (IBAction)doneButtonTapped:(UIBarButtonItem *)sender {
    if (_doneTappedBlock) {
        _doneTappedBlock();
    }
}

@end


@interface ASJExpandableTextView () {
    UILabel *placeholderLabel;
    NSUInteger currentLine;
    CGFloat previousContentHeight, defaultTextViewHeight, defaultContentHeight;
    BOOL isPlaceholderVisible, areLayoutDefaultsSet;
}

@property(weak, nonatomic) ASJInputAccessoryView *asjInputAccessoryView;
@property(nonatomic) CGFloat heightOfOneLine;
@property(nonatomic) CGFloat currentContentHeight;
@property(nonatomic) CGFloat currentTextViewHeight;
@property(nonatomic) BOOL shouldShowPlaceholder;
@property(nonatomic) NSLayoutConstraint *heightConstraint;

- (void)setup;

- (void)setLayoutDefaults;

- (void)prepareInputAccessoryView;

- (void)setDefaults;

- (void)executeDefaultFontHack;

- (void)setPlaceholderLabel;

- (void)listenForNotifications;

- (void)handleTextChange;

- (void)handleExpansion;

- (void)handleNextLine;

- (void)handlePreviousLine;

- (void)animateConstraintToHeight:(CGFloat)height;

- (void)animateFrameToHeight:(CGFloat)height;

- (void)scrollToBottom;

@end

@implementation ASJExpandableTextView

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!areLayoutDefaultsSet && _isExpandable) {
        [self setLayoutDefaults];
        areLayoutDefaultsSet = YES;
    }
    if (!placeholderLabel) {
        [self setPlaceholderLabel];
    }
}

- (void)setLayoutDefaults {
    currentLine = 1;
    defaultContentHeight = self.contentSize.height;
    defaultTextViewHeight = self.frame.size.height;
    previousContentHeight = _currentContentHeight = defaultContentHeight;
}

#pragma mark - Accessory view

- (BOOL)becomeFirstResponder {
    if (_shouldShowDoneButtonOverKeyboard) {
        [self prepareInputAccessoryView];
    }
    return [super becomeFirstResponder];
}

- (void)prepareInputAccessoryView {
    ASJInputAccessoryView *inputAccessoryView = self.asjInputAccessoryView;
    inputAccessoryView.doneTappedBlock = ^{
        [self resignFirstResponder];
        if (_doneTappedBlock) {
            _doneTappedBlock(self.text);
        }
    };
    self.inputAccessoryView = inputAccessoryView;
}

- (ASJInputAccessoryView *)asjInputAccessoryView {
    return (ASJInputAccessoryView *) [[NSBundle mainBundle] loadNibNamed:@"ASJInputAccessoryView" owner:self options:nil][0];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setup

- (void)setup {
    [self setDefaults];
    [self executeDefaultFontHack];
    [self listenForNotifications];
}

- (void)setDefaults {
    _isExpandable = NO;
    _maximumLineCount = 4;
    _shouldShowDoneButtonOverKeyboard = NO;
    self.shouldShowPlaceholder = NO;
}

- (void)executeDefaultFontHack {
    /**
     Unless text is set, self.font is nil, it doesn't seem to initialise when the text view is created.
     */
    self.text = @"weirdness";
    self.text = nil;
}

- (void)setPlaceholderTextColor:(UIColor *)placeholderTextColor {
    if (nil != placeholderTextColor && _placeholderTextColor != placeholderTextColor) {
        _placeholderTextColor = placeholderTextColor;

        if (nil != placeholderLabel) {
            placeholderLabel.textColor = _placeholderTextColor;
        }
    }
}

- (void)setPlaceholderLabel {
    placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    placeholderLabel.enabled = YES;
    placeholderLabel.highlighted = NO;
    placeholderLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    placeholderLabel.numberOfLines = 1;
    placeholderLabel.textColor = _placeholderTextColor;
    placeholderLabel.text = self.placeholder;
    placeholderLabel.font = self.font;
    placeholderLabel.backgroundColor = [UIColor clearColor];
    [placeholderLabel sizeToFit];

    // 这里的4.0f是为了match text view caret的起始位置
    CGFloat x = 4.0f;
    CGFloat y = self.textContainerInset.top;
    CGFloat width = self.frame.size.width - (2.0f * x);
    CGFloat height = CGRectGetHeight(placeholderLabel.frame);
    placeholderLabel.frame = CGRectMake(x, y, width, height);

    [self addSubview:placeholderLabel];

    if (self.text.length) {
        self.shouldShowPlaceholder = NO;
    }
}

#pragma mark - Text change

- (void)listenForNotifications {
    [[NSNotificationCenter defaultCenter]
            addObserverForName:UITextViewTextDidBeginEditingNotification
                        object:self queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *note) {
                        [self handleTextChange];
                    }];

    [[NSNotificationCenter defaultCenter]
            addObserverForName:UITextViewTextDidChangeNotification
                        object:self queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *note) {
                        [self handleTextChange];
                        if (_isExpandable) {
                            [self handleExpansion];
                        }
                    }];
}

- (void)handleTextChange {
    if (self.text.length) {
        self.shouldShowPlaceholder = NO;
        return;
    }
    if (!isPlaceholderVisible) {
        self.shouldShowPlaceholder = YES;;
    }
}

- (void)handleExpansion {
    BOOL isOnCurrentLine = self.currentContentHeight == previousContentHeight;

    if (isOnCurrentLine) {
        return;
    }

    SLog(@"currentContentHeight: %f previousContentHeight: %f", self.currentContentHeight, previousContentHeight);
    BOOL isOnNextLine = self.currentContentHeight > previousContentHeight;
    previousContentHeight = self.currentContentHeight;

    if (isOnNextLine) {
        [self handleNextLine];
        return;
    }

    [self handlePreviousLine];
}

- (CGFloat)currentContentHeight {
//    SLog(@"contentSize.height: %f", self.contentSize.height);
    return self.contentSize.height;
}

#pragma mark - Next and previous lines

- (void)handleNextLine {
    currentLine++;
    if (currentLine > _maximumLineCount) {
        return;
    }

    SLog(@"currentContentHeight: %f currentTextViewHeight: %f", self.currentContentHeight, self.currentTextViewHeight);
    if (self.currentContentHeight <= self.currentTextViewHeight) {
        return;
    }

    CGFloat newHeight = 0.0;
    BOOL isHeightConstraintAvailable = self.heightConstraint != nil;
    if (isHeightConstraintAvailable) {
        newHeight = self.heightConstraint.constant + self.heightOfOneLine;
        [self animateConstraintToHeight:newHeight];
    } else {
        SLog(@"newHeight - currentTextViewHeight: %f heightOfOneLine: %f", self.currentTextViewHeight, self.heightOfOneLine);
        newHeight = self.currentTextViewHeight + self.heightOfOneLine;
        [self animateFrameToHeight:newHeight];
    }
}

- (void)handlePreviousLine {
    SLogFunc();

    currentLine--;

    SLog(@"currentContentHeight: %f currentTextViewHeight: %f", self.currentContentHeight, self.currentTextViewHeight);
    // 这里有个1.0f的magic number...
    if (self.currentContentHeight + 1.0f >= self.currentTextViewHeight) {
        return;
    }

    SLog(@"defaultTextViewHeight: %f", defaultTextViewHeight);
    if (self.currentTextViewHeight <= defaultTextViewHeight) {
        return;
    }

    CGFloat newHeight = 0.0;
    BOOL isHeightConstraintAvailable = self.heightConstraint != nil;
    if (isHeightConstraintAvailable) {
        newHeight = self.heightConstraint.constant - self.heightOfOneLine;
        SLog(@"newHeight 1: %f", newHeight);
        [self animateConstraintToHeight:newHeight];
    } else {
        newHeight = self.currentTextViewHeight - self.heightOfOneLine;
        SLog(@"newHeight 2: %f", newHeight);
        [self animateFrameToHeight:newHeight];
    }
}

- (CGFloat)heightOfOneLine {
    return self.font.lineHeight;
}

- (void)animateConstraintToHeight:(CGFloat)height {
    [self.superview layoutIfNeeded];
    self.heightConstraint.constant = height;
    [UIView animateWithDuration:0.30
                          delay:0.0
                        options:UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         [self scrollToBottom];
                         [self.superview layoutIfNeeded];
                     } completion:nil];

    if (_heightChangedBlock) {
        _heightChangedBlock(height);
    }
}

- (void)animateFrameToHeight:(CGFloat)height {
    if (_heightChangedBlock) {
        _heightChangedBlock(height);
    }

    [UIView animateWithDuration:0.25f
                          delay:0.0
                        options:UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         CGFloat x = self.frame.origin.x;
                         CGFloat y = self.frame.origin.y;
                         CGFloat width = self.frame.size.width;
                         self.frame = CGRectMake(x, y, width, height);
                     } completion:nil];
}

- (NSLayoutConstraint *)heightConstraint {
    for (NSLayoutConstraint *constraint in self.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            return constraint;
        }
    }
    return nil;
}

- (CGFloat)currentTextViewHeight {
    return self.frame.size.height;
}

- (void)scrollToBottom {
    NSRange range = NSMakeRange(self.text.length - 1, 1);
    [self scrollRangeToVisible:range];
}

#pragma mark - Property setter overrides

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    placeholderLabel.text = _placeholder;
    [placeholderLabel sizeToFit];
    self.shouldShowPlaceholder = YES;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    if (text && text.length) {
        self.shouldShowPlaceholder = NO;
        return;
    }
    self.shouldShowPlaceholder = YES;
}

- (void)setShouldShowPlaceholder:(BOOL)shouldShowPlaceholder {
    _shouldShowPlaceholder = shouldShowPlaceholder;
    if (_shouldShowPlaceholder) {
        placeholderLabel.alpha = 1.0;
        isPlaceholderVisible = YES;
        return;
    }
    placeholderLabel.alpha = 0.0;
    isPlaceholderVisible = NO;
}

@end
