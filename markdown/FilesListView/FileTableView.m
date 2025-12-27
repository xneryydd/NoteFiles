//
//  FileTableView.m
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/8/16.
//

#import "FileListView.h"

@interface FileTableView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSLayoutConstraint *tableHeightConstraint;

// 数据源：大cell标题
@property (nonatomic, strong) NSArray<NSString *> *sectionTitles;
// 数据源：子项
@property (nonatomic, strong) NSArray<NSArray<NSString *> *> *sectionContents;
// 展开状态
@property (nonatomic, strong) NSMutableArray<NSNumber *> *sectionExpanded;

@end

@implementation FileTableView
/*
 数据源结构（sectionContents）:
 
 section 0 → 标题 "位置"
    row 0: "iCloud 云盘"
    row 1: "我的 iPhone"
    row 2: "最近删除"

 section 1 → 标题 "个人收藏"
    row 0: "下载"
 
 section 2 -> 设置
    row 0: "设置"
*/

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.scrollEnabled = NO; // ❌ 禁止内部滚动，由外层scrollView控制
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self addSubview:self.tableView];

    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];

    self.tableHeightConstraint = [self.tableView.heightAnchor constraintEqualToConstant:100];
    self.tableHeightConstraint.active = YES;

    // 初始化数据
    self.sectionTitles = @[@"位置", @"个人收藏", @"设置"];
    self.sectionContents = @[
        @[@"iCloud 云盘", @"我的 iPhone", @"最近删除"],
        @[@"下载"],
        @[@"设置"]
    ];
    self.sectionExpanded = [@[@(YES), @(YES), @(YES)] mutableCopy]; // 默认展开
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (![self.sectionExpanded[section] boolValue]) {
        return 0;
    }
    return self.sectionContents[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = self.sectionContents[indexPath.section][indexPath.row];
    return cell;
}

#pragma mark - Section Header（大cell）

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:self.sectionTitles[section] forState:UIControlStateNormal];
    button.tag = section;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0);
    [button addTarget:self action:@selector(toggleSection:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0;
}

#pragma mark - 折叠展开逻辑

- (void)toggleSection:(UIButton *)sender {
    NSInteger section = sender.tag;
    BOOL isExpanded = [self.sectionExpanded[section] boolValue];
    self.sectionExpanded[section] = @(!isExpanded);

    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];

    [self reloadData];
}

#pragma mark - UITableViewDelegate (小cell点击)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 点击后取消选中高亮
    
    NSString *title = self.sectionContents[indexPath.section][indexPath.row];
    NSLog(@"点击了小cell: %@", title);
    
    if (self.delegate) {
        [self.delegate fileTableView:self didSelectTitleNum:(int)indexPath.section AndContentNum:(int)indexPath.row];
    }
}


#pragma mark - 更新高度

- (void)reloadData {
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];

    // 内容高度
    CGFloat contentHeight = self.tableView.contentSize.height;

    // 最少 588
    CGFloat finalHeight = MAX(contentHeight, 588);

    self.tableHeightConstraint.constant = finalHeight;
    [self layoutIfNeeded];
}

@end
