//
//  FileAndFolder.m
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/8/15.
//

#import "FileAndFolder.h"

@implementation FileAndFolder

- (instancetype)initWithName:(NSString *)name withIsFolder:(bool)isFolder {
    self = [super init];
    if (self) {
        self.name = name;
        self.isFolder = isFolder;
    }
    
    return self;
}

@end
