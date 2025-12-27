//
//  PdfViewController.m
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/8/8.
//

#import "PdfViewController.h"
#import <PDFKit/PDFKit.h>

@interface PdfViewController ()
@property (nonatomic, strong) PDFView *pdfView;
@end

@implementation PdfViewController

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.pdfFilePath = url;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"PDF 预览";
    
    // 创建 PDFView
    self.pdfView = [[PDFView alloc] init];
    self.pdfView.translatesAutoresizingMaskIntoConstraints = NO;

    // 关闭 autoScales，改成手动设置
    self.pdfView.autoScales = NO;
    self.pdfView.displayMode = kPDFDisplaySinglePageContinuous;
    self.pdfView.displayDirection = kPDFDisplayDirectionVertical;
    self.pdfView.scaleFactor = self.pdfView.scaleFactorForSizeToFit;

    [self.view addSubview:self.pdfView];


    
    // 自动布局 - 使用 safeAreaLayoutGuide 避免被导航栏或底部遮挡
    [NSLayoutConstraint activateConstraints:@[
        [self.pdfView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.pdfView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.pdfView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.pdfView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];

    
    // 加载 PDF
    [self loadPDF];
}

- (void)loadPDF {
    if (!self.pdfFilePath) {
        NSLog(@"⚠️ pdfFilePath 为空，无法加载 PDF");
        return;
    }
    
    PDFDocument *document = [[PDFDocument alloc] initWithURL:self.pdfFilePath];
    
    if (document) {
        [self.pdfView setDocument:document];
        NSLog(@"pdf 文件成功加载");
        
        // 布局完成后再比较
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view layoutIfNeeded];
            
//            CGFloat viewHeight = self.pdfView.bounds.size.height;
            
            PDFPage *firstPage = [document pageAtIndex:0];
            CGRect bounds = [firstPage boundsForBox:kPDFDisplayBoxMediaBox];
            
            NSLog(@"PDF 第一页尺寸: 宽 %.2f pt, 高 %.2f pt", bounds.size.width, bounds.size.height);
            NSLog(@"PDFView 高度: %.2f pt", self.pdfView.frame.size.height);
            NSLog(@"%f", self.view.frame.size.height);
        });
    } else {
        NSLog(@"❌ 无法加载 PDF 文件: %@", self.pdfFilePath);
    }
}


@end
