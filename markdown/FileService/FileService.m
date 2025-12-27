//
//  FilesManager.m
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/13.
//

#import "FileService.h"

@implementation FileService
#pragma mark - 文件读取部分
+ (NSMutableArray<FileAndFolder *> *)listFilesInDocumentsFolder:(NSString * _Nonnull)folderName {
    // 取Documents路径
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *targetPath = nil;
    
    if (folderName == nil || folderName.length == 0) {
        // 根目录
        targetPath = documentsPath;
    } else {
        // 子文件夹
        targetPath = [documentsPath stringByAppendingPathComponent:folderName];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL exists = [fileManager fileExistsAtPath:targetPath isDirectory:&isDir];
    
    if (!exists || !isDir) {
        // 文件夹不存在或不是文件夹，返回空数组
        return [@[] mutableCopy];
    }
    
    NSError *error = nil;
    NSArray<NSString *> *allFiles = [fileManager contentsOfDirectoryAtPath:targetPath error:&error];
    
    if (error) {
        NSLog(@"读取文件夹内容失败: %@", error);
        return [@[] mutableCopy];
    }
    
    NSMutableArray<FileAndFolder *> *result = [NSMutableArray array];
    
    for (NSString *file in allFiles) {
        // 只有根目录才排除 "assert"
        if ((folderName == nil || folderName.length == 0) && [file isEqualToString:@"assert"]) {
            continue;
        }
        
        NSString *fullPath = [targetPath stringByAppendingPathComponent:file];
        BOOL isSubDir = NO;
        [fileManager fileExistsAtPath:fullPath isDirectory:&isSubDir];
        
        FileAndFolder *item = [[FileAndFolder alloc] initWithName:file withIsFolder:isSubDir];
        [result addObject:item];
    }
    
    return result;
}

+ (NSString *)uniqueFilePathForFileName:(NSString *)fileName inDirectory:(NSString *)directory isRepeat:(bool)yes {
    NSString *name = [fileName stringByDeletingPathExtension];
    NSString *ext = [fileName pathExtension];
    NSString *filePath = [directory stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    int index = 1;
    while ([fileManager fileExistsAtPath:filePath]) {
        if (yes) {
            NSString *newFileName = [NSString stringWithFormat:@"%@_%d.%@", name, index, ext];
            filePath = [directory stringByAppendingPathComponent:newFileName];
            index++;
        } else {
            return filePath;
        }
    }
    return filePath;
}

+ (BOOL)createTextFileIfNeeded:(NSString *_Nonnull)fileName withContent:(NSString *_Nonnull)content isRepeat:(bool)yes {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSLog(@"%@", fileName);
    NSString *filePath = [self uniqueFilePathForFileName:fileName inDirectory:documentsPath isRepeat:yes];
    
    NSError *error = nil;
    BOOL success = [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!success) {
        NSLog(@"文件写入失败：%@", error.localizedDescription);
    } else {
        NSLog(@"文件创建成功：%@", [filePath lastPathComponent]);
    }
    return success;
}

+ (BOOL)deleteTextFileIfExists:(FileAndFolder *_Nonnull)fileAndFolder {
    // 获取 Documents 目录
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    // 拼接完整路径（这里不再用 uniqueFilePath，直接使用真实名字，防止误删）
    NSString *targetPath = [documentsPath stringByAppendingPathComponent:fileAndFolder.name];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    BOOL exists = [fileManager fileExistsAtPath:targetPath isDirectory:&isDir];
    
    // 判断是否存在
    if (!exists) {
        NSLog(@"❌ 文件/文件夹不存在：%@", fileAndFolder.name);
        return NO;
    }
    
    // 校验类型匹配（防止同名文件夹/文件误删）
    if (fileAndFolder.isFolder != isDir) {
        NSLog(@"⚠️ 类型不匹配，可能存在同名的文件和文件夹，已取消删除：%@", fileAndFolder.name);
        return NO;
    }
    
    // 删除
    NSError *error = nil;
    BOOL success = [fileManager removeItemAtPath:targetPath error:&error];
    
    if (!success) {
        NSLog(@"❌ 删除失败：%@", error.localizedDescription);
    } else {
        NSLog(@"✅ 删除成功：%@", fileAndFolder.name);
    }
    
    return success;
}

+ (BOOL)renameTextFileIfExists:(FileAndFolder *_Nonnull)fileAndFolder toNewName:(NSString *_Nonnull)newFileName {
    NSString *oldFileName = fileAndFolder.name;
    
    // 获取 Documents 目录
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];

    // 原完整路径
    NSString *oldFilePath = [documentsPath stringByAppendingPathComponent:oldFileName];

    // 原目录路径
    NSString *directory = [oldFilePath stringByDeletingLastPathComponent];

    // 原扩展名（保留后缀）
    NSString *extension = [oldFilePath pathExtension];

    // 构建带扩展名的新文件名
    NSString *newFileNameWithExtension = extension.length > 0 ? [NSString stringWithFormat:@"%@.%@", newFileName, extension] : newFileName;

    // 新路径
    NSString *newFilePath = [directory stringByAppendingPathComponent:newFileNameWithExtension];

    // 检查原文件是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:oldFilePath]) {
        NSLog(@"❌ 原文件不存在：%@", [oldFilePath lastPathComponent]);
        return NO;
    }

    // 检查新文件是否已存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:newFilePath]) {
        NSLog(@"❌ 新文件已存在，不能重命名为同名文件：%@", [newFilePath lastPathComponent]);
        return NO;
    }

    // 执行重命名
    NSError *error = nil;
    BOOL success = [[NSFileManager defaultManager] moveItemAtPath:oldFilePath toPath:newFilePath error:&error];

    if (success) {
        NSLog(@"✅ 文件重命名成功：%@ → %@", [oldFilePath lastPathComponent], [newFilePath lastPathComponent]);
    } else {
        NSLog(@"❌ 文件重命名失败：%@", error.localizedDescription);
    }

    return success;
}

