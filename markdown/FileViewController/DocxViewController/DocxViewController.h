//
//  DocxViewController.h
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/9/24.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>

NS_ASSUME_NONNULL_BEGIN

@interface DocxViewController : UIViewController

- (instancetype)initWithURL:(NSURL *)fileURL;

@property (nonatomic, strong) NSURL *fileURL;


@end

NS_ASSUME_NONNULL_END
