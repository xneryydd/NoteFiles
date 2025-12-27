//
//  EditToolbar.h
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/7/29.
//

#import <UIKit/UIKit.h>
#import "EditToolbarItem.h"

@interface EditToolbar : UIView

@property (nonatomic, copy) NSArray<EditToolbarItem *> *items;

- (instancetype)initWithItems:(NSArray<EditToolbarItem *> *)items preferredHeight:(CGFloat)height;

@end
