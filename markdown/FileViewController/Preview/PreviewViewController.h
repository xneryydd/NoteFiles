//
//  PreviewViewController.h
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/8/4.
//

#import <UIKit/UIKit.h>
#import "../FileViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PreviewViewController : FileViewController




- (instancetype)initWithHTMLURL:(NSURL *)htmlURL;
- (instancetype)initWithHTMLContent:(NSString *)htmlContent originalFileURL:(NSURL *)originalFileURL;

//- (void)prepareAndLoadHTML;

- (void)exportPDFWithCompletion:(void (^)(NSData * _Nullable pdfData))completion;

@end

NS_ASSUME_NONNULL_END
