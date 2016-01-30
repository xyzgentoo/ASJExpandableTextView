//
//  ViewController.m
//  ASJExpandableTextViewExample
//
//  Created by sudeep on 08/07/15.
//  Copyright (c) 2015 Sudeep Jaiswal. All rights reserved.
//

#import "ViewController.h"
#import "ASJExpandableTextView.h"
#import "SLogger.h"

#define kDefaultCommentViewHeight (45.0f)
#define kDefaultTextViewHeight (33.0f)

@interface ViewController ()

// 评论框View
@property(nonatomic, strong) UIView *commentView;

// 可变高度的文字输入框
@property(nonatomic, strong) ASJExpandableTextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupCommentView];

    [self setupTextView];

    [self setupSendButton];
}

- (void)setupCommentView {
    CGRect commentFrame = (CGRect) {.origin = {0.0f, 200.0f}, .size = {CGRectGetWidth(self.view.frame), kDefaultCommentViewHeight}};
    self.commentView = [[UIView alloc] initWithFrame:commentFrame];
    _commentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_commentView];
}

- (void)setupTextView {
    CGFloat height = kDefaultTextViewHeight;
    CGFloat xOffset = 8.0f;
    CGFloat yOffset = (CGRectGetHeight(self.commentView.frame) - height)/2;
    // 先设置字体大小
    CGFloat fontSize = 15.0f;

    CGFloat screenWidth = CGRectGetWidth(self.view.frame);

    self.textView = [[ASJExpandableTextView alloc] initWithFrame:CGRectZero];
    _textView.font = [UIFont systemFontOfSize:fontSize];
    // 这块是为了迎合设计的需求, 同时保证字看着比较顺眼
    _textView.textContainer.lineFragmentPadding = 2.0f;

    // 根据字体大小,上下间隔,行间距计算初始单行的控件高度, >= 这个高度可以保证用户focus时, 不会出现奇怪的滑动
    CGFloat heightNoScrollOnFocus = _textView.textContainerInset.top + _textView.textContainerInset.bottom + fontSize + _textView.textContainer.lineFragmentPadding;
    SLog(@"heightNoScrollOnFocus: %f", heightNoScrollOnFocus);
    NSAssert(heightNoScrollOnFocus <= height, @"Well, if smaller than this, it will scroll on gaining focus.");

    CGRect textFrame = (CGRect) {.origin = {xOffset, yOffset},
            .size = {screenWidth - 2 * xOffset, height}};
    _textView.frame = textFrame;

    _textView.placeholder = @"Type something here...";
    _textView.isExpandable = YES;
    _textView.maximumLineCount = 2;
    _textView.returnKeyType = UIReturnKeyDefault;
    _textView.backgroundColor = [UIColor lightGrayColor];
    _textView.placeholderTextColor = [UIColor blackColor];
    _textView.layer.masksToBounds = YES;
    _textView.layer.cornerRadius = 4.0f;
    __weak typeof(self) weakSelf = self;
    _textView.heightChangedBlock = ^(CGFloat newHeight) {
        SLog(@"!! newHeight: %f", newHeight);
        CGFloat commentHeight = kDefaultCommentViewHeight + newHeight - kDefaultTextViewHeight;
        CGFloat commentYOffset = CGRectGetMaxY(weakSelf.commentView.frame) - commentHeight;
        CGRect frame = weakSelf.commentView.frame;
        SLog(@"!! old frame: %@", NSStringFromCGRect(frame));
        frame.origin.y = commentYOffset;
        frame.size.height = commentHeight;
        SLog(@"!! new frame: %@", NSStringFromCGRect(frame));
        weakSelf.commentView.frame = frame;
    };

    [_commentView addSubview:_textView];
}

- (void)setupSendButton {
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    CGFloat yOffset = CGRectGetMaxY(_commentView.frame);
    CGRect buttonFrame = (CGRect) {.origin = {0.0f, yOffset}, .size = {60.0f, 30.0f}};
    sendButton.frame = buttonFrame;
    [sendButton setBackgroundColor:[UIColor yellowColor]];
    [sendButton addTarget:self action:@selector(clickSendButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendButton];
}

- (void)clickSendButton:(id)clickSendButton {
    NSLog(@"clicked!");
}

@end
