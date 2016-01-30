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
#import "ExpandableTextView.h"

#define kDefaultCommentViewHeight (45.0f)
#define kDefaultTextViewHeight (33.0f)

@interface ViewController ()

// 评论框View
@property(nonatomic, strong) UIView *commentView;

// 可变高度的文字输入框
@property(nonatomic, strong) ExpandableTextView *textView;

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

    self.textView = [[ExpandableTextView alloc] initWithFrame:CGRectZero];
    _textView.font = [UIFont systemFontOfSize:fontSize];

    CGRect textFrame = (CGRect) {.origin = {xOffset, yOffset}, .size = {screenWidth - 2 * xOffset, height}};
    _textView.frame = textFrame;

    _textView.placeholderText = @"Type something here...";
    _textView.placeholderTextColor = [UIColor blackColor];

    _textView.maxNumberOfLines = 2;

    _textView.returnKeyType = UIReturnKeyDefault;
    _textView.backgroundColor = [UIColor lightGrayColor];
    _textView.layer.masksToBounds = YES;
    _textView.layer.cornerRadius = 4.0f;

    __weak typeof(self) weakSelf = self;
    _textView.heightChangedBlock = ^(CGFloat heightChange) {
        SLog(@"heightChange: %f", heightChange);
        CGFloat commentHeight = CGRectGetHeight(weakSelf.commentView.frame) + heightChange;
        CGFloat commentYOffset = CGRectGetMaxY(weakSelf.commentView.frame) - commentHeight;
        CGRect frame = weakSelf.commentView.frame;
        SLog(@"old frame: %@", NSStringFromCGRect(frame));
        frame.origin.y = commentYOffset;
        frame.size.height = commentHeight;
        SLog(@"new frame: %@", NSStringFromCGRect(frame));
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
    if ([_textView isFirstResponder]) {
        [_textView resignFirstResponder];
    }
}

@end
