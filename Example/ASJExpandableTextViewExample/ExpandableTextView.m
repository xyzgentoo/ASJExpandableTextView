//
// Created by lihong on 16/1/30.
// Copyright (c) 2016 Sudeep Jaiswal. All rights reserved.
//

#import "ExpandableTextView.h"
#import "SLogger.h"

@interface ExpandableTextView () {
    // 当前text对应的行数
    NSUInteger _currentNumberOfLines;
}

// 显示占位字符串
@property(nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation ExpandableTextView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    if (self = [super initWithFrame:frame textContainer:textContainer]) {
        [self setup];
    }

    return self;
}

- (void)setup {
    [self listenForNotifications];

    // 默认的最小和最大行数
    _currentNumberOfLines = 1;
    _maxNumberOfLines = 2;

    [self setupPlaceholderLabel];
}

- (void)setupPlaceholderLabel {
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _placeholderLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _placeholderLabel.numberOfLines = 1;
    _placeholderLabel.backgroundColor = [UIColor clearColor];
    _placeholderLabel.text = @"";
    _placeholderLabel.textColor = [UIColor blackColor];

    [self refreshPlaceholderLabel];

    [self addSubview:_placeholderLabel];
}

/**
 * 刷新placeholder的字体和frame
 */
- (void)refreshPlaceholderLabel {
    _placeholderLabel.font = self.font;

    // 这里的4.0f是为了match text view caret的起始位置
    CGFloat x = 4.0f;
    CGFloat y = self.textContainerInset.top;
    CGFloat width = self.frame.size.width - (2.0f * x);
    CGFloat height = self.font.lineHeight;
    _placeholderLabel.frame = CGRectMake(x, y, width, height);
}

#pragma mark - Inherited

/**
 * 当TextView改变的时候, 也同步调整placeholder label
 */
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    [self refreshPlaceholderLabel];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];

    [self refreshPlaceholderLabel];
}

#pragma mark - Placeholder

- (void)setPlaceholderText:(NSString *)placeholderText {
    _placeholderLabel.text = placeholderText;
}

- (void)setPlaceholderTextColor:(UIColor *)placeholderTextColor {
    _placeholderLabel.textColor = placeholderTextColor;
}

#pragma mark - Notifications

- (void)listenForNotifications {
    [[NSNotificationCenter defaultCenter]
            addObserverForName:UITextViewTextDidBeginEditingNotification
                        object:self
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *note) {
                        [self beginTextEditing];
                    }];

    [[NSNotificationCenter defaultCenter]
            addObserverForName:UITextViewTextDidChangeNotification
                        object:self
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *note) {
                        [self beginTextEditing];

                        [self handleExpansion];
                    }];
}

#pragma mark - Text update

- (void)beginTextEditing {
    if (self.text.length && !_placeholderLabel.hidden) {
        // 如果有输入文字, 并且placeholder没有hidden的时候, 就隐藏掉
        _placeholderLabel.hidden = YES;
    } else if (!self.text.length) {
        // 没有输入文字时, 显示placeholder
        _placeholderLabel.hidden = NO;
    }
}

- (void)handleExpansion {
    // 使用contentSize计算文字行数比较准, boundingRectForSize那个计算时, 在临界条件下不太对... 回头再研究一下
    float rawLineNumber = (self.contentSize.height - self.textContainerInset.top - self.textContainerInset.bottom) / self.font.lineHeight;
    NSUInteger numberOfLines = (NSUInteger) round(rawLineNumber);

    // 这里加了个delay是为了保证在下一个runloop再处理, 因为UITextView输入后, 会自己向上移动一下, 当扩大frame时, UI会比较奇怪
    static CGFloat textScrollDelay = 0.1f;

    // 根据设置的最大最小行数调节预期高度
    if (numberOfLines > _maxNumberOfLines) {
        numberOfLines = _maxNumberOfLines;

        // 这里也是为了让文字输入多时, 也能保持好看的UI
        SLog(@"max lines hit, keep better looking");
        [self performSelector:@selector(scrollTextToBottom) withObject:nil afterDelay:textScrollDelay];
    }

    // 文字行数没有变化, 则不进行如下操作
    if (numberOfLines == _currentNumberOfLines) {
        return;
    }

    // 变化的行数, 由这个来计算高度的变化值
    int diffLines = (numberOfLines - _currentNumberOfLines);
    SLog(@"diffLines: %d", diffLines);
    _currentNumberOfLines = numberOfLines;

    // 计算应有的高度
    CGRect expectFrame = self.frame;
    CGFloat height = CGRectGetHeight(self.frame);

    SLog(@"old frame: %@", NSStringFromCGRect(expectFrame));
    // 这里只加上lineHeight, 暂时不考虑lineFragmentPadding... TODO LH 可能应该考虑, 这个控件还没那么完善
    expectFrame.size.height = height + diffLines * self.font.lineHeight;
    SLog(@"new frame: %@", NSStringFromCGRect(expectFrame));

    // 高度变化
    [UIView animateWithDuration:0.25f animations:^{
        self.frame = expectFrame;

        if (_heightChangedBlock) {
            _heightChangedBlock(CGRectGetHeight(expectFrame));
        }
    } completion:^(BOOL completed) {
        SLog(@"text frame expanded");
        [self performSelector:@selector(scrollTextToBottom) withObject:nil afterDelay:textScrollDelay];
    }];
}

/**
 * 确保UITextView中的文字始终是在最下面的
 */
- (void)scrollTextToBottom {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollTextToBottom) object:nil];

    // 只有当前在文本末尾输入时, 才自动移动到text的最后部分 - 可以避免用户在中间部分输入时也调整位置
    if (self.selectedRange.location + self.selectedRange.length == self.text.length) {
        SLog(@"scroll text to bottom and keep them better looking");
        self.contentOffset = CGPointMake(0.0f, self.contentSize.height - self.frame.size.height);
    }
}

@end