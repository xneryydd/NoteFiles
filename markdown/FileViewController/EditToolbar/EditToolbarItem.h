//
//  EditToolbarItem.h
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/29.
//

#import <Foundation/Foundation.h>

@interface EditToolbarItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, copy) void (^action)(void);

- (instancetype)initWithTitle:(NSString *)title action:(void (^)(void))action;

@end
