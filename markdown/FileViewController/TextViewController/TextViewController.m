//
//  FileViewController.m
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/19.
//

#import "TextViewController.h"
#import "../../FileService/FileService.h"
#import "../../VC/SecondViewController.h"
#import "FloatingWindow.h"
#import "markdown-Swift.h"
#import "../EditToolbar/EditToolbar.h"
#import "../Preview/PreviewViewController.h"


@interface TextViewController () <UITextViewDelegate, UIScrollViewDelegate, FloatWindowDelegate, UIEditMenuInteractionDelegate>

@property (strong, nonatomic) FloatingWindow *floatingWindow;


@property (nonatomic, strong) EditToolbar *toolbarView;

// 为NO则需要 keep
@property (assign, nonatomic) BOOL isKeep;

// 搜索功能
@property (nonatomic, strong) NSArray<NSValue *> *matchRanges;
@property (nonatomic, assign) NSInteger currentMatchIndex;
@property (nonatomic, strong) NSString *fullText;
@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) NSString *fileType;

@end

@implementation TextViewController

#pragma mark - 懒加载
- (NSString *)fileType {
    if (!_fileType) {
        
        if (!self.fileName || self.fileName.length == 0) {
            return nil;
        }
        
        NSString *extension = [self.fileName pathExtension];
        if (extension.length == 0) {
            return nil;
        }
        
        _fileType = [extension lowercaseString];
    }
    return _fileType;
}

#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"操作"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(didTapAction)];
    
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"magnifyingglass"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(openCheckWindow)];
    
    self.navigationItem.rightBarButtonItems = @[rightButton, searchButton];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                             target:self
                             action:@selector(backButtonTapped)];
    
    self.title = self.fileName;
    
    self.isKeep = YES;
    
    


    
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setTextView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    // 判断是返回（pop/dismiss）还是跳转到其他 VC
    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
        if (self.floatingWindow) {
            [self.floatingWindow removeFromSuperview];
            [self floatingWindowClosed];
        }
    }
}



- (void)setTextView {
    CGFloat top = self.view.safeAreaInsets.top;
    CGFloat bottom = self.view.safeAreaInsets.bottom;
    CGFloat height = self.view.frame.size.height - top - bottom;
    
    // 创建左侧行号视图
    self.lineNumberTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, top, 40, height)];
    self.lineNumberTextView.editable = NO;
    self.lineNumberTextView.scrollEnabled = YES;
    self.lineNumberTextView.userInteractionEnabled = NO;
    self.lineNumberTextView.backgroundColor = [UIColor grayColor];
    self.lineNumberTextView.textAlignment = NSTextAlignmentRight;
    
    // 行号文本也使用全局字体，但颜色可以单独设置
    self.lineNumberTextView.textColor = [UIColor whiteColor];
    
    // 创建右侧主内容视图
    self.contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(40, top, self.view.frame.size.width - 40, height)];
    self.contentTextView.editable = YES;
    self.contentTextView.userInteractionEnabled = YES;
    self.contentTextView.selectable = YES;

    // 设置文本
    self.contentTextView.text = [FileService readFileContentFromURL:self.fileURL];
    self.contentTextView.inputAccessoryView = [self createInputAccessoryView];
    self.contentTextView.delegate = self;
    
    // 应用全局样式
    self.lineNumberTextView.text = @"1";
    
    // 获取全局样式管理器
    TextStyleManager *styleManager = [TextStyleManager sharedManager];
    
    [styleManager applyStyleToTextView:self.lineNumberTextView];
    [styleManager applyStyleToTextView:self.contentTextView];
    
    [self updateLineNumbers];
    
    [self.view addSubview:self.lineNumberTextView];
    [self.view addSubview:self.contentTextView];
    
    [self setMenu];
}


- (void)textViewDidChange:(UITextView *)textView {
    self.isKeep = NO;
    [self updateLineNumbers];
}

