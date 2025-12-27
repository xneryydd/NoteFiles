//
//  BarButtonItemAdd.m
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/17.
//

#import "BarButtonItems.h"

@implementation BarButtonItemAdd

- (void)setupTargetAction:(id<BarButtonItemAddDelegate>)delegate {
    self.delegate = delegate;
    
    // 清除旧的target-action，防止重复
    [self.target removeTarget:self action:@selector(buttonTapped)];
    
    // 绑定点击事件
    [self setTarget:self];
    [self setAction:@selector(buttonTapped)];
}

- (void)buttonTapped {
    if ([self.delegate respondsToSelector:@selector(barButtonItemAddDidTap:)]) {
        [self.delegate barButtonItemAddDidTap:self];
    }
}

@end