+ (BOOL)moveFileAtRelativePath:(NSString *_Nonnull)fileRelativePath
                   toFolderAtRelativePath:(NSString *_Nonnull)folderRelativePath {
    if (fileRelativePath.length == 0) {
        NSLog(@"❌ 参数错误：文件路径为空");
        return NO;
    }

    // 1. 获取 Documents 目录
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];

    // 2. 拼接绝对路径
    NSString *filePath   = [documentsPath stringByAppendingPathComponent:fileRelativePath];
    NSString *folderPath = [documentsPath stringByAppendingPathComponent:folderRelativePath];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    // 3. 检查源文件是否存在
    BOOL isDir = NO;
    if (![fileManager fileExistsAtPath:filePath isDirectory:&isDir] || isDir) {
        NSLog(@"❌ 源文件不存在或不是文件：%@", fileRelativePath);
        return NO;
    }

    // 4. 检查目标文件夹是否存在
    if (![fileManager fileExistsAtPath:folderPath isDirectory:&isDir] || !isDir) {
        NSLog(@"❌ 目标文件夹不存在或不是文件夹：%@", folderRelativePath);
        return NO;
    }

    // 5. 构造目标路径
    NSString *fileName = [fileRelativePath lastPathComponent];
    NSString *targetPath = [folderPath stringByAppendingPathComponent:fileName];

    // 6. 执行移动
    NSError *error = nil;
    BOOL success = [fileManager moveItemAtPath:filePath toPath:targetPath error:&error];

    if (!success) {
        NSLog(@"❌ 移动失败：%@", error.localizedDescription);
    } else {
        NSLog(@"✅ 移动成功：%@ -> %@", fileRelativePath, folderRelativePath);
    }

    return success;
}