- (void)updateLineNumbers {
    NSString *text = self.contentTextView.text ?: @"";
    __block NSUInteger numberOfLines = 0;
    [text enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
        numberOfLines++;
    }];
    
    if ([text hasSuffix:@"\n"]) {
        numberOfLines += 1;
    }
    
    if (numberOfLines == 0) {
        numberOfLines = 1; // 空文本也显示1行
    }
    
    NSMutableString *lineNumberString = [NSMutableString string];
    for (NSUInteger i = 1; i <= numberOfLines; i++) {
        [lineNumberString appendFormat:@"%lu\n", (unsigned long)i];
//        NSLog(@"height = %lu", (unsigned long)i);
    }
    
    self.lineNumberTextView.text = lineNumberString;

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.contentTextView) {
        self.lineNumberTextView.contentOffset = self.contentTextView.contentOffset;
    }
}


#pragma mark - 键盘

- (UIView *)createInputAccessoryView {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
    accessoryView.backgroundColor = [UIColor secondarySystemBackgroundColor];

    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [editButton setTitle:@"编辑文本" forState:UIControlStateNormal];
    editButton.frame = CGRectMake(10, 7, 80, 30);
    [editButton addTarget:self action:@selector(toggleKeyboardToolbar:) forControlEvents:UIControlEventTouchUpInside];
    editButton.tag = 1001;
    [accessoryView addSubview:editButton];

    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [doneButton setTitle:@"完成" forState:UIControlStateNormal];
    doneButton.frame = CGRectMake(screenWidth - 80, 7, 70, 30);
    doneButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [doneButton addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [accessoryView addSubview:doneButton];

    return accessoryView;
}

- (EditToolbar *)createToolbarView {
    if (self.toolbarView) return self.toolbarView;

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat keyboardHeight = [self findKeyboardHeight];
    CGFloat height = keyboardHeight > 0 ? keyboardHeight : 216;

    __weak typeof(self) weakSelf = self;

    NSArray<EditToolbarItem *> *items = @[
        [[EditToolbarItem alloc] initWithTitle:@"粘贴" action:^{
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            if (pasteboard.string) {
                NSRange selectedRange = weakSelf.contentTextView.selectedRange;
                NSMutableString *text = [weakSelf.contentTextView.text mutableCopy];
                [text replaceCharactersInRange:selectedRange withString:pasteboard.string];
                weakSelf.contentTextView.text = text;
                weakSelf.contentTextView.selectedRange = NSMakeRange(selectedRange.location + pasteboard.string.length, 0);
            }
        }],
        [[EditToolbarItem alloc] initWithTitle:@"复制" action:^{
            NSRange selectedRange = weakSelf.contentTextView.selectedRange;
            if (selectedRange.length > 0) {
                NSString *selectedText = [weakSelf.contentTextView.text substringWithRange:selectedRange];
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = selectedText;
            }
        }],
        [[EditToolbarItem alloc] initWithTitle:@"插入图片" action:^{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            SecondViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SecondViewController"];

            // 设置回调
            __weak typeof(self) weakSelf = self;
            vc.confirmCallback = ^(NSString *selectedFileString) {
                // 生成 Markdown 图片语句
                NSString *markdownImage = [NSString stringWithFormat:@"![示例](app://%@)", selectedFileString];

                // 获取当前光标位置
                NSRange selectedRange = self.contentTextView.selectedRange;

                // 获取原始文本
                NSMutableString *originalText = [self.contentTextView.text mutableCopy];

                // 插入 markdownImage
                [originalText insertString:markdownImage atIndex:selectedRange.location];

                // 设置更新后的文本
                self.contentTextView.text = originalText;

                // 更新光标位置（插入后的下一个位置）
                self.contentTextView.selectedRange = NSMakeRange(selectedRange.location + markdownImage.length, 0);
            };
            
            vc.imageViewMode = ImageViewModeInsert;
            
            // Push 进入
            [self.navigationController pushViewController:vc animated:YES];
            self.isKeep = false;
        }]
    ];

    EditToolbar *toolbar = [[EditToolbar alloc] initWithItems:items preferredHeight:height];
    toolbar.frame = CGRectMake(0, 0, screenWidth, height);
    toolbar.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.toolbarView = toolbar;
    return toolbar;
}

- (void)toggleKeyboardToolbar:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"编辑文本"]) {
        // 切换到 EditToolbar（自定义 inputView）
        self.contentTextView.inputView = [self createToolbarView];
        [sender setTitle:@"键盘" forState:UIControlStateNormal];
    } else {
        // 切换回系统键盘
        self.contentTextView.inputView = nil;
        [sender setTitle:@"编辑文本" forState:UIControlStateNormal];
    }

    [self.contentTextView reloadInputViews];
    [self.contentTextView becomeFirstResponder];
}

