//
//  FileViewController.m
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/8/8.
//

#import "FileViewController.h"
#import "TextViewController/TextViewController.h"
#import "PdfViewController/PdfViewController.h"
#import "DocxViewController/DocxViewController.h"


@interface FileViewController ()

@end

@implementation FileViewController

+ (UIViewController *)fileViewControllerWithURL:(NSURL *)fileURL {
    NSString *extension = fileURL.pathExtension.lowercaseString;
    
    if ([extension isEqualToString:@"pdf"]) {
        
        PdfViewController *pdfVC = [[PdfViewController alloc] initWithURL:fileURL];
        
        NSLog(@"加载成功");
        
        return pdfVC;
    } else if([extension isEqualToString:@"docx"]) {
        DocxViewController *docxVC = [[DocxViewController alloc] initWithURL:fileURL];
        
        NSLog(@"加载成功");
        
        return docxVC;
    } else {
        
        
        NSString *string = fileURL.lastPathComponent;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"File" bundle:nil];
        TextViewController *textVC = [storyboard instantiateViewControllerWithIdentifier:@"FileViewController"];

        textVC.fileName = string;
        textVC.fileURL = fileURL;
        
        return textVC;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 其他app打开时执行
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openOtherFile)
                                             name:@"OpenFileNotification"
                                           object:nil];
}

- (void)openOtherFile {
    // 你可以先执行文件打开逻辑，然后退出
    NSLog(@"mytitle: %@", self.title);
    [self.navigationController popViewControllerAnimated:YES];
    // 你可以先执行文件打开逻辑，然后退出
    NSLog(@"mytitle: %@", self.title);
}

@end
