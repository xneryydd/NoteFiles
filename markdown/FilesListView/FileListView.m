//
//  FileListView.m
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/13.
//

#import "FileListView.h"
#import "FileService.h"
#import "../FileService/FileAndFolder.h"



@interface FileListView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSMutableArray<FileAndFolder *> *fileList;

@property (nonatomic, strong) NSString *selectedFileRelativeString;

@end


@implementation FileListView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupCollectionView];
    
    UILongPressGestureRecognizer *longPressGesture =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    
    [self.collectionView addGestureRecognizer:longPressGesture];
    
    self.selectedIndex = -1;
}

- (void)loadFileListIfNeededForType:(FileType)type {
    self.fileType = type;
    if (type == FileTypeText) {
        self.folderURL = @"";
        self.fileList = [FileService listFilesInDocumentsFolder:self.folderURL];
        NSLog(@"1");
    } else if (type == FileTypeImage) {
        self.folderURL = @"assert";
        self.fileList = [FileService listFilesInDocumentsFolder:self.folderURL];

        
        NSLog(@"2");
    } else if (type == FileTypeICloud) {
        self.folderURL = @"";
        self.fileList = [FileService readICloudFolder:@""];
        NSLog(@"3");
    }
    
    
    [self.collectionView reloadData];
}

- (void)loadFileListWithKeyword:(NSString *)keyword {
	if ([keyword isEqual:@""]) {
		self.fileList = [self readFileList:self.folderURL];
		[self.collectionView reloadData];
		return;
	}
	
	NSArray<FileAndFolder *> *allFiles = [self readFileList:self.folderURL];
	
	NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(FileAndFolder *file, NSDictionary *bindings) {
		return [file.name.lowercaseString containsString:keyword.lowercaseString];
	}];
	
	self.fileList = [[allFiles filteredArrayUsingPredicate:predicate] mutableCopy];
	
	[self.collectionView reloadData];
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    CGFloat width = (self.bounds.size.width - 40) / 3; // 3列间隔10
    layout.itemSize = CGSizeMake(width, width);

    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"FileCell"];
    [self addSubview:self.collectionView];
}


#pragma mark - UITableViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fileList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FileCell" forIndexPath:indexPath];
    
    // 先清理旧内容
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }

    NSString *fileName = self.fileList[indexPath.item].name;
    FileAndFolder *item = self.fileList[indexPath.item];

    UIImage *iconImage;
    if (item.isFolder) {
        // 文件夹图标
        iconImage = [UIImage systemImageNamed:@"folder"];
    } else {
        // 文件图标
        iconImage = [UIImage systemImageNamed:@"doc"];
    }

    UIImageView *imageView = [[UIImageView alloc] initWithImage:iconImage];

    imageView.frame = CGRectMake(10, 10, 60, 60);
    imageView.contentMode = UIViewContentModeScaleAspectFit;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, cell.bounds.size.width, 20)];
    label.text = fileName;
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    label.adjustsFontSizeToFitWidth = YES;

    [cell.contentView addSubview:imageView];
    [cell.contentView addSubview:label];

    cell.contentView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    cell.contentView.layer.cornerRadius = 8;
    cell.contentView.clipsToBounds = YES;
    
    if (self.selectedIndex == -1) {
        imageView.alpha = 1.0;
    } else {
        if (item.isFolder) {
            // (这里不做处理，只加个注释)
        } else {
//            if (indexPath.item == self.selectedIndex) {
//                // 当前选中的 Cell → 放大和抖动逻辑在 moveFileWithIndex 里处理
//                imageView.alpha = 1.0;
//            } else {
//                // 其他非文件夹且不是选中的 → 变暗
                imageView.alpha = 0.3;
//            }
        }
        
    }
    
    return cell;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    FileAndFolder *fileAndFolder = self.fileList[indexPath.item];
    NSString *fileName = [self connectFolderAndFile:fileAndFolder.name];
    NSLog(@"点击了文件：%@", fileName);
    if (fileAndFolder.isFolder) {
        // 对方是文件夹
        self.folderURL = fileName;
        self.fileList = [self readFileList:self.folderURL];
        
        [self.collectionView reloadData];
    } else {
        if (self.selectedIndex != -1) {
            [self reloadData];
        } else {
            if (self.delegate) {
                
                [self.delegate fileListView:self didSelectString:fileName];
                
            }
        }
    }

}

#pragma mark - 长按手势
- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (self.selectedIndex != -1) {
        return;
    }
    
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gestureRecognizer locationInView:self.collectionView];
        
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        FileAndFolder *fileAndFolder = self.fileList[indexPath.item];
        if (indexPath && indexPath.item < self.fileList.count) {
            
            // 通知 delegate 或执行删除逻辑
            if ([self.delegate respondsToSelector:@selector(fileListView:didLongPressNum:withIsFolder:)]) {
                [self.delegate fileListView:self didLongPressNum:(int)indexPath.item withIsFolder:fileAndFolder.isFolder];
            }
        }
    }
}

