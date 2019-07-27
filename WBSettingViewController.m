#import "xia0WeChat.h"
#import "WBSettingViewController.h"
#import <objc/objc-runtime.h>
#import "WBMultiSelectGroupsViewController.h"
#import "XEditViewController.h"

@interface WBSettingViewController () <MultiSelectGroupsViewControllerDelegate>

@property (nonatomic, strong) WCTableViewManager *tableViewInfo;

@end

@implementation WBSettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // 增加对iPhone X的屏幕适配
        CGRect winSize = [UIScreen mainScreen].bounds;
        if (winSize.size.height == 812) { // iPhone X 高为812
            winSize.size.height -= 88;
            winSize.origin.y = 88;
        }
        _tableViewInfo = [[objc_getClass("WCTableViewManager") alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTitle];
    [self reloadTableData];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;

    MMTableView *tableView = [self.tableViewInfo getTableView];
    [self.view addSubview:tableView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopLoading];
}

- (void)initTitle {
    self.title = @"集赞助手设置";
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0]}];
}

- (void)reloadTableData {
    [self.tableViewInfo clearAllSection];
    
    [self addZanSettingSection];
    [self addSupportSection];
    [self addAboutSection];
    
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [tableView reloadData];
}

#pragma mark - ZanSetting
- (void)addZanSettingSection {
    WCTableViewSectionManager *sectionInfo = [objc_getClass("WCTableViewSectionManager") sectionInfoHeader:@"集赞功能设置"];

    [sectionInfo addCell:[self createFKZanCell]];
    [sectionInfo addCell:[self createFKCmtCell]];

    [sectionInfo addCell:[self createMyCmtSwitchCell]];

    BOOL isOpenMyCmt = [[NSUserDefaults standardUserDefaults] boolForKey:@"kMoreCmtOpenMyCmt"];
    if (isOpenMyCmt)
    {
        [sectionInfo addCell:[self createMyCmtContentCell]];
    }
    
    [self.tableViewInfo addSection:sectionInfo];
}

- (WCTableViewCellManager *)createFKZanCell {
    NSInteger zanCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"kMoreZanID"];
    if (!zanCount)
    {
        zanCount = 0;
    }

     return [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(settingMoreZan) target:self title:@"集攒数量设置" rightValue:[@(zanCount) stringValue] WithDisclosureIndicator:0];
}

- (void)settingMoreZan{
    NSInteger zanCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"kMoreZanID"];
    [self alertControllerWithTitle:@"集赞数量设置"
                           message:@"设置需要增加的赞个数（原始赞保留）"
                           content:[NSString stringWithFormat:@"%ld", (long)zanCount]
                       placeholder:@"请输入增加赞数"
                      keyboardType:UIKeyboardTypeNumberPad
                               blk:^(UITextField *textField) {
                                   [[NSUserDefaults standardUserDefaults] setInteger:textField.text.integerValue forKey:@"kMoreZanID"];
                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                   [self reloadTableData];
                               }];
}

- (WCTableViewCellManager *)createFKCmtCell {
    NSInteger cmtCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"kMoreCmtID"];
    if (!cmtCount)
    {
        cmtCount = 0;
    }

     return [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(settingMoreCmt) target:self title:@"评论数量设置" rightValue:[@(cmtCount) stringValue] WithDisclosureIndicator:0];
}

- (void)settingMoreCmt{
    NSInteger cmtCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"kMoreCmtID"];
    [self alertControllerWithTitle:@"评论数量设置"
                           message:@"设置需要增加的评论个数（原始评论保留）"
                           content:[NSString stringWithFormat:@"%ld", (long)cmtCount]
                       placeholder:@"请输入增加评论数"
                      keyboardType:UIKeyboardTypeNumberPad
                               blk:^(UITextField *textField) {
                                   [[NSUserDefaults standardUserDefaults] setInteger:textField.text.integerValue forKey:@"kMoreCmtID"];
                                   [[NSUserDefaults standardUserDefaults] synchronize];
                                   [self reloadTableData];
                               }];
}

- (WCTableViewCellManager *)createMyCmtSwitchCell {

    BOOL isOpenMyCmt = [[NSUserDefaults standardUserDefaults] boolForKey:@"kMoreCmtOpenMyCmt"];

    WCTableViewCellManager *cellInfo = [objc_getClass("WCTableViewCellManager") switchCellForSel:@selector(settingMyCmtSwitch:) target:self title:@"开启自定义评论" on:isOpenMyCmt];

    return cellInfo;
}

- (WCTableViewCellManager *)createMyCmtContentCell {
    NSString *myCmtContent = [[NSUserDefaults standardUserDefaults] objectForKey:@"kMoreCmtMyCmtContent"];
    myCmtContent = myCmtContent.length == 0 ? @"请填写" : myCmtContent;

    WCTableViewCellManager *cellInfo = [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(settingMyCmtContent) target:self title:@"自定义评论内容" rightValue:myCmtContent WithDisclosureIndicator:1];

    return cellInfo;
}

- (void)settingMyCmtSwitch:(UISwitch *)arg {
    [[NSUserDefaults standardUserDefaults] setBool:arg.on forKey:@"kMoreCmtOpenMyCmt"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reloadTableData];
}

