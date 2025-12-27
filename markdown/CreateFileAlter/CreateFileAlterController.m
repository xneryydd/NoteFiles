//
//  CreateFileAlterController.m
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/17.
//

#import "CreateFileAlterController.h"
#import "../FileService/FileService.h"


@interface CreateFileAlertController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) NSString *selectedType;
@property (nonatomic, copy) void (^onFinish)(NSString *filePath);
@property (nonatomic, strong) NSArray<NSString *> *fileTypes;
@property (nonatomic, strong) UIPickerView *pickerView;

@end

@implementation CreateFileAlertController

+ (instancetype)createAlertWithCompletion:(void(^)(NSString *filePath))onFinish withFileString:(NSString *)fileString {
    CreateFileAlertController *alert = [super alertControllerWithTitle:@"创建文件"
                                                               message:@"请输入文件名并选择类型"
                                                        preferredStyle:UIAlertControllerStyleAlert];

    alert.selectedType = @"txt";
    alert.onFinish = onFinish;
    alert.fileTypes = @[@"txt", @"md", @"json", @"folder"];
    alert.pickerView = [[UIPickerView alloc] init];
    alert.pickerView.delegate = alert;
    alert.pickerView.dataSource = alert;

    // 添加输入框：文件名
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"文件名（不含扩展名）";
    }];

    // 添加输入框：文件类型（用 UIPickerView 作为输入视图）
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"选择文件类型";
        textField.inputView = alert.pickerView;
        textField.text = @"txt"; // 默认类型
    }];

    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"确认创建" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *fileNameInput = alert.textFields.firstObject.text;
        NSString *typeInput = alert.textFields[1].text;

        if (fileNameInput.length == 0) {
            NSLog(@"文件名不能为空");
            return;
        }

        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *fullPath;
        
        
        
        NSString *theFileString = [fileString stringByAppendingString:@"/"];

        if ([typeInput isEqualToString:@"folder"]) {
            // 🔧 创建文件夹，不加后缀名
            
            NSString *fileNameString = [theFileString stringByAppendingString:fileNameInput];
            fullPath = [documentsPath stringByAppendingPathComponent:fileNameString];
            
            
            NSError *error = nil;
            BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:fullPath
                                                     withIntermediateDirectories:YES
                                                                      attributes:nil
                                                                           error:&error];
            if (!success) {
                NSLog(@"创建文件夹失败：%@", error.localizedDescription);
                return;
            }
        } else {
            // 🗂️ 创建普通文件（加后缀）
            NSString *fullFileName = [NSString stringWithFormat:@"%@.%@", fileNameInput, typeInput];
            NSString *fileNameString = [theFileString stringByAppendingString:fullFileName];
            fullPath = [documentsPath stringByAppendingPathComponent:fileNameString];

            NSString *defaultContent = @"文件已创建";
            BOOL success = [FileService createTextFileIfNeeded:fileNameString withContent:defaultContent isRepeat:YES];
            if (!success) {
                NSLog(@"创建文件失败");
                return;
            }
        }

        // ✅ 通知完成
        if (alert.onFinish) {
            alert.onFinish(fullPath);
        }
    }];


    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];

    [alert addAction:createAction];
    [alert addAction:cancelAction];

    return alert;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.fileTypes.count;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.fileTypes[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedType = self.fileTypes[row];
    self.textFields[1].text = self.selectedType;
}

@end
