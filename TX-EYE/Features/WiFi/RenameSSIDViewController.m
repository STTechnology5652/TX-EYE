//
//  RenameSSIDViewController.m
//  TX-EYE
//
//  Created by CoreCat on 2016/10/28.
//  Copyright © 2016年 CoreCat. All rights reserved.
//

#import "RenameSSIDViewController.h"
#import "BWSocket.h"
#import "SVProgressHUD.h"

typedef NS_OPTIONS(NSInteger, WirelessAction) {
    WirelessActionIdle,
    WirelessActionProcessing,
    WirelessActionGetSSID,
    WirelessActionSetSSID,
    WirelessActionReset,
};

@interface RenameSSIDViewController () <BWSocketDelegate, UITextFieldDelegate>
{
    CGFloat _theNewSSIDTextFieldOriginY;
}
@property (nonatomic, strong) BWSocket *asyncSocket;
@property (weak, nonatomic) IBOutlet UITextField *currentSSIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *theNewSSIDTextField;
@property (weak, nonatomic) IBOutlet UILabel *currentSSIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *theNewSSIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@end

@implementation RenameSSIDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // Title
    self.title = NSLocalizedString(@"RENAME_VC_TITLE", @"Rename VC title");
    
    // Navigation Bar
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                target:self
                                                                                action:@selector(tapCancel:)];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                 target:self
                                                                                 action:@selector(tapSave:)];
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // AsyncSocket
    _asyncSocket = [BWSocket sharedSocket];
    _asyncSocket.delegate = self;
    
    // HUD Style
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    // Register Notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    _theNewSSIDTextFieldOriginY = _theNewSSIDTextField.frame.origin.y;
    
    // Init getting information
    self.navigationItem.leftBarButtonItem.enabled = NO;
    _theNewSSIDTextField.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSError *error = nil;
    if (_asyncSocket.isDisconnected) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"RENAME_HUD_INFO_CONNECTING_TO_BOARD", @"Rename HUD INFO connecting to board")];
        
        if (![_asyncSocket connectToHostwithError:&error]) {
            NSLog(@"Error occurred when connect to host: %@", error);
            self.navigationItem.leftBarButtonItem.enabled = YES;
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"RENAME_HUD_ERROR_CONNECT_TO_BOARD", @"Rename HUD ERROR connect to board")];
        }
    } else {
        _theNewSSIDTextField.enabled = YES;
        [SVProgressHUD showWithStatus:NSLocalizedString(@"RENAME_HUD_INFO_COLLECTING_INFORMATION", @"Rename HUD INFO collecting information")];
        [_asyncSocket getInfo];
    }
}

- (void)dealloc
{
    if ([_asyncSocket isConnected]) {
        [_asyncSocket disconnect];
    }
}

#pragma mark - BWSocketDelegate

- (void)socketDidConnect:(BWSocket *)sock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _theNewSSIDTextField.enabled = YES;
    });
    [SVProgressHUD showWithStatus:NSLocalizedString(@"RENAME_HUD_INFO_COLLECTING_INFORMATION", @"Rename HUD INFO collecting information")];
    [_asyncSocket getInfo];
}

- (void)socketDidDisconnect:(BWSocket *)sock withError:(NSError *)err
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.leftBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem.enabled = NO;
    });
    
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"RENAME_HUD_ERROR_ERROR_OCCURRED", @"Rename HUD ERROR error occurred")];
    [SVProgressHUD dismissWithDelay:2.0];
}

