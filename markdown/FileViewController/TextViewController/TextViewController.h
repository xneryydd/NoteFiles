//
//  FileViewController.h
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/19.
//

#import <UIKit/UIKit.h>
#import "../FileViewController.h"
#import "../../GlobalInfoManager/GlobalInfoManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface TextViewController : FileViewController

@property (strong, nonatomic) UITextView *lineNumberTextView;
@property (strong, nonatomic) UITextView *contentTextView;

    
@property (strong, nonatomic) NSString *fileName;

// 完整文件路径
@property (strong, nonatomic) NSURL *fileURL;
@end

NS_ASSUME_NONNULL_END
