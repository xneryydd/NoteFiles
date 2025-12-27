//
//  ImagePickerHelper.h
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImagePickerHelper : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

/// 从相册选择图片 → 弹窗输入文件名 → 使用 fileURL 路径保存
/// @param vc         当前 ViewController
/// @param fileURL    保存的子路径（如 images/test）
/// @param completion 回调保存结果
+ (void)presentImagePickerFromVC:(UIViewController *)vc
                         fileURL:(NSString *)fileURL
                      completion:(void(^)(BOOL success, NSString * _Nullable savedPath))completion;


@end

NS_ASSUME_NONNULL_END