- (void)socket:(BWSocket *)sock didGetInformation:(NSDictionary *)info withAction:(SocketAction)action
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.leftBarButtonItem.enabled = YES;
    });
    
    NSString *methodString = info[kKeyMethod];
    
    switch (action) {
        case SocketActionGetInfo:
        {
            BOOL got = NO;
            [SVProgressHUD dismiss];
            if ([methodString isEqualToString:kCommandGetInfo]) {
                NSString *ssidString = info[kKeySSID];
                if (ssidString != nil) {
                    got = YES;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _currentSSIDTextField.text = ssidString;
                        // 测试使用
//                        _noticeLabel.numberOfLines = 0;
//                        _noticeLabel.text = [NSString stringWithFormat:@"%@", info];
                    });
                }
            }
            if (!got) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"RENAME_HUD_ERROR_GET_INFO", @"Rename HUD ERROR get info")];
            }
        }
            break;
        case SocketActionSetSSID:
        {
            BOOL set = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationItem.rightBarButtonItem.enabled = YES;
            });
            if ([methodString isEqualToString:kCommandSetSSID]) {
                NSString *statusCodeString = info[kKeyStatusCode];
                NSString *ssidString = info[kKeySSID];
                if ([statusCodeString isEqualToString:@"200"]) {
                    [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"RENAME_HUD_INFO_APPLY_SUCCESSFULLY", @"Rename HUD INFO apply successfully")];
                    [SVProgressHUD dismissWithDelay:2.0];
                    if (ssidString != nil) {
                        set = YES;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            _currentSSIDTextField.text = ssidString;
                            
                            // 相同名称则禁用保存
                            if ([_theNewSSIDTextField.text isEqualToString:_currentSSIDTextField.text]) {
                                self.navigationItem.rightBarButtonItem.enabled = NO;
                            }
                            
                            /* ---- 因为现在硬件那边Reset方案有困难，所以先使用手动Reset ---- */
                            NSString *title = NSLocalizedString(@"RENAME_NOTICE_TITLE", @"Rename NOTICE title");
                            NSString *message = NSLocalizedString(@"RENAME_NOTICE_MESSAGE", @"Rename NOTICE message");
                            NSString *buttonTitle = NSLocalizedString(@"RENAME_NOTICE_BUTTON_TITLE", @"Rename NOTICE button title");
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                                message:message
                                                                               delegate:nil
                                                                      cancelButtonTitle:buttonTitle
                                                                      otherButtonTitles:nil];
                            [alertView show];
                            
//                            // Reset board after setting SSID
//                            [_asyncSocket resetBoard];
                        });
                    }
                }
            }
            if (!set) {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"RENAME_HUD_ERROR_SET_SSID", @"Rename HUD ERROR set SSID")];
            }
        }
            break;
        case SocketActionSetPassword:
        {
            if ([methodString isEqualToString:kCommandSetPassword]) {
                //
            }
        }
            break;
        case SocketActionResetBoard:
        {
            if ([methodString isEqualToString:kCommandResetNet]) {
                // Alert to open WiFi settings page
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *title = NSLocalizedString(@"RENAME_ALERT_TITLE", @"Rename ALERT title");
                    NSString *message = NSLocalizedString(@"RENAME_ALERT_MESSAGE", @"Rename ALERT message");
                    NSString *buttonTitle = NSLocalizedString(@"RENAME_ALERT_BUTTON_TITLE", @"Rename ALERT button title");
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                        message:message
                                                                       delegate:nil
                                                              cancelButtonTitle:buttonTitle
                                                              otherButtonTitles:nil];
                    [alertView show];
                });
            } else {
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"RENAME_HUD_ERROR_RESET_BOARD", @"Rename HUD ERROR reset board")];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Filter the text input
    NSString *strRegex = @"[^A-Za-z0-9_]+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strRegex];
    if ([predicate evaluateWithObject:string])
        return NO;
    
    // Detect text length
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newString.length > 24)
        textField.textColor = [UIColor redColor];
    else
        textField.textColor = [UIColor darkTextColor];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Finish editing
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // Disable save button while editing new SSID
    self.navigationItem.rightBarButtonItem.enabled = NO;
    // 先dismiss SVProgressHUD
    [SVProgressHUD dismiss];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Detect text length
    if ([textField.text isEqualToString:@""] || textField.text.length > 24
        || [textField.text isEqualToString:_currentSSIDTextField.text]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        // 弹出重名提示
        if ([textField.text isEqualToString:_currentSSIDTextField.text]) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"RENAME_HUD_ALERT_CHANGE_ANOTHER_SSID", @"Rename HUD ALERT change another SSID")];
        }
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

#pragma mark - Button Actions

- (void)tapCancel:(id)sender
{
    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tapSave:(id)sender
{
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"RENAME_HUD_INFO_APPLYING_CHANGES", @"Rename HUD INFO applying changes")];
    [_asyncSocket setSSID:_theNewSSIDTextField.text];
}

#pragma mark - Keyboard Notification

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    UITextField *textField = _theNewSSIDTextField;
    
    CGFloat viewHeight = self.view.frame.size.height;
    CGFloat deltaHeight = viewHeight - kbSize.height;
    CGFloat textfieldY = (deltaHeight - textField.frame.size.height) / 2.0;
    if (textfieldY < 0) textfieldY = 0;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    textField.frame = CGRectMake(textField.frame.origin.x, textfieldY, textField.frame.size.width, textField.frame.size.height);
    
    _currentSSIDLabel.alpha = 0;
    _currentSSIDTextField.alpha = 0;
    _theNewSSIDLabel.alpha = 0;
    _noticeLabel.alpha = 0;
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationBeginsFromCurrentState:YES];
    UITextField *textField = _theNewSSIDTextField;
    textField.frame = CGRectMake(textField.frame.origin.x, _theNewSSIDTextFieldOriginY, textField.frame.size.width, textField.frame.size.height);
    
    _currentSSIDLabel.alpha = 1.0;
    _currentSSIDTextField.alpha = 1.0;
    _theNewSSIDLabel.alpha = 1.0;
    _noticeLabel.alpha = 1.0;
    
    [UIView commitAnimations];
}

@end
