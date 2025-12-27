//
//  FloatingWindow.h
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FloatingWindow;

@protocol FloatWindowDelegate <NSObject>

@required

- (void)highlightTextInTextView:(NSString *)searchText;

- (int)scrollToMatchAtIndex:(NSInteger)index;

- (int)goToNextMatch;


@end


@interface FloatingWindow : UIView

@property (nonatomic, copy) void (^onClose)(void);

@property (nonatomic, weak) id<FloatWindowDelegate> delegate;

@property (nonatomic, strong) UITextField *searchTextField;

@property (nonatomic, strong) UITextField *searchIndexField;

//- (void)setInputAccessoryView:(UIView *)inputAccessoryView;

@end

NS_ASSUME_NONNULL_END
