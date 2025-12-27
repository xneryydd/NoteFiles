//
//  PdfViewController.h
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/8/8.
//

#import <UIKit/UIKit.h>
#import "../FileViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PdfViewController : FileViewController

@property (nonatomic, copy) NSURL *pdfFilePath;

- (instancetype)initWithURL:(NSURL *)fileURL;

@end

NS_ASSUME_NONNULL_END
