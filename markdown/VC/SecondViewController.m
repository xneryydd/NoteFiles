//
//  SecondViewController.m
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/27.
//

#import "SecondViewController.h"
#import "../CreateFileAlter/ImagePickerHelper.h"
#import "../FileViewController/FileViewController.h"
#import "../GlobalInfoManager/GlobalInfoManager.h"
#import "../FileService/FileService.h"

@interface SecondViewController () <UIScrollViewDelegate,  UISearchBarDelegate, BarButtonItemAddDelegate, FileListViewDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UISearchBar *navSearchBar;

//@property (strong, nonatomic) FileViewController *fileVC;



@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    self.navSearchBar = [[UISearchBar alloc] init];
    self.navSearchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.navSearchBar.delegate = self;
    CGRect searchBarFrame = [self.searchBar convertRect:self.searchBar.bounds toView:self.view];
    CGRect newFrame = CGRectMake(0,
                                 91,
                                 searchBarFrame.size.width,
                                 searchBarFrame.size.height);
    self.navSearchBar.frame = newFrame;
    self.navSearchBar.hidden = YES; // 初始隐藏
    self.navSearchBar.backgroundColor = UIColor.blackColor;
    self.navSearchBar.placeholder = @"搜索";
    [self.view addSubview:self.navSearchBar];
    [self.view bringSubviewToFront:self.navSearchBar]; // 确保在 scrollView 之上

    if (self.fileListView) {
        // 你希望 FileListView 填满 self.filesView，而不是 self.view
        
        _fileListView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.fileListView loadFileListIfNeededForType:FileTypeImage];
        
        self.fileListView.delegate = self;
        
        // 如果你想控制 filesView 的大小/位置
        self.fileListView.frame = CGRectMake(0, 112, 393, 700);
    }
    
    if (self.BarButtonItemRight2) {
        [self.BarButtonItemRight2 setupTargetAction:self];
        [self.BarButtonItemLeft1 setTarget:self];
        [self.BarButtonItemLeft1 setAction:@selector(comebackFolder)];

        
        // 使用系统图标设置 BarButtonItemRight2（添加图标）
        UIImage *addImage = [UIImage systemImageNamed:@"plus"];
        self.BarButtonItemRight2.image = addImage;
    }
    
    // 使用系统图标设置 BarButtonItemLeft1（返回图标）
    UIImage *backImage = [UIImage systemImageNamed:@"chevron.left"];
    self.BarButtonItemLeft1.image = backImage;
    self.BarButtonItemLeft1.target = self;


    
    // 设置 scrollView 的 delegate
    self.scrollView.delegate = self;
    
    
    // 其他app打开时执行
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleOpenFile:)
                                                 name:@"OpenFileNotification"
                                               object:nil];
    
    // 设置为导航控制器代理
    if (self.navigationController) {
        self.navigationController.delegate = self;
        
        
    }
    
}

#pragma mark - 滑动功能
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 获取 searchBar 相对于 view 的位置
    CGRect searchBarFrame = [self.searchBar convertRect:self.searchBar.bounds toView:self.view];
    
    CGFloat thresholdY = self.view.safeAreaInsets.top ; // 导航栏底部
    if (searchBarFrame.origin.y <= thresholdY) {
//        NSLog(@"w: %f, h: %f, x: %f, y: %f", self.smallLabel.frame.size.width, self.scrollView.frame.size.height, self.scrollView.frame.origin.x, self.scrollView.frame.origin.y);
        
        // 吸顶效果：替换为导航栏上的 searchBar
        self.navSearchBar.text = self.searchBar.text;
        
        if (self.fileListView) {
            self.titleLabel.text = self.fileListView.folderURL;
        }
        
        self.navSearchBar.hidden = NO;
        self.searchBar.alpha = 0.0;
        self.searchBar.userInteractionEnabled = NO; // 禁止交互
        
    } else {
        // 回到原位：移除导航栏 searchBar，显示原来的
        self.searchBar.text = self.navSearchBar.text;
        
        self.titleLabel.text = @"";
        
        self.navSearchBar.hidden = YES;
        self.searchBar.alpha = 1.0;
        self.searchBar.userInteractionEnabled = YES; // 禁止交互


    
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    // 保持两个 searchBar 同步
    if (searchBar == self.searchBar) {
        self.navSearchBar.text = searchText;
    } else {
        self.searchBar.text = searchText;
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *keyword = searchBar.text;
    [self.fileListView loadFileListWithKeyword:keyword];
    [searchBar resignFirstResponder]; // 隐藏键盘
}

#pragma mark - BarButtonItem
- (void)barButtonItemAddDidTap:(nonnull BarButtonItemAdd *)button {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"请选择操作"
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    // 导入图片操作
    UIAlertAction *importImageAction = [UIAlertAction actionWithTitle:@"导入图片"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * _Nonnull action) {
        [ImagePickerHelper presentImagePickerFromVC:self
                                            fileURL:self.fileListView.folderURL
                                         completion:^(BOOL success, NSString * _Nullable savedPath) {
            if (success) {
                if (self.fileListView) {
                    [self.fileListView reloadData];
                }
                NSLog(@"✅ 图片保存成功: %@", savedPath);
            } else {
                NSLog(@"❌ 图片保存失败或取消");
            }
        }];
    }];
    
    // 创建文件夹操作
    UIAlertAction *createFolderAction = [UIAlertAction actionWithTitle:@"创建文件夹"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
        [self showCreateFolderAlert];
    }];
    
    // 取消操作
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [actionSheet addAction:importImageAction];
    [actionSheet addAction:createFolderAction];
    [actionSheet addAction:cancelAction];
    
    // iPad 兼容处理（如使用 UIBarButtonItem）
    actionSheet.popoverPresentationController.barButtonItem = button;

    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)showCreateFolderAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"新建文件夹"
                                                                   message:@"请输入文件夹名称"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    // 添加输入框
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"文件夹名称";
    }];
    
    // 创建动作
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"创建"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
        NSString *folderName = alert.textFields.firstObject.text;
        if (folderName.length == 0) return;

        NSString *folderString = [self.fileListView.folderURL stringByAppendingString:@"/"];
        NSString *fullString = [folderString stringByAppendingString:folderName];
        
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        
        NSString *fullPath = [documentsPath stringByAppendingPathComponent:fullString];
        
        NSError *error = nil;
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:fullPath
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:&error];
        if (!success) {
            NSLog(@"创建文件夹失败：%@", error.localizedDescription);
            return;
        } else {
            [self.fileListView reloadData];
        }
    }];
    
    // 取消动作
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [alert addAction:createAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)comebackFolder {
    if ([self.fileListView.folderURL isEqual:@"assert"]) {
        if (self.confirmCallback) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self.fileListView comebackFolder];
    }
}