- (void)dismissKeyboard {
    [self.contentTextView resignFirstResponder];

    // 清除自定义 inputView（下次默认使用系统键盘）
    self.contentTextView.inputView = nil;

    // 还原 accessoryView 按钮标题
    UIView *accessory = self.contentTextView.inputAccessoryView;
    UIButton *toggleButton = [accessory viewWithTag:1001];
    if ([toggleButton isKindOfClass:[UIButton class]]) {
        [toggleButton setTitle:@"编辑文本" forState:UIControlStateNormal];
    }
}

- (CGFloat)findKeyboardHeight {
    for (UIWindow *window in UIApplication.sharedApplication.windows.reverseObjectEnumerator) {
        for (UIView *view in window.subviews) {
            NSString *className = NSStringFromClass(view.class);
            if ([className hasPrefix:@"UI"] && [className containsString:@"Keyboard"]) {
                return view.bounds.size.height;
            }
        }
    }
    return 0;
}


#pragma mark - alert
- (void)didTapAction {
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *keepAction = [UIAlertAction actionWithTitle:@"保存"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
        [self backButtonTapped];
    }];
    
    UIAlertAction *changeAction = [UIAlertAction actionWithTitle:@"导出"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
        // 延迟一点点执行下一个菜单，避免两个 UIAlertController 冲突
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showExportFormatMenu];
        });
    }];
    
    UIAlertAction *readAction = [UIAlertAction actionWithTitle:@"预览"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
        NSString *textToPreview = self.contentTextView.text;
        
        
        if ([self.fileType isEqual:@"md"]) {
            MarkDownViewController *vc = [[MarkDownViewController alloc] initWithContent:textToPreview];
            [self.navigationController pushViewController:vc animated:YES];
        } else if ([self.fileType isEqual:@"html"]) {
            NSLog(@"URL: %@", self.fileURL);
            
            PreviewViewController *vc = [[PreviewViewController alloc] initWithHTMLURL:self.fileURL];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
    
    UIAlertAction *shareAction = [UIAlertAction actionWithTitle:@"分享/其他软件打开"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {

        // 获取文件路径（假设你已经保存好了文件）
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        


        // 从 NSURL 获取文件系统路径
        NSString *filePath = [self.fileURL path];

        // 判断文件是否存在
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSLog(@"文件不存在：%@", filePath);
            return;
        }

        // 创建 UIActivityViewController
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.fileURL] applicationActivities:nil];

        // iPad 需要指定 sourceView 和 sourceRect，否则会崩溃
        activityVC.popoverPresentationController.sourceView = self.view;
        activityVC.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height, 1.0, 1.0);

        // 显示分享界面
        [self presentViewController:activityVC animated:YES completion:nil];
    }];

    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];

    [menu addAction:keepAction];
    [menu addAction:readAction];
    [menu addAction:changeAction];
    [menu addAction:shareAction];
    [menu addAction:cancelAction];
    
    // 避免 iPad 或某些系统下崩溃
    menu.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;

    [self presentViewController:menu animated:YES completion:nil];
}

- (void)showExportFormatMenu {
    UIAlertController *exportMenu = [UIAlertController alertControllerWithTitle:@"选择导出格式"
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *pdfAction = [UIAlertAction actionWithTitle:@"导出为 PDF"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
        [self exportAsPDF];
    }];

    UIAlertAction *htmlAction = [UIAlertAction actionWithTitle:@"导出为 HTML"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
        [self exportAsHTML];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    if ([self.fileType isEqual:@"md"]) {
        [exportMenu addAction:htmlAction];
    } else if ([self.fileType isEqual:@"html"]) {
        [exportMenu addAction:pdfAction];
    }
    
    [exportMenu addAction:cancelAction];

    [self presentViewController:exportMenu animated:YES completion:nil];
}

- (void)exportAsHTML {
    NSString *markdown = self.contentTextView.text;
    if (!markdown) return;

    [MarkdownExporter exportHTMLFrom:markdown completion:^(NSString *html) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *relativePath = [self relativeExportPathWithExtension:@"html"];
            BOOL success = [FileService createTextFileIfNeeded:relativePath
                                                   withContent:html
                                                      isRepeat:YES];
            if (success) {
                NSLog(@"✅ HTML 导出成功：%@", relativePath);
            } else {
                NSLog(@"❌ HTML 导出失败");
            }
        });
    }];
}

