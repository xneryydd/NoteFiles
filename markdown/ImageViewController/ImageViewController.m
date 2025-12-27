//
//  ImageViewController.m
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/29.
//

#import "ImageViewController.h"



@interface ImageViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    [self setupScrollView];
    [self setupImageView];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self setupNavigationItems];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateImageLayout];
    
    
}

#pragma mark - UI Setup

- (void)setupScrollView {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 3.0;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.bouncesZoom = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
}

- (void)setupImageView {
    self.imageView = [[UIImageView alloc] initWithImage:self.image];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.userInteractionEnabled = YES;
    [self.scrollView addSubview:self.imageView];
}

- (void)setupNavigationItems {
    if (self.mode == ImageViewModeInsert) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(cancelTapped)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确认"
                                                                                  style:UIBarButtonItemStyleDone
                                                                                 target:self
                                                                                 action:@selector(confirmTapped)];
        self.title = @"预览图片";
    } else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(closeTapped)];
        self.title = @"查看图片";
    }
}

- (void)updateImageLayout {
    self.scrollView.frame = self.view.bounds;

    CGSize imageSize = self.image.size;
    CGFloat scale = MIN(self.view.bounds.size.width / imageSize.width,
                        self.view.bounds.size.height / imageSize.height);
    
    CGSize displaySize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);

    self.imageView.frame = CGRectMake(0, 0, displaySize.width, displaySize.height);
    self.imageView.center = CGPointMake(self.scrollView.bounds.size.width / 2,
                                        self.scrollView.bounds.size.height / 2);
    self.scrollView.contentSize = displaySize;
}

#pragma mark - Actions

- (void)cancelTapped {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)confirmTapped {
    if (self.onInsertConfirm) {
        self.onInsertConfirm();
    }
}

- (void)closeTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ScrollView Zoom

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end
