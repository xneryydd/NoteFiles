//
//  ThirdViewController.m
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/8/15.
//

#import "ThirdViewController.h"
#import "ViewController.h"
#import "SettingViewController/SettingViewController.h"

@interface ThirdViewController () <UIScrollViewDelegate, UISearchBarDelegate, UINavigationControllerDelegate, FileTableViewDelegate>

@property (strong, nonatomic) UISearchBar *navSearchBar;

@end

@implementation ThirdViewController

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
    self.navSearchBar.hidden = YES;
    self.navSearchBar.backgroundColor = UIColor.blackColor;
    self.navSearchBar.placeholder = @"搜索";
    [self.view addSubview:self.navSearchBar];
    [self.view bringSubviewToFront:self.navSearchBar];
    
    
    // 使用系统图标设置 BarButtonItemLeft1（返回图标）
    UIImage *backImage = [UIImage systemImageNamed:@"chevron.left"];
    self.BarButtonItemLeft1.image = backImage;
    self.BarButtonItemLeft1.target = self;
    
    // 设置 scrollView 的 delegate
    self.scrollView.delegate = self;
    
    // 设置 scrollView 的 delegate
    self.scrollView.delegate = self;
    
    self.fileTableView.delegate = self;
    
    [self.fileTableView reloadData];
    
    
    
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

#pragma mark - FileTableViewDelegate
- (void)fileTableView:(FileTableView *)fileTableView didSelectTitleNum:(int)titleNum AndContentNum:(int)contentNum {
    if (titleNum == 0) { // section 0 → 位置
        if (contentNum == 0) {
            // iCloud 云盘
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
            viewController.fileType = FileTypeICloud;

            [self.navigationController pushViewController:viewController animated:YES];

        } else if (contentNum == 1) {
            // 我的 iPhone
        } else if (contentNum == 2) {
            // 最近删除
        }
    } else if (titleNum == 1) { // section 1 → 个人收藏
        if (contentNum == 0) {
            // 下载
        }
    } else if (titleNum == 2) {
        if (contentNum == 0) {
            SettingViewController *settingVC = [[SettingViewController alloc] init];
            
            [self.navigationController pushViewController:settingVC animated:YES];
            
        }
    }
}

#pragma mark -
- (void)handleOpenFile:(NSNotification *)notification {
    
}

@end