- (void)settingMyCmtContent {
    XEditViewController *editVC = [[XEditViewController alloc] init];
    editVC.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"kMoreCmtMyCmtContent"];
    [editVC setEndEditing:^(NSString *text) {
        [[NSUserDefaults standardUserDefaults] setObject:text forKey:@"kMoreCmtMyCmtContent"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self reloadTableData];
    }];
    editVC.title = @"请输入自定义评论内容";
    editVC.placeholder = @"开启时会从中随机生成(一行为一条评论)";
    [self.navigationController PushViewController:editVC animated:YES];
}

#pragma mark - About
- (void)addAboutSection {
    WCTableViewSectionManager *sectionInfo = [objc_getClass("WCTableViewSectionManager") sectionInfoHeader:@"关于我/项目"];
    
    [sectionInfo addCell:[self createAboutmeCell]];
    [sectionInfo addCell:[self createGithubCell]];
    [sectionInfo addCell:[self createBlogCell]];
    
    [self.tableViewInfo addSection:sectionInfo];
}

- (WCTableViewCellManager *)createAboutmeCell {
    return [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(showAboutme) target:self title:@"关于我" rightValue: @"xia0" WithDisclosureIndicator:1];
}

- (WCTableViewCellManager *)createGithubCell {
    return [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(showGithub) target:self title:@"项目Github" rightValue: @"🌟star" WithDisclosureIndicator:1];
}

- (WCTableViewCellManager *)createBlogCell {
    return [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(showBlog) target:self title:@"项目分析"];
}

- (void)showAboutme {
    NSURL *gitHubUrl = [NSURL URLWithString:@"http://4ch12dy.site/aboutme/"];
    MMWebViewController *webViewController = [[objc_getClass("MMWebViewController") alloc] initWithURL:gitHubUrl presentModal:NO extraInfo:nil];
    [self.navigationController PushViewController:webViewController animated:YES];
}

- (void)showGithub {
    NSURL *gitHubUrl = [NSURL URLWithString:@"https://github.com/4ch12dy/fkwechatzan"];
    MMWebViewController *webViewController = [[objc_getClass("MMWebViewController") alloc] initWithURL:gitHubUrl presentModal:NO extraInfo:nil];
    [self.navigationController PushViewController:webViewController animated:YES];
}

- (void)showBlog {
    NSURL *blogUrl = [NSURL URLWithString:@"http://4ch12dy.site/2019/07/22/fkwechatLike/fkwechatLike/"];
    MMWebViewController *webViewController = [[objc_getClass("MMWebViewController") alloc] initWithURL:blogUrl presentModal:NO extraInfo:nil];
    [self.navigationController PushViewController:webViewController animated:YES];
}

#pragma mark - Support
- (void)addSupportSection {
    WCTableViewSectionManager *sectionInfo = [objc_getClass("WCTableViewSectionManager") sectionInfoHeader:@"若有帮助，可以打赏支持作者"];
    
    [sectionInfo addCell:[self createWeChatPayingCell]];
    
    [self.tableViewInfo addSection:sectionInfo];
}

- (WCTableViewCellManager *)createWeChatPayingCell {
    return [objc_getClass("WCTableViewCellManager") normalCellForSel:@selector(payingToAuthor) target:self title:@"微信打赏" rightValue:@"支持作者😈" WithDisclosureIndicator:1];
}

- (void)payingToAuthor {
    [self startLoadingNonBlock];
    ScanQRCodeLogicController *scanQRCodeLogic = [[objc_getClass("ScanQRCodeLogicController") alloc] initWithViewController:self CodeType:31];
    scanQRCodeLogic.fromScene = 1;
    
    NewQRCodeScanner *qrCodeScanner = [[objc_getClass("NewQRCodeScanner") alloc] initWithDelegate:scanQRCodeLogic CodeType:31];

    NSString *rewardStr = @"m0Ms67nN$+P*ZKLtExYpfe";
    NSData *rewardData = [rewardStr dataUsingEncoding:4];  
    [qrCodeScanner notifyResult:rewardStr type:@"WX_CODE" version:0 rawData:rewardData];
}

#pragma mark - MultiSelectGroupsViewControllerDelegate
- (void)onMultiSelectGroupCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)onMultiSelectGroupReturn:(NSArray *)arg1 {
    
    [self reloadTableData];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertControllerWithTitle:(NSString *)title content:(NSString *)content placeholder:(NSString *)placeholder blk:(void (^)(UITextField *))blk {
    [self alertControllerWithTitle:title message:nil content:content placeholder:placeholder blk:blk];
}

- (void)alertControllerWithTitle:(NSString *)title message:(NSString *)message content:(NSString *)content placeholder:(NSString *)placeholder blk:(void (^)(UITextField *))blk {
    [self alertControllerWithTitle:title message:message content:content placeholder:placeholder keyboardType:UIKeyboardTypeDefault blk:blk];
}

- (void)alertControllerWithTitle:(NSString *)title message:(NSString *)message content:(NSString *)content placeholder:(NSString *)placeholder keyboardType:(UIKeyboardType)keyboardType blk:(void (^)(UITextField *))blk  {
    UIAlertController *alertController = ({
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:title
                                    message:message
                                    preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDestructive
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    if (blk) {
                                                        blk(alert.textFields.firstObject);
                                                    }
                                                }]];

        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = placeholder;
            textField.text = content;
            textField.keyboardType = keyboardType;
        }];

        alert;
    });

    [self presentViewController:alertController animated:YES completion:nil];
}

@end
