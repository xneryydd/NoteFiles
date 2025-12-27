//
//  FileListView.h
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/13.
//

#import <UIKit/UIKit.h>


@class FileListView;

// FileType.h
typedef NS_ENUM(NSInteger, FileType) {
    FileTypeText,   // 文本文件
    FileTypeImage,   // 图片文件
    FileTypeICloud
};


@protocol FileListViewDelegate <NSObject>

@required
// 代理方法，传递一个 NSString 参数
- (void)fileListView:(FileListView *)fileListView didSelectString:(NSString *)string;

// 长按手势
- (void)fileListView:(FileListView *)fileListView didLongPressNum:(int)num withIsFolder:(bool)isFolder;

@end



@interface FileListView : UIView


@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSString *folderURL;
@property (nonatomic, weak) id<FileListViewDelegate> delegate;
@property (nonatomic, assign) FileType fileType;

@property (nonatomic, assign) int selectedIndex;

- (void)loadFileListIfNeededForType:(FileType)type;

- (void)loadFileListWithKeyword:(NSString *)keyword;

- (void)openFolder;

- (void)deleteFileWithIndex:(int)num;

- (void)renameFileWithIndex:(int)num withNewName:(NSString *)newName;

- (void)moveFileWithIndex:(int)num;

- (Boolean)moveFiletoFolder;

- (void)comebackFolder;

- (void)reloadData;

@end

@class FileTableView;

@protocol FileTableViewDelegate <NSObject>

@required
// 代理方法，传递一个 NSString 参数
- (void)fileTableView:(FileTableView *)fileTableView didSelectTitleNum:(int)titleNum AndContentNum:(int)contentNum;



@end

@interface FileTableView : UIView

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, weak) id<FileTableViewDelegate> delegate;

- (void)setupUI;

- (void)reloadData;

@end
