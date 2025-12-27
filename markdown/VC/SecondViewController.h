//
//  SecondViewController.h
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/27.
//

#import <UIKit/UIKit.h>
#import "../FilesListView/FileListView.h"

#import "../UIBarButtonItem/BarButtonItems.h"
#import "../ImageViewController/ImageViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SecondViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *smallLabel;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet BarButtonItemLeft *BarButtonItemLeft1;

@property (weak, nonatomic) IBOutlet BarButtonItemRight *BarButtonRight1;

@property (weak, nonatomic) IBOutlet BarButtonItemAdd *BarButtonItemRight2;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;

@property (weak, nonatomic) IBOutlet FileListView *fileListView;


typedef void(^SecondConfirmCallback)(NSString *fileString);

@property (assign, nonatomic) ImageViewMode imageViewMode;

@property (nonatomic, copy) SecondConfirmCallback confirmCallback;

@end

NS_ASSUME_NONNULL_END
