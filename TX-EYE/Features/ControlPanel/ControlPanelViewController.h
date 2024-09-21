//
//  ControlPanelViewController.h
//  TX-EYE
//
//  Created by CoreCat on 16/1/13.
//  Copyright © 2016年 CoreCat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IJKMediaFramework/IJKMediaFramework.h>

@interface ControlPanelViewController : UIViewController

@property(atomic,strong) NSURL *url;
@property(atomic, retain) id<IJKMediaPlayback> player;

- (id)initWithURL:(NSURL *)url;

+ (void)presentFromViewController:(UIViewController *)viewController withTitle:(NSString *)title URL:(NSURL *)url completion:(void(^)())completion;

@end
