//
//  ViewController.h
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/11.
//

#import <UIKit/UIKit.h>

#import "../FilesListView/FileListView.h"

#import "../UIBarButtonItem/BarButtonItems.h"

@interface ViewController : UIViewController


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *smallLabel;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet BarButtonItemLeft *BarButtonItemLeft1;

@property (weak, nonatomic) IBOutlet BarButtonItemRight *BarButtonRight1;

@property (weak, nonatomic) IBOutlet BarButtonItemAdd *BarButtonItemRight2;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;

@property (weak, nonatomic) IBOutlet FileListView *fileListView;

@property (assign, nonatomic) FileType fileType;

@property (strong, nonatomic) NSURL *fileURL;

@end

