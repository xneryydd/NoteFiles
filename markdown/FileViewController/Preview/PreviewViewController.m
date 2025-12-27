#import "PreviewViewController.h"
#import <WebKit/WebKit.h>

@interface PreviewViewController () <WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSURL *originalHTMLURL; // 也用于非 HTML 文件路径
@property (nonatomic, copy) NSString *htmlContent;
@property (nonatomic, assign) BOOL isHTML;

@property (nonatomic, strong) NSURL *tempHTMLURL;

@property (nonatomic, assign) BOOL isExport;

@property (nonatomic, copy) void (^completion)(NSData * _Nullable data);


@end

@implementation PreviewViewController

#pragma mark - 初始化方法

- (instancetype)initWithHTMLURL:(NSURL *)htmlURL {
    self = [super init];
    if (self) {
        _originalHTMLURL = htmlURL;
        _isHTML = YES;
    }
    return self;
}

- (instancetype)initWithHTMLContent:(NSString *)htmlContent originalFileURL:(NSURL *)originalFileURL {
    self = [super init];
    if (self) {
        _htmlContent = [htmlContent copy];
        _originalHTMLURL = originalFileURL; // 可能是 markdown 文件
        _isHTML = NO;
    }
    return self;
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"预览";

    // 创建 WKWebView
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *controller = [[WKUserContentController alloc] init];

    NSString *js = @"\
    document.querySelectorAll('img').forEach(function(img) {\
        window.webkit.messageHandlers.imageLogger.postMessage('🔍 尝试加载: ' + img.src);\
        img.onerror = function() {\
            window.webkit.messageHandlers.imageLogger.postMessage('❌ 加载失败: ' + img.src);\
        };\
        img.onload = function() {\
            window.webkit.messageHandlers.imageLogger.postMessage('✅ 加载成功: ' + img.src);\
        };\
    });";

    WKUserScript *script = [[WKUserScript alloc] initWithSource:js
                                                  injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                               forMainFrameOnly:NO];
    [controller addUserScript:script];
    [controller addScriptMessageHandler:self name:@"imageLogger"];
    config.userContentController = controller;

    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.webView];

    [self prepareAndLoadHTML];
}

#pragma mark - 加载 HTML 或内容

- (void)prepareAndLoadHTML {
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                  inDomains:NSUserDomainMask] firstObject];
    NSURL *tempURL = [documentsURL URLByAppendingPathComponent:@"tempPreview.html"];
    
    NSError *error;

    // 删除旧文件（如果存在）
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempURL.path]) {
        BOOL removed = [[NSFileManager defaultManager] removeItemAtURL:tempURL error:&error];
        if (!removed) {
            NSLog(@"⚠️ 删除旧临时文件失败: %@", error.localizedDescription);
        }
    }

    BOOL created = NO;

    if (!self.isHTML) {
        // ✨ 如果传入 HTML 内容，则写入文件
        created = [self.htmlContent writeToURL:tempURL atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (!created) {
            NSLog(@"❌ 写入 HTML 内容失败: %@", error.localizedDescription);
            return;
        }
    } else {
        // 如果传入的是 HTML 文件路径，则复制
        created = [[NSFileManager defaultManager] copyItemAtURL:self.originalHTMLURL toURL:tempURL error:&error];
        if (!created) {
            NSLog(@"❌ 复制 HTML 文件失败: %@", error.localizedDescription);
            return;
        }
    }
    
    self.tempHTMLURL = tempURL;

    NSLog(@"📄 加载临时 HTML 文件: %@", tempURL.path);
    NSLog(@"📁 允许访问目录: %@", documentsURL.path);

    // 加载 HTML
    [self.webView loadFileURL:tempURL allowingReadAccessToURL:documentsURL];
    

}

#pragma mark - 自动删除临时文件

- (void)deleteFile {
    if (self.tempHTMLURL) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtURL:self.tempHTMLURL error:&error];
        if (error) {
            NSLog(@"⚠️ 删除临时文件失败: %@", error.localizedDescription);
        } else {
            NSLog(@"🧹 已删除临时 HTML 文件");
            self.tempHTMLURL = nil; // 避免重复删除
            
            if (self.isExport) {
                NSLog(@"1");
                [self exportPDFWithCompletion:self.completion];
                
                
            }
        }
    }
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"imageLogger"]) {
        NSLog(@"🖼️ JS日志: %@", message.body);
    }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"✅ 页面加载完成");

    [self deleteFile];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"❌ 加载失败: %@", error.localizedDescription);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"❌ 预加载失败: %@", error.localizedDescription);
}

#pragma mark - 导出 PDF

- (void)exportPDFWithCompletion:(void (^)(NSData * _Nullable pdfData))completion {
    if (!self.isExport) {
        
        self.completion = completion;
        self.isExport = YES;
        
        return;
    }
    
    NSLog(@"开始导出pdf");
    if (!self.webView) {
        NSLog(@"❌ WKWebView 不存在，无法导出 PDF");
        completion(nil);
        return;
    }
    
    CGRect contentRect = CGRectMake(0, 0, self.webView.scrollView.contentSize.width, self.webView.scrollView.contentSize.height);
    NSLog(@"contentRect = %@", NSStringFromCGRect(contentRect));

    
    NSString *basePath = self.originalHTMLURL.path;
    if (basePath.length == 0) {
        NSLog(@"❌ 原始文件路径为空");
        completion(nil);
        return;
    }

    NSString *pdfPath = [[basePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"pdf"];
    NSURL *pdfURL = [NSURL fileURLWithPath:pdfPath];

    if (@available(iOS 14.0, *)) {
        WKPDFConfiguration *config = [[WKPDFConfiguration alloc] init];
        config.rect = self.webView.bounds;

        [self.webView createPDFWithConfiguration:config completionHandler:^(NSData * _Nullable pdfData, NSError * _Nullable error) {
            if (error || !pdfData) {
                NSLog(@"❌ 导出 PDF 失败: %@", error.localizedDescription);
                completion(nil);
                return;
            }

            BOOL success = [pdfData writeToURL:pdfURL atomically:YES];
            if (success) {
                NSLog(@"✅ PDF 导出成功，路径: %@", pdfURL.path);
                completion(pdfData);
            } else {
                NSLog(@"❌ PDF 写入失败");
                completion(nil);
            }
        }];
    } else {
        NSLog(@"❌ iOS 版本过低，无法使用 createPDFWithConfiguration");
        completion(nil);
    }
}


@end