#import "PreviewViewController.h"

- (void)exportAsPDF {
    if (!self.fileURL) {
        NSLog(@"❌ fileURL 未设置");
        return;
    }
    
    __block PreviewViewController *previewVC;

    if ([self.fileType isEqual:@"html"]) {
        // 创建 PreviewViewController 实例（不push，不显示）
        previewVC = [[PreviewViewController alloc] initWithHTMLURL:self.fileURL];

    } else if ([self.fileType isEqual:@"md"]) {
        // 读取原始 Markdown 内容
        NSString *markdown = self.contentTextView.text;
        
        if (markdown) {
            // 使用 Swift 中的 MarkdownExporter 生成 HTML
            [MarkdownExporter exportHTMLFrom:markdown completion:^(NSString *html) {
                // 得到 html 后构造 previewVC
                previewVC = [[PreviewViewController alloc] initWithHTMLContent:html originalFileURL:self.fileURL];

                // 这里你可以继续使用 previewVC，例如 export PDF
                // [previewVC exportPDF];
            }];
        } else {
            NSLog(@"❌ 无法读取 Markdown 文件内容: %@", self.fileURL);
        }
    }
    
    
    [previewVC exportPDFWithCompletion:^(NSData * _Nullable pdfData) {
        // 什么都不做
    }];
    
    (void)previewVC.view;

}



- (NSString *)relativeExportPathWithExtension:(NSString *)extension {
    NSURL *originalURL = self.fileURL;
    NSString *originalName = originalURL.lastPathComponent;
    NSString *fileName = [[originalName stringByDeletingPathExtension] stringByAppendingPathExtension:extension];

    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *documentPrefix = [documentsDir stringByAppendingString:@"/"];

    if ([FileService isSandboxFileURL:originalURL]) {
        NSString *fullPath = originalURL.path;
        if ([fullPath hasPrefix:documentPrefix]) {
            NSString *subPath = [fullPath substringFromIndex:documentPrefix.length];
            NSString *subDir = [subPath stringByDeletingLastPathComponent];
            return [subDir stringByAppendingPathComponent:fileName];
        }
    }
    return fileName;
}

