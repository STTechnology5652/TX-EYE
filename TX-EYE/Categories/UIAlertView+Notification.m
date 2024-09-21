//
//  UIAlertView+Notification.m
//  TX-EYE
//
//  Created by CoreCat on 2017/11/9.
//  Copyright © 2017年 CoreCat. All rights reserved.
//

#import "UIAlertView+Notification.h"

@implementation UIAlertView (Notification)

+ (void)showAlertDialogWithTitle:(NSString *)title message:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    });
}

@end
