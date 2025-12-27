//
//  FilesManager.h
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/13.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FileAndFolder.h"

@interface FileService : NSObject

+ (NSMutableArray<FileAndFolder *> *_Nonnull)listFilesInDocumentsFolder:(NSString *_Nonnull)folderName;

+ (BOOL)createTextFileIfNeeded:(NSString *_Nonnull)fileName withContent:(NSString *_Nonnull)content isRepeat:(bool)yes;

+ (BOOL)deleteTextFileIfExists:(FileAndFolder *_Nonnull)fileAndFolder;

+ (BOOL)renameTextFileIfExists:(FileAndFolder *_Nonnull)fileAndFolder toNewName:(NSString *_Nonnull)newFileName;

+ (BOOL)moveFileAtRelativePath:(NSString *_Nonnull)fileRelativePath
        toFolderAtRelativePath:(NSString *_Nonnull)folderRelativePath;

+ (nullable NSString *)readFileContentFromURL:(NSURL *_Nonnull)fileURL;

+ (nullable UIImage *)readImageFromURL:(NSURL *_Nullable)fileURL;

+ (BOOL)saveText:(NSString *_Nonnull)textString toFileNamed:(NSString *_Nonnull)fileString;

+ (BOOL)isSandboxFileURL:(NSURL *_Nonnull)url;

+ (NSMutableArray<FileAndFolder *> *_Nonnull)readICloudFolder:(NSString *_Nonnull)folderName;

+ (NSData *_Nonnull)readICloudFileAtRelativePath:(NSString *_Nonnull)relativePath;

@end
