//
//  GlobalInfoManager.h
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - GlobalInfoManager

@interface GlobalInfoManager : NSObject

/// 全局共享实例
+ (instancetype)sharedManager;

/// 要传递的全局 URL
@property (nonatomic, strong) NSURL *url;

@end

#pragma mark - TextStyleManager

@interface TextStyleManager : NSObject

/// 全局共享实例
+ (instancetype)sharedManager;

/// 可修改属性
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) CGFloat lineSpacing;

/// 应用到 UITextView
- (void)applyStyleToTextView:(UITextView *)textView;

@end



