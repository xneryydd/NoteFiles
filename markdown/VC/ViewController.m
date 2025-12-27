//
//  ViewController.m
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/11.
//

#import "ViewController.h"
#import "../CreateFileAlter/CreateFileAlterController.h"
#import "../FileViewController/FileViewController.h"
#import "../GlobalInfoManager/GlobalInfoManager.h"
#import "../FileService/FileService.h"

@interface ViewController () <UIScrollViewDelegate,  UISearchBarDelegate, BarButtonItemAddDelegate, FileListViewDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UISearchBar *navSearchBar;

@property (strong, nonatomic) FileViewController *fileVC;


@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UITabBarController *tabBarController = self.tabBarController;
        UITabBar *tabBar = tabBarController.tabBar;
        
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        
        // 设置灰色半透明背景
        [appearance configureWithOpaqueBackground]; // 先配置不透明背景
        appearance.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5]; // 半透明灰色
        
        tabBar.standardAppearance = appearance;
        
        if (@available(iOS 15.0, *)) {
            tabBar.scrollEdgeAppearance = appearance;
        }
    });
    
    
    self.navSearchBar = [[UISearchBar alloc] init];
    self.navSearchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.navSearchBar.delegate = self;
    CGRect searchBarFrame = [self.searchBar convertRect:self.searchBar.bounds toView:self.view];
    CGRect newFrame = CGRectMake(0,
                                 91,
                                 searchBarFrame.size.width,
                                 searchBarFrame.size.height);
    self.navSearchBar.frame = newFrame;
    self.navSearchBar.hidden = YES;
    self.navSearchBar.backgroundColor = UIColor.blackColor;
    self.navSearchBar.placeholder = @"搜索";
    [self.view addSubview:self.navSearchBar];
    [self.view bringSubviewToFront:self.navSearchBar];

    if (self.fileListView) {
        // 你希望 FileListView 填满 self.filesView，而不是 self.view
        _fileListView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        if (self.fileType) {
            [self.fileListView loadFileListIfNeededForType:self.fileType];
        } else {
            [self.fileListView loadFileListIfNeededForType:FileTypeText];
        }
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

    self.titleLabel.text = @"";
    
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

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self.fileListView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [self whenViewDidAppear];
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
    
    if (self.fileListView) {
        [self.fileListView reloadData];
    }
}

- (void)openOtherFileWith:(NSURL *)fileURL {
    
    FileViewController *fileVC = [FileViewController fileViewControllerWithURL:fileURL];
    
    [self.navigationController pushViewController:fileVC animated:YES];

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
        
        self.titleLabel.text = self.smallLabel.text;
        
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
- (void)barButtonItemAddDidTap:(BarButtonItemAdd *)button {
    if (self.fileListView.selectedIndex == -1) {
        CreateFileAlertController *alert = [CreateFileAlertController createAlertWithCompletion:^(NSString *filePath) {
            NSLog(@"文件创建成功，路径为：%@", filePath);
            // 例如：刷新文件列表、弹出提示
            
            
            [self.fileListView loadFileListWithKeyword:self.searchBar.text];
            
        } withFileString:self.fileListView.folderURL];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        NSLog(@"1");
    } else {
        Boolean success = [self.fileListView moveFiletoFolder];
        
        UIImage *addImage = [UIImage systemImageNamed:@"plus"];
        self.BarButtonItemRight2.image = addImage;
        
        if (success) {
            self.smallLabel.text = @"移动成功";
        } else {
            self.smallLabel.text = @"移动失败";
        }
    }
}

- (void)comebackFolder {
    [self.fileListView comebackFolder];
}

#pragma mark - FileListViewDelegate
- (void)fileListView:(FileListView *)fileListView didSelectString:(NSString *)string {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *fullPath = [documentsPath stringByAppendingPathComponent:string];

    // 先判断文件是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        return;
    }

    [self openOtherFileWith:[NSURL fileURLWithPath:fullPath]];

}


- (void)fileListView:(FileListView *)fileListView didLongPressNum:(int)num withIsFolder:(bool)isFolder {
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
    
    UIAlertAction *moveAction = [UIAlertAction actionWithTitle:@"移动"
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
        
        [self moveItemAtIndexs:num];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];

    [alert addAction:deleteAction];
    [alert addAction:renameAction];
    [alert addAction:cancelAction];
    
    if (!isFolder) {
        [alert addAction:moveAction];
    }

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

- (void)moveItemAtIndexs:(NSInteger)num {
    self.smallLabel.text = @"点击确认移动到当前文件夹下面";
    
    self.BarButtonItemRight2.title = @"确认";
    self.BarButtonItemRight2.image = nil;
    
    [self.fileListView moveFileWithIndex:(int)num];
}


@end
