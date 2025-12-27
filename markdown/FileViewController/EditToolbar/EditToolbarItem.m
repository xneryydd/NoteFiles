//
//  EditToolbarItem.m
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/29.
//

#import "EditToolbarItem.h"

@implementation EditToolbarItem

- (instancetype)initWithTitle:(NSString *)title action:(void (^)(void))action {
    self = [super init];
    if (self) {
        _title = title;
        _action = action;
    }
    return self;
}

@end
