//
//  FloatingWindow.m
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/25.
//


#import "FloatingWindow.h"

@interface FloatingWindow () <UITextFieldDelegate>


@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *toggleButton;

@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UIButton *nextButton;

// accessory view
@property (nonatomic, strong) UIView *customInputAccessoryView;


@property (nonatomic, assign) BOOL isExpanded;

@property (nonatomic, assign) BOOL isChange;

@end


@implementation FloatingWindow

- (instancetype)initWithFrame:(CGRect)frame {
    // 强制最小宽高
    CGFloat minWidth = 260;
    CGFloat minHeight = 130;

    frame.size.width = MAX(frame.size.width, minWidth);
    frame.size.height = MAX(frame.size.height, minHeight);
    
    self = [super initWithFrame:frame];
    if (self) {
        self.isExpanded = YES;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        self.layer.cornerRadius = 10;
        self.clipsToBounds = YES;
        
        // 关闭按钮
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.closeButton.frame = CGRectMake(self.bounds.size.width - 35, 10, 25, 25);
        [self.closeButton setTitle:@"×" forState:UIControlStateNormal];
        [self.closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(closeWindow) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeButton];

        // 展开/收缩按钮
        self.toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.toggleButton.frame = CGRectMake(10, 10, 60, 25);
        [self.toggleButton setTitle:@"收起" forState:UIControlStateNormal];
        self.toggleButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.toggleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.toggleButton addTarget:self action:@selector(toggleContent) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.toggleButton];

        // 搜索框（主搜索框）
        self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 45, self.bounds.size.width - 20, 30)];
        self.searchTextField.placeholder = @"请输入搜索内容";
        self.searchTextField.borderStyle = UITextBorderStyleRoundedRect;
        [self.searchTextField addTarget:self action:@selector(searchTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [self addSubview:self.searchTextField];

        // 搜索第几个 TextField（数字）
        UITextField *searchIndexField = [[UITextField alloc] initWithFrame:CGRectMake(10, 85, 80, 30)];
        searchIndexField.placeholder = @"第几个";
        searchIndexField.keyboardType = UIKeyboardTypeNumberPad;
        searchIndexField.borderStyle = UITextBorderStyleRoundedRect;
        self.searchIndexField.keyboardType = UIKeyboardTypeNumberPad;
        self.searchIndexField.delegate = self;
        [self addSubview:searchIndexField];
        self.searchIndexField = searchIndexField;

        // 搜索按钮
        self.searchButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.searchButton.frame = CGRectMake(100, 85, 60, 30);
        [self.searchButton setTitle:@"搜索" forState:UIControlStateNormal];
        [self.searchButton addTarget:self action:@selector(searchContents) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.searchButton];

        // 下一处按钮
        self.nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.nextButton.frame = CGRectMake(170, 85, 70, 30);
        [self.nextButton setTitle:@"下一处" forState:UIControlStateNormal];
        [self.nextButton addTarget:self action:@selector(nextContent) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.nextButton];


        // 拖动手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
        
        [self canBecomeFocused];
    }
    return self;
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    if (textField == self.searchIndexField) {
        NSCharacterSet *nonDigitSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        return ([string rangeOfCharacterFromSet:nonDigitSet].location == NSNotFound);
    }
    return YES;
}

- (void)searchTextFieldDidChange:(UITextField *)textField {
    self.isChange = YES;
}

#pragma mark - 组件功能
- (void)toggleContent {
    self.isExpanded = !self.isExpanded;
    
    self.searchTextField.hidden = !self.isExpanded;
    self.searchIndexField.hidden = !self.isExpanded;
    self.searchButton.hidden = !self.isExpanded;
    self.nextButton.hidden = !self.isExpanded;
    
    NSString *title = self.isExpanded ? @"收起" : @"展开";
    [self.toggleButton setTitle:title forState:UIControlStateNormal];
}

- (void)closeWindow {
    [self removeFromSuperview];
    if (self.onClose) {
        self.onClose();
    }
}

- (void)searchContents {
    NSString *textString = self.searchTextField.text;
    if (self.delegate) {
        if (_isChange) {
            [self.delegate highlightTextInTextView:textString];
            self.searchIndexField.text = @"1";
            
        } else {
            NSInteger value = [self.searchIndexField.text integerValue];
            int num = (int)value;
            
            
            
            int returnNum = [self.delegate scrollToMatchAtIndex:num] + 1;
            
            self.searchIndexField.text = [NSString stringWithFormat:@"%ld", (long)returnNum];
        }
    }
}

- (void)nextContent {
    if (self.delegate) {
        int num = [self.delegate goToNextMatch] + 1;

        self.searchIndexField.text = [NSString stringWithFormat:@"%ld", (long)num];

    }
}

#pragma mark - 手势处理
- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.superview];
    self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
    [pan setTranslation:CGPointZero inView:self.superview];
}

#pragma mark - 键盘设置
//- (UIView *)inputAccessoryView {
//    return self.customInputAccessoryView;
//}
//
//- (void)setInputAccessoryView:(UIView *)inputAccessoryView {
//    self.customInputAccessoryView = inputAccessoryView;
//    
//    
//    
//    
//}
//
//- (BOOL)canBecomeFirstResponder {
//    return YES;
//}


@end