//
+ (nullable NSString *)readFileContentFromURL:(NSURL *)fileURL {
    if (!fileURL) {
        NSLog(@"文件 URL 为空");
        return nil;
    }
    // 获取 App 沙盒 Documents 路径
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];

    // 获取 URL 的本地路径（如 /var/mobile/...）
    NSString *filePath = [fileURL path];
    
    NSError *error = nil;
    NSString *content = nil;

    // 判断是否为沙盒内的文件（前缀是否是 Documents 路径）
    if ([filePath hasPrefix:documentsPath]) {
        // 属于 App 自己的沙盒，使用 stringWithContentsOfFile
        content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    } else {
        // 来自其他 App（如微信、文件App）共享的，使用 stringWithContentsOfURL
        if ([fileURL startAccessingSecurityScopedResource]) {
            content = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:&error];
            [fileURL stopAccessingSecurityScopedResource];
        } else {
            content = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:&error];
        }
    }

    if (error) {
        NSLog(@"读取文件失败：%@", error.localizedDescription);
        return nil;
    }

    return content;
}

+ (nullable UIImage *)readImageFromURL:(NSURL *)fileURL {
    if (!fileURL) {
        NSLog(@"图片 URL 为空");
        return nil;
    }
    
    // 获取 App 沙盒 Documents 路径
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [fileURL path];
    
    UIImage *image = nil;

    // 判断是否为沙盒内的文件
    if ([filePath hasPrefix:documentsPath]) {
        // 属于 App 沙盒，直接用 filePath 读取
        NSLog(@"%@", filePath);
        image = [UIImage imageWithContentsOfFile:filePath];
    } else {
        // 来自文件 App / 微信等外部 app，需要请求访问权限
        if ([fileURL startAccessingSecurityScopedResource]) {
            NSData *imageData = [NSData dataWithContentsOfURL:fileURL];
            image = [UIImage imageWithData:imageData];
            [fileURL stopAccessingSecurityScopedResource];
        } else {
            // 如果没获得访问权限，尝试直接读取
            NSData *imageData = [NSData dataWithContentsOfURL:fileURL];
            image = [UIImage imageWithData:imageData];
        }
    }

    if (!image) {
        NSLog(@"❌ 图片读取失败");
    }

    return image;
}



+ (BOOL)saveText:(NSString *)textString toFileNamed:(NSString *)fileString {
    if (fileString.length == 0) {
        NSLog(@"文件名为空");
        return NO;
    }
    if (!textString) {
        NSLog(@"要保存的内容为空");
        return NO;
    }

    // 获取 Documents 路径
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];

    // 拼接完整路径
    NSString *fullPath = [documentsPath stringByAppendingPathComponent:fileString];

    NSError *error = nil;
    BOOL success = [textString writeToFile:fileString atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (!success || error) {
        NSLog(@"保存文件失败：%@", error.localizedDescription);
        return NO;
    }

    NSLog(@"文件已成功保存到：%@", fullPath);
    return YES;
}


/// 判断路径是否属于本地沙盒目录（Documents、Library、tmp）
+ (BOOL)isSandboxFileURL:(NSURL *)url {
    if (!url.isFileURL) return NO;

    NSString *path = url.path;

    NSArray<NSString *> *sandboxDirectories = @[
        NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject,
        NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject,
        NSTemporaryDirectory()
    ];

    for (NSString *dir in sandboxDirectories) {
        if ([path hasPrefix:dir]) {
            return YES;
        }
    }

    return NO;
}

