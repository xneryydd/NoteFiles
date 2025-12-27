//
//  GlobalInfoManager.m
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/23.
//


#import "GlobalInfoManager.h"
#pragma mark - GlobalInfoManager
@implementation GlobalInfoManager

+ (instancetype)sharedManager {
    static GlobalInfoManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GlobalInfoManager alloc] init];
    });
    return sharedInstance;
}

@end

#pragma mark - TextStyleManager

@implementation TextStyleManager

+ (instancetype)sharedManager {
    static TextStyleManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TextStyleManager alloc] init];
        
        // 默认样式
        manager.textFont = [UIFont systemFontOfSize:14];
        manager.textColor = [UIColor labelColor];
        manager.lineSpacing = 6.0;
    });
    return manager;
}

- (void)applyStyleToTextView:(UITextView *)textView {
    if (!textView.text) textView.text = @"";
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = self.lineSpacing;
    
    NSDictionary *attributes = @{
        NSFontAttributeName: self.textFont,
        NSForegroundColorAttributeName: self.textColor,
        NSParagraphStyleAttributeName: paragraphStyle
    };
    
    textView.attributedText = [[NSAttributedString alloc] initWithString:textView.text attributes:attributes];
}

@end
