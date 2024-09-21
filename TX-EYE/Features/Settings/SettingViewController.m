//
//  SettingViewController.m
//  TX-EYE
//
//  Created by CoreCat on 16/1/20.
//  Copyright © 2016年 CoreCat. All rights reserved.
//

#import "SettingViewController.h"
#import "Settings.h"
#import "RenameSSIDViewController.h"

@import Masonry;

@interface SettingViewController () <UITableViewDataSource, UITableViewDelegate>
{
    BOOL bAutosave;
    BOOL bRightHandMode;
}
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *returnButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *headerTitleArray;
@property (nonatomic, strong) NSArray *cellTitleArray;

@end

@implementation SettingViewController

/**
 *  列表的Header Title数组
 *
 *  @return 返回字串
 */
- (NSArray *)headerTitleArray
{
    return @[
             NSLocalizedString(@"HEADER_TITLE_0", @"Header title 0"),
             NSLocalizedString(@"HEADER_TITLE_1", @"Header title 1"),
//             NSLocalizedString(@"HEADER_TITLE_2", @"Header title 2")
             ];
}

/**
 *  列表Cell Title数组
 *  数组内数组数与headerTitleArray的大小相同
 *
 *  @return 返回字串
 */
- (NSArray *)cellTitleArray
{
    return @[
             @[
                 NSLocalizedString(@"SECTION_0_CELL_TITLE_0", @"Section 0 cell title 0"),
                 NSLocalizedString(@"SECTION_0_CELL_TITLE_1", @"Section 0 cell title 1"),
                 ],
             @[
                 NSLocalizedString(@"SECTION_1_CELL_TITLE_0", @"Section 1 cell title 0"),
                 ],
//             @[
//                 NSLocalizedString(@"SECTION_2_CELL_TITLE_0", @"Section 2 cell title 0"),
//                 ],
             ];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 配置Top Container
    _topView = [[UIView alloc] init];
    _topView.backgroundColor = [UIColor colorWithRed:1.0/255.0 green:150.0/255.0 blue:254.0/255.0 alpha:1.0];
    [self.view addSubview:_topView];

    // 初始化控件
    [self initControls];
    
    // 添加版本显示
    [self addVersionLabel];
    
    // 获取设置初始值
    bAutosave = [Settings getParameterForAutosave];
    bRightHandMode = [Settings getParameterForRightHandMode];
}

- (void)dealloc
{
    if (!bAutosave) {
        [Settings resetSettings];
    }
}

/**
 *  初始化控件
 */
- (void)initControls
{
    // 配置Top Container
    _topView = [[UIView alloc] init];
    _topView.backgroundColor = [UIColor colorWithRed:1.0/255.0 green:150.0/255.0 blue:254.0/255.0 alpha:1.0];
    [self.view addSubview:_topView];

    // 配置后退按键
    _returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_returnButton setImage:[UIImage imageNamed:@"return"] forState:UIControlStateNormal];
    [_returnButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_returnButton];

    // 配置列表
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    // 注册UITableViewCell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];

    // 布局约束
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.and.right.equalTo(self.view);
        make.height.mas_equalTo(40.0);
    }];
    [_returnButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(36.0, 36.0));
        make.centerY.equalTo(_topView);
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(_topView.mas_safeAreaLayoutGuideLeft).with.offset(8.0);
        } else {
            make.left.equalTo(_topView).with.offset(8.0);
        }
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_topView.mas_bottom);
        make.left.right.and.bottom.equalTo(self.view);
    }];
}

/**
 *  触摸按键入口
 *
 *  @param button 按键
 */
- (void)tapButton:(UIButton *)button
{
    // 返回键
    if (button == self.returnButton) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)addVersionLabel
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // app版本
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    // app build版本
    NSString *appBuild = [infoDictionary objectForKey:@"CFBundleVersion"];
    // version+build
    NSString *versionBuild = [NSString stringWithFormat:@"Ver %@ (Build %@)", appVersion, appBuild];
    
    UILabel *label = [[UILabel alloc] init];
    [label setText:versionBuild];
    [label sizeToFit];
    [label setTextColor:[UIColor whiteColor]];
    [_topView addSubview:label];

    // 布局约束
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_topView);
        make.right.equalTo(_topView).with.offset(-16.0);
    }];
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.headerTitleArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.headerTitleArray[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cellTitleArray[section] count];
}

#pragma mark - TableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    // 不需要选择样式
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    // 配置不同单元格的样式，根绝不同情况去修改
    // Section 0
    if (section == 0) {
        // Row 0
        if (row == 0) {
            UISwitch *s = [[UISwitch alloc] init];
            
            BOOL on = bAutosave;
            s.on = on;
            
            [s addTarget:self action:@selector(saveSettingParametersAutoSave:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = s;
        }
    }
    // Section 1
    else if (section == 1) {
        // Row 0
        if (row == 0) {
            UISwitch *s = [[UISwitch alloc] init];
            
            BOOL on = bRightHandMode;
            s.on = on;
            
            [s addTarget:self action:@selector(saveSettingRightHandMode:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = s;
        }
    }
    // Section 2
    else if (section == 2) {
        
    }
    
    cell.textLabel.text = self.cellTitleArray[indexPath.section][indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 23.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    // Section 0
    if (section == 0) {
        // Row 1
        if (row == 1) {
            // 重置设置
            [Settings resetSettings];
            
            // 显示重置成功的Alert
            NSString *title = NSLocalizedString(@"RESET_ALERT_TITLE", @"Reset Alert Title");
            NSString *message = NSLocalizedString(@"RESET_ALERT_MESSAGE", @"Reset alert message");
            NSString *buttonTitle = NSLocalizedString(@"RESET_ALERT_OK_BUTTON_TITLE", @"Reset alert OK button title");
            // 根据不同的系统版本选择不同的Alert控件
            if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
                // 使用UIAlertController
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                         message:message
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                [alertController addAction:action];
                [self showViewController:alertController sender:nil];
            } else {
                // 使用UIAlertView
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                    message:message
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:buttonTitle, nil];
                [alertView show];
            }
        }
    }
    // Section 1
    else if (section == 2) {
        // Row 0
        if (row == 0) {
            RenameSSIDViewController *vc = [[RenameSSIDViewController alloc] init];
//            [self presentViewController:vc animated:YES completion:nil];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:navController animated:YES completion:nil];
        }
    }
}

#pragma mark - Setting

/**
 *  保存参数自动保存设置
 *
 *  @param s switch
 */
- (void)saveSettingParametersAutoSave:(UISwitch *)s
{
    BOOL isOn = s.isOn;
    [Settings saveParameterForAutosave:isOn];
}

/**
 *  保存右手模式设置
 *
 *  @param s switch
 */
- (void)saveSettingRightHandMode:(UISwitch *)s
{
    BOOL isOn = s.isOn;
    [Settings saveParameterForRightHandMode:isOn];
}

@end