#pragma mark - 读取iCloud
+ (NSMutableArray<FileAndFolder *> *)readICloudFolder:(NSString *)folderName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray<FileAndFolder *> *resultArray = [NSMutableArray array];
    
    // 获取 iCloud 容器
    NSURL *containerURL = [fileManager URLForUbiquityContainerIdentifier:nil];
    if (!containerURL) {
        NSLog(@"❌ 找不到 iCloud 容器，请检查 iCloud 权限和设置");
        return resultArray;
    }
    
    // 拼接目标路径 Documents/folderName
    NSURL *targetFolderURL = [[containerURL URLByAppendingPathComponent:@"Documents"]
                              URLByAppendingPathComponent:folderName ?: @""];
    
    // 创建目录（如果不存在）
    if (![fileManager fileExistsAtPath:targetFolderURL.path]) {
        NSError *createError = nil;
        [fileManager createDirectoryAtURL:targetFolderURL
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&createError];
        if (createError) {
            NSLog(@"❌ 创建目录失败: %@", createError);
            return resultArray;
        }
    }
    
    // 读取内容
    NSError *error = nil;
    NSArray<NSURL *> *contents = [fileManager contentsOfDirectoryAtURL:targetFolderURL
                                           includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                              options:0
                                                                error:&error];
    if (error) {
        NSLog(@"❌ 读取目录失败: %@", error);
        return resultArray;
    }
    
    for (NSURL *url in contents) {
        // 获取下载状态
        NSString *status = nil;
        [url getResourceValue:&status forKey:NSURLUbiquitousItemDownloadingStatusKey error:nil];
        
        if (![status isEqualToString:NSURLUbiquitousItemDownloadingStatusDownloaded] &&
            ![status isEqualToString:NSURLUbiquitousItemDownloadingStatusCurrent]) {
            // 请求下载未完成的文件
            [fileManager startDownloadingUbiquitousItemAtURL:url error:nil];
        }
        
        // 判断是否文件夹
        NSNumber *isDir = nil;
        [url getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil];
        
        // 创建 FileAndFolder 对象
        FileAndFolder *item = [[FileAndFolder alloc] initWithName:url.lastPathComponent
                                                     withIsFolder:isDir.boolValue];
        [resultArray addObject:item];
    }
    
    return resultArray;
}


+ (NSData *)readICloudFileAtRelativePath:(NSString *)relativePath {
    if (!relativePath || relativePath.length == 0) {
        NSLog(@"❌ relativePath 为空");
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 获取 iCloud 容器 URL
    NSURL *containerURL = [fileManager URLForUbiquityContainerIdentifier:nil];
    if (!containerURL) {
        NSLog(@"❌ 找不到 iCloud 容器，请检查 iCloud 设置");
        return nil;
    }
    
    // 拼接完整文件路径：Documents/relativePath
    NSURL *fileURL = [[containerURL URLByAppendingPathComponent:@"Documents"]
                      URLByAppendingPathComponent:relativePath];
    
    // 检查下载状态
    NSString *status = nil;
    [fileURL getResourceValue:&status
                       forKey:NSURLUbiquitousItemDownloadingStatusKey
                        error:nil];
    
    if (![status isEqualToString:NSURLUbiquitousItemDownloadingStatusDownloaded] &&
        ![status isEqualToString:NSURLUbiquitousItemDownloadingStatusCurrent]) {
        
        NSLog(@"📥 文件未下载，开始下载: %@", fileURL.lastPathComponent);
        [fileManager startDownloadingUbiquitousItemAtURL:fileURL error:nil];
        
        // 等待下载（最多 10 秒）
        NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:10];
        while ([timeoutDate timeIntervalSinceNow] > 0) {
            [fileURL getResourceValue:&status
                               forKey:NSURLUbiquitousItemDownloadingStatusKey
                                error:nil];
            if ([status isEqualToString:NSURLUbiquitousItemDownloadingStatusDownloaded] ||
                [status isEqualToString:NSURLUbiquitousItemDownloadingStatusCurrent]) {
                break;
            }
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
        }
    }
    
    // 读取文件数据
    NSData *data = [NSData dataWithContentsOfURL:fileURL];
    if (!data) {
        NSLog(@"❌ 读取文件失败: %@", relativePath);
    }
    return data;
}


@end
