//
//  FileAndFolder.h
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/8/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileAndFolder : NSObject

@property (strong, nonatomic) NSString *name;

@property (assign, nonatomic) bool isFolder;

- (instancetype)initWithName:(NSString *)name withIsFolder:(bool)isFolder;

@end

NS_ASSUME_NONNULL_END
