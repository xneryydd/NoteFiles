//
//  SettingViewController.m
//  markdown
//
//  Created by 赢赢淡淡小奈尔 on 2025/8/20.
//

#import "SettingViewController.h"
#import "../../GlobalInfoManager/GlobalInfoManager.h"

@interface SettingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // 初始化 tableView
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    // 其他app打开时执行
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openOtherFile)
                                             name:@"OpenFileNotification"
                                           object:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1; // 一个分组
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3; // 三行：深色模式、行距、字体大小
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"SettingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    if (indexPath.row == 0) {
        // 深色/浅色模式
        cell.textLabel.text = @"深色模式";
        
        UISwitch *modeSwitch = [[UISwitch alloc] init];
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            modeSwitch.on = YES;
        } else {
            modeSwitch.on = NO;
        }
        [modeSwitch addTarget:self action:@selector(modeSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = modeSwitch;
    }
    else if (indexPath.row == 1) {
        // 行距设置
        cell.textLabel.text = @"行距";
        
        UIStepper *stepper = [[UIStepper alloc] init];
        stepper.minimumValue = 0;
        stepper.maximumValue = 20;
        stepper.stepValue = 1;
        
        // 从全局管理器取当前值
        TextStyleManager *manager = [TextStyleManager sharedManager];
        stepper.value = manager.lineSpacing;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", manager.lineSpacing];
        
        [stepper addTarget:self action:@selector(lineSpacingChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = stepper;
    }
    else if (indexPath.row == 2) {
        // 字体大小设置
        cell.textLabel.text = @"字体大小";
        
        UIStepper *stepper = [[UIStepper alloc] init];
        stepper.minimumValue = 10;
        stepper.maximumValue = 30;
        stepper.stepValue = 1;
        
        TextStyleManager *manager = [TextStyleManager sharedManager];
        stepper.value = manager.textFont.pointSize;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", manager.textFont.pointSize];
        
        [stepper addTarget:self action:@selector(fontSizeChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = stepper;
    }
    
    return cell;
}

#pragma mark - 切换深色/浅色模式
- (void)modeSwitchChanged:(UISwitch *)sender {
    UIUserInterfaceStyle style = sender.isOn ? UIUserInterfaceStyleDark : UIUserInterfaceStyleLight;
    
    if (@available(iOS 13.0, *)) {
        // 获取当前激活的 windowScene
        UIWindow *targetWindow = nil;
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in scene.windows) {
                    if (window.isKeyWindow) {
                        targetWindow = window;
                        break;
                    }
                }
            }
            if (targetWindow) break;
        }
        
        if (targetWindow) {
            targetWindow.overrideUserInterfaceStyle = style;
        } else {
            // fallback: 设置整个 VC（如果没找到 window）
            self.overrideUserInterfaceStyle = style;
        }
    } else {
        // iOS 12 及以下，没有 Dark Mode API，只能忽略
        self.overrideUserInterfaceStyle = style;
    }
}


#pragma mark - 字体修改
// 修改行距
- (void)lineSpacingChanged:(UIStepper *)sender {
    TextStyleManager *manager = [TextStyleManager sharedManager];
    manager.lineSpacing = sender.value;
    
    // 刷新 cell 显示
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", manager.lineSpacing];
    
    // 通知全局刷新
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TextStyleChangedNotification" object:nil];
}

// 修改字体大小
- (void)fontSizeChanged:(UIStepper *)sender {
    TextStyleManager *manager = [TextStyleManager sharedManager];
    manager.textFont = [UIFont systemFontOfSize:sender.value];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f", manager.textFont.pointSize];
    
    // 通知全局刷新
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TextStyleChangedNotification" object:nil];
}

#pragma mark - 外部app查看文件
- (void)openOtherFile {
    // 你可以先执行文件打开逻辑，然后退出
    NSLog(@"mytitle: %@", self.title);
    [self.navigationController popViewControllerAnimated:YES];
    // 你可以先执行文件打开逻辑，然后退出
    NSLog(@"mytitle: %@", self.title);
}

@end
