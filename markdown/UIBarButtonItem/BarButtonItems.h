//
//  BarButtonItemAdd.h
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - BarButtonItemRight

@interface BarButtonItemRight : UIBarButtonItem

@end

#pragma mark - BarButtonItemLeft

@interface BarButtonItemLeft : UIBarButtonItem

@end

#pragma mark - BarButtonItemAddDelegate

@class BarButtonItemAdd;

@protocol BarButtonItemAddDelegate <NSObject>
@required
- (void)barButtonItemAddDidTap:(BarButtonItemAdd *)button;
@end

#pragma mark - BarButtonItemAdd

@interface BarButtonItemAdd : UIBarButtonItem

@property (nonatomic, weak) id<BarButtonItemAddDelegate> delegate;

/// 绑定按钮点击事件（Storyboard 创建时调用）
- (void)setupTargetAction:(id<BarButtonItemAddDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
