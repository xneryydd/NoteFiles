//
//  ImageViewController.h
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/29.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ImageViewMode) {
    ImageViewModePreview,   // 只查看
    ImageViewModeInsert     // 插入图片
};

@interface ImageViewController : UIViewController

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) ImageViewMode mode;
@property (nonatomic, copy) void (^onInsertConfirm)(void);

@end