#pragma mark - 文件打开、删除、改名
- (void)fileListView:(FileListView *)fileListView didSelectString:(NSString *)string {
    // 拼接文件路径
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *fullPath = [documentsPath stringByAppendingPathComponent:string];
    
    // 判断是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        NSLog(@"文件不存在: %@", fullPath);
        return;
    }
    
    // 构造 file URL
    NSURL *fileURL = [NSURL fileURLWithPath:fullPath];
    
    // 调用 FileService 加载图片
    UIImage *image = [FileService readImageFromURL:fileURL];
    if (!image) {
        NSLog(@"无法读取图片：%@", fileURL);
        return;
    }
    
    // 创建并跳转到 ImageVC
    ImageViewController *vc = [[ImageViewController alloc] init];
    vc.image = image;
    
    if (self.imageViewMode == ImageViewModeInsert) {
        vc.mode = self.imageViewMode;
        
        if (self.confirmCallback) {
            __weak typeof(self) weakSelf = self;
            vc.onInsertConfirm = ^() {
                if (weakSelf.confirmCallback) {
                    weakSelf.confirmCallback(string);
                }
                
                // 🔁 回退到 FileVC（pop 2 层）
                NSArray *viewControllers = weakSelf.navigationController.viewControllers;
                for (UIViewController *vc in viewControllers) {
                    if ([vc isKindOfClass:[FileViewController class]]) {
                        [weakSelf.navigationController popToViewController:vc animated:YES];
                        break;
                    }
                }
            };
        }

        
    } else {
        vc.mode = ImageViewModePreview;
    }
    
    
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)fileListView:(FileListView *)fileListView didLongPressNum:(int)num {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:[NSString stringWithFormat:@"是否删除文件"]
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
        [self.fileListView deleteFileWithIndex:num];
    }];
    
    UIAlertAction *renameAction = [UIAlertAction actionWithTitle:@"改名"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
        [self showInputAlertForItemAtIndex:num];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];

    [alert addAction:deleteAction];
    [alert addAction:renameAction];
    [alert addAction:cancelAction];

    // 避免 iPad 或某些系统下崩溃
    alert.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;

    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)showInputAlertForItemAtIndex:(NSInteger)num {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"输入新名称"
                                                                   message:[NSString stringWithFormat:@"编号为 %ld 的文件", (long)num]
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入内容";
    }];

    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
        NSString *input = alert.textFields.firstObject.text;
        
        [self.fileListView renameFileWithIndex:(int)num withNewName:input];
        
    }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];

    [alert addAction:confirm];
    [alert addAction:cancel];

    [self presentViewController:alert animated:YES completion:nil];
}


# pragma mark - 打开其他app文件
- (void)handleOpenFile:(NSNotification *)notification {
    UIViewController *topVC = self.navigationController.topViewController;

    // 如果当前顶部是 fileVC1（或某种 FileVC），先 pop
    if ([topVC isKindOfClass:[FileViewController class]]) {
        [self.navigationController popViewControllerAnimated:YES]; // 异步 pop
        
    } else {
        // 如果不需要 pop，直接 push 新的
        [self whenViewDidAppear];
    }
}

- (void)navigationController:(UINavigationController *)navigationController
      didShowViewController:(UIViewController *)viewController
                   animated:(BOOL)animated {
    // 确保当前显示的是 VC 且我们之前标记了需要 push
    if (viewController == self) {
        // 确保 push 在 pop 动画完成后执行
        [self whenViewDidAppear];
    }
}

- (void)whenViewDidAppear {
    NSLog(@"准备打开文件");
    
    NSURL *fileURL = [GlobalInfoManager sharedManager].url;
    
    if (fileURL) {
        // 可选清空，避免重复打开
        [GlobalInfoManager sharedManager].url = nil;
        
        [self openOtherFileWith:fileURL];
        
    }
}

- (void)openOtherFileWith:(NSURL *)fileURL {
    
    FileViewController *fileVC = [FileViewController fileViewControllerWithURL:fileURL];
    
    [self.navigationController pushViewController:fileVC animated:YES];

}


@end
