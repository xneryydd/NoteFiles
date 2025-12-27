//
//  EditToolbar.m
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/29.
//

#import "EditToolbar.h"

@interface EditToolbar ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttons;
@property (nonatomic, assign) CGFloat preferredHeight;

@end

@implementation EditToolbar

- (instancetype)initWithItems:(NSArray<EditToolbarItem *> *)items preferredHeight:(CGFloat)height {
    self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height)];
    if (self) {
        _preferredHeight = height;
        _buttons = [NSMutableArray array];
        
        // 背景黑色半透明，alpha 0.6
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.alwaysBounceVertical = YES;
        _scrollView.backgroundColor = [UIColor clearColor]; // 透明，显示父视图背景
        
        [self addSubview:_scrollView];
        self.items = items;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
}

- (void)setItems:(NSArray<EditToolbarItem *> *)items {
    _items = [items copy];

    for (UIButton *btn in self.buttons) {
        [btn removeFromSuperview];
    }
    [self.buttons removeAllObjects];

    CGFloat margin = 10;
    CGFloat spacing = 10;
    CGFloat buttonWidth = (self.frame.size.width - 3 * margin) / 2;
    CGFloat buttonHeight = buttonWidth * 0.6;

    int column = 2;

    for (int i = 0; i < _items.count; i++) {
        EditToolbarItem *item = _items[i];

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:item.title forState:UIControlStateNormal];

        // 按钮灰色半透明，alpha 0.5
        btn.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
        // 文字白色
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        btn.titleLabel.font = [UIFont systemFontOfSize:17];
        btn.layer.cornerRadius = 6;
        btn.clipsToBounds = YES;

        int row = i / column;
        int col = i % column;

        CGFloat x = margin + col * (buttonWidth + spacing);
        CGFloat y = margin + row * (buttonHeight + spacing);
        btn.frame = CGRectMake(x, y, buttonWidth, buttonHeight);

        btn.tag = i;
        [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];

        [self.scrollView addSubview:btn];
        [self.buttons addObject:btn];
    }

    NSInteger rowCount = (_items.count + 1) / 2;
    CGFloat totalHeight = margin + rowCount * (buttonHeight + spacing);
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width, totalHeight);
}

- (void)buttonTapped:(UIButton *)sender {
    NSInteger index = sender.tag;
    if (index >= 0 && index < self.items.count) {
        EditToolbarItem *item = self.items[index];
        if (item.action) {
            item.action();
        }
    }
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, self.preferredHeight);
}

@end
