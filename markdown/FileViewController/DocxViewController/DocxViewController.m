//
//  DocxViewController.m
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/9/24.
//

#import "DocxViewController.h"

@interface DocxViewController () <QLPreviewControllerDataSource>

@property (nonatomic, strong) QLPreviewController *previewController;

@end

@implementation DocxViewController

- (instancetype)initWithURL:(NSURL *)fileURL {
    self = [super init];
    if (self) {
        self.fileURL = fileURL;
        self.title = fileURL.lastPathComponent;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 创建 QLPreviewController
    self.previewController = [[QLPreviewController alloc] init];
    self.previewController.dataSource = self;
    
    // 添加到当前 VC 的 view
    [self addChildViewController:self.previewController];
    [self.view addSubview:self.previewController.view];
    self.previewController.view.frame = self.view.bounds;
    self.previewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.previewController didMoveToParentViewController:self];
    
    // 禁用 QL 内部下拉/捏合退出手势
    [self disableQLDismissGestures:self.previewController.view];
    
    // 自定义导航栏
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                                                  target:self
                                                                  action:@selector(backButtonTapped)];
    
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        // appearance.backgroundColor = [UIColor systemBlueColor];
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.whiteColor};
        self.navigationController.navigationBar.standardAppearance = appearance;
        if (@available(iOS 15.0, *)) {
            self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        }
    }
}

#pragma mark - 禁用手势
- (void)disableQLDismissGestures:(UIView *)view {
    for (UIGestureRecognizer *gesture in view.gestureRecognizers) {
        NSString *cls = NSStringFromClass([gesture class]);
        if ([cls containsString:@"Parallax"] || [cls containsString:@"SwipeDown"] || [cls containsString:@"Transform"]) {
            gesture.enabled = NO;
        }
    }
    for (UIView *sub in view.subviews) {
        [self disableQLDismissGestures:sub];
    }
}

#pragma mark - 返回按钮
- (void)backButtonTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return self.fileURL ? 1 : 0;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return self.fileURL;
}

@end
