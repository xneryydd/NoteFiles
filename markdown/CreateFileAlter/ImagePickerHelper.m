//
//  ImagePickerHelper.m
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/27.
//

#import "ImagePickerHelper.h"

@interface ImagePickerHelper () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, weak) UIViewController *vc;
@property (nonatomic, copy) NSString *fileURL;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, copy) void(^completion)(BOOL success, NSString * _Nullable savedPath);
@end

@implementation ImagePickerHelper

static ImagePickerHelper *_helperInstance;

+ (void)presentImagePickerFromVC:(UIViewController *)vc
                         fileURL:(NSString *)fileURL
                      completion:(void(^)(BOOL success, NSString * _Nullable savedPath))completion {
    _helperInstance = [[ImagePickerHelper alloc] init];
    _helperInstance.vc = vc;
    _helperInstance.fileURL = fileURL ?: @"";  // 防止 nil
    _helperInstance.completion = completion;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = _helperInstance;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = NO;
    
    [vc presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePicker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.selectedImage = image;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        if (!image || !self.vc) {
            if (self.completion) self.completion(NO, nil);
            return;
        }
        
        // 弹出输入框，输入文件名
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"保存图片"
                                                                       message:@"请输入文件名（如 image.jpg）"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"输入文件名";
        }];
        
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *fileName = alert.textFields.firstObject.text;
            if (fileName.length == 0) fileName = @"default.jpg";
            
            // 拼接完整路径
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString *basePath = [documentsPath stringByAppendingPathComponent:@""];
            NSString *dirPath = self.fileURL.length > 0 ? [basePath stringByAppendingPathComponent:self.fileURL] : basePath;
            
            // 创建目录
            NSFileManager *fm = [NSFileManager defaultManager];
            if (![fm fileExistsAtPath:dirPath]) {
                [fm createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            NSString *fullPath = [dirPath stringByAppendingPathComponent:fileName];
            NSData *data = UIImageJPEGRepresentation(self.selectedImage, 0.9);
            BOOL success = NO;
            if (data) {
                success = [data writeToFile:fullPath atomically:YES];
            }
            
            if (self.completion) self.completion(success, success ? fullPath : nil);
        }];
        
        [alert addAction:saveAction];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            if (self.completion) self.completion(NO, nil);
        }]];
        
        [self.vc presentViewController:alert animated:YES completion:nil];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        if (self.completion) self.completion(NO, nil);
    }];
}

@end