- (void)deleteFileWithIndex:(int)num {
    FileAndFolder *fileAndFolder = self.fileList[num];
    NSString *fileString = [self connectFolderAndFile:fileAndFolder.name];
    
    fileAndFolder.name = fileString;
    
    BOOL success = [FileService deleteTextFileIfExists:fileAndFolder];
    if (success) {
        [self.fileList removeObjectAtIndex:num];
    }
    
    [self.collectionView reloadData];
}

- (void)renameFileWithIndex:(int)num withNewName:(NSString *)newName {
    FileAndFolder *fileAndFolder = self.fileList[num];
    NSString *fileString = [self connectFolderAndFile:fileAndFolder.name];
    
    fileAndFolder.name = fileString;
    
    // 获取旧文件扩展名
    NSString *extension = [fileAndFolder.name pathExtension];
    
    // 拼接新文件名（加后缀）
    NSString *finalNewName = extension.length > 0 ? [NSString stringWithFormat:@"%@.%@", newName, extension] : newName;

    // 调用重命名方法
    [FileService renameTextFileIfExists:fileAndFolder toNewName:newName];
    
    // 更新 fileList
    self.fileList[num].name = finalNewName;
    
    [self.collectionView reloadData];
}

- (void)moveFileWithIndex:(int)num {
    // 保存选中的 index
    self.selectedIndex = num;
    
    self.selectedFileRelativeString = [self getRelativeStringWithIndex:num];
    
    // 刷新 CollectionView，让 cellForItemAtIndexPath 走一遍
    [self.collectionView reloadData];
    
    // 获取当前 cell
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:num inSection:0];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (cell) {
        // 放大动画
        [UIView animateWithDuration:0.2 animations:^{
            cell.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }];
        
        // 抖动动画
        CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        shake.fromValue = @(-0.05);
        shake.toValue = @(0.05);
        shake.duration = 0.1;
        shake.autoreverses = YES;
        shake.repeatCount = HUGE_VALF;
        
        [cell.layer addAnimation:shake forKey:@"shakeAnimation"];
    }
}

- (Boolean)moveFiletoFolder {
    if (!self.selectedFileRelativeString) {
        return NO;
    }
    
    // 文件移动逻辑
    
    bool success = [FileService moveFileAtRelativePath:self.selectedFileRelativeString toFolderAtRelativePath:self.folderURL];
    
    if (success) {
        [self reloadData];
        
        self.selectedIndex = -1;
        self.selectedFileRelativeString = nil;
        
        return YES;
    } else {
        NSLog(@"failing to move");
        
        [self reloadData];
        
        self.selectedIndex = -1;
        self.selectedFileRelativeString = nil;
        
        return NO;
    }
}



#pragma mark - List
- (void)openFolder {
    
}

- (void)comebackFolder {
    [self folderURLTrimmed];
    [self reloadData];
	
}

#pragma mark - Other
- (NSMutableArray<FileAndFolder *> *)readFileList:(NSString *)folderURL {
    NSMutableArray *resultMutableArray;
    if (self.fileType == FileTypeICloud) {
        resultMutableArray = [FileService readICloudFolder:folderURL];
    } else {
        resultMutableArray = [FileService listFilesInDocumentsFolder:folderURL];
    }
    
    return resultMutableArray;
}

- (NSString *)connectFolderAndFile:(NSString *)fileName {
    NSString *fileString = @"";
    if (![self.folderURL isEqual:@""]) {
        fileString = [self.folderURL stringByAppendingString:@"/"];
    }
    return [fileString stringByAppendingString:fileName];
}

- (NSString *)getRelativeStringWithIndex:(int)index {
    NSString *name = self.fileList[index].name;
    
    NSString *relativeString = [self connectFolderAndFile:name];
    
    return relativeString;
}

- (void)folderURLAdd:(NSString *)folderName {
    if ([self.folderURL isEqual:@""]) {
        self.folderURL = folderName;
    } else {
        self.folderURL = [self.folderURL stringByAppendingString:@"/"];
        
        self.folderURL = [self.folderURL stringByAppendingString:folderName];
    }
}

- (void)folderURLTrimmed {
    
    if (self.folderURL.length == 0 || [self.folderURL isEqualToString:@"assert"]) {
        NSLog(@"%@", self.folderURL);
        return;
    }
    NSArray<NSString *> *components = [self.folderURL componentsSeparatedByString:@"/"];
    
    // 去除最后一段路径
    NSArray<NSString *> *newComponents = [components subarrayWithRange:NSMakeRange(0, components.count - 1)];
    NSString *newPath = [newComponents componentsJoinedByString:@"/"];
    
    // 如果回退后结果是空字符串或"assert"，则不回退

    
    self.folderURL = newPath;
    

}

// 刷新函数
- (void)reloadData {
    self.fileList = [self readFileList:self.folderURL];
    if (self.folderURL.length == 0) {
        NSIndexSet *indexesToRemove = [self.fileList indexesOfObjectsPassingTest:^BOOL(FileAndFolder *obj, NSUInteger idx, BOOL *stop) {
            return [obj.name isEqualToString:@"assert"] && obj.isFolder;
        }];
        [self.fileList removeObjectsAtIndexes:indexesToRemove];
    }


    [self.collectionView reloadData];
}


@end