- (void)backButtonTapped {
    if (!self.isKeep) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"是否保存文件？"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *textString = self.contentTextView.text;
            BOOL success = [FileService saveText:textString toFileNamed:[self.fileURL path]];
            if (!success) {
                NSLog(@"failing on keeping file");
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"不保存" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        [alert addAction:saveAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - Check
// 打开查找窗
- (void)openCheckWindow {
    if (!self.floatingWindow) {
        NSLog(@"启动");
        self.floatingWindow = [[FloatingWindow alloc] initWithFrame:CGRectMake(100, 200, 150, 80)];
        
        if (self.floatingWindow) {
            self.floatingWindow.delegate = self;
            self.floatingWindow.searchTextField.inputAccessoryView = [self createInputAccessoryView];
            self.floatingWindow.searchIndexField.inputAccessoryView = [self createInputAccessoryView];
            __weak typeof(self) weakSelf = self;
            self.floatingWindow.onClose = ^{
                weakSelf.floatingWindow = nil;
            };
            NSLog(@"FloatingWindow frame: %@", NSStringFromCGRect(self.floatingWindow.frame));
            
            // 比textView高
            //        [self.view insertSubview:self.floatingWindow aboveSubview:self.contentTextView];
            
            
            // 最上层
            //        [self.view bringSubviewToFront:self.floatingWindow];
            
            // 添加到导航层
            [self.navigationController.view addSubview:self.floatingWindow];
        };

    } else {
        [self.floatingWindow removeFromSuperview];
        [self floatingWindowClosed];
    }
}

- (void)floatingWindowClosed {
    self.floatingWindow = nil;
}

// 1. 高亮关键词并记录所有匹配位置
- (void)highlightTextInTextView:(NSString *)searchText {
    NSString *text = self.contentTextView.text ?: @"";

    // 获取原始样式（字体等）
    UIFont *originalFont = self.contentTextView.font ?: [UIFont systemFontOfSize:14];
    UIColor *originalTextColor = self.contentTextView.textColor ?: [UIColor labelColor];

    // 重新构造保留原样式的 attributed string
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{
        NSFontAttributeName: originalFont,
        NSForegroundColorAttributeName: originalTextColor
    }];

    if (searchText.length == 0) {
        self.contentTextView.attributedText = attributedString;
        self.matchRanges = @[];
        return;
    }

    NSMutableArray<NSValue *> *matches = [NSMutableArray array];
    NSRange searchRange = NSMakeRange(0, text.length);
    NSRange foundRange;

    while (searchRange.location < text.length) {
        searchRange.length = text.length - searchRange.location;
        foundRange = [text rangeOfString:searchText options:NSCaseInsensitiveSearch range:searchRange];

        if (foundRange.location != NSNotFound) {
            // 设置浅灰底色和粗体
            UIFont *boldFont = [UIFont boldSystemFontOfSize:originalFont.pointSize];
            UIColor *highlightColor = [UIColor colorWithWhite:0.9 alpha:1.0]; // 略白灰色
            
            [attributedString addAttributes:@{
                NSFontAttributeName: boldFont,
                NSBackgroundColorAttributeName: highlightColor
            } range:foundRange];
            
            [matches addObject:[NSValue valueWithRange:foundRange]];
            searchRange.location = foundRange.location + foundRange.length;
        } else {
            break;
        }
    }

    self.contentTextView.attributedText = attributedString;
    self.matchRanges = matches;
    self.currentMatchIndex = 0;

    [self scrollToMatchAtIndex:self.currentMatchIndex];
}



// 2. 滚动到指定的匹配索引，并设置当前匹配为橙色，其他为黄色
- (int)scrollToMatchAtIndex:(NSInteger)index {
    if (self.matchRanges.count == 0) return -1;

    if (index >= self.matchRanges.count) {
        index = self.matchRanges.count - 1;
    }
    if (index < 0) return -1;

    NSRange range = [self.matchRanges[index] rangeValue];
    [self.contentTextView scrollRangeToVisible:range];

    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.contentTextView.attributedText];
    UIFont *regularFont = [UIFont systemFontOfSize:self.contentTextView.font.pointSize];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:self.contentTextView.font.pointSize];

    for (NSInteger i = 0; i < self.matchRanges.count; i++) {
        UIFont *font = (i == index) ? boldFont : regularFont;
        [attrStr addAttribute:NSFontAttributeName value:font range:[self.matchRanges[i] rangeValue]];
    }

    self.contentTextView.attributedText = attrStr;
    self.currentMatchIndex = index;
    return (int)index;
}

// 3. 跳转到下一个匹配项
- (int)goToNextMatch {
    if (self.matchRanges.count == 0) return -1;

    self.currentMatchIndex = (self.currentMatchIndex + 1) % self.matchRanges.count;
    [self scrollToMatchAtIndex:self.currentMatchIndex];
    return (int)self.currentMatchIndex;
}

#pragma mark - 长按菜单
- (void)setMenu {
    if (@available(iOS 16.0, *)) {
        NSMutableArray *toRemove = [NSMutableArray array];
        for (id<UIInteraction> interaction in self.contentTextView.interactions) {
            if ([interaction isKindOfClass:NSClassFromString(@"UITextContextMenuInteraction")]) {
                [toRemove addObject:interaction];
            }
        }
        for (id<UIInteraction> interaction in toRemove) {
            [self.contentTextView removeInteraction:interaction];
            NSLog(@"🧹 已移除系统默认菜单交互：%@", interaction);
        }
    } else {
        NSLog(@"⚠️ 当前系统版本低于 iOS 16，无需处理默认菜单交互。");
    }
}


#pragma mark - Other


@end
