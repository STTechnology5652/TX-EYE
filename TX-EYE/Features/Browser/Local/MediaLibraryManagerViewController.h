//
//  MediaLibraryManagerViewController.h
//  TX-EYE
//
//  Created by CoreCat on 16/1/27.
//  Copyright © 2016年 CoreCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaLibraryManagerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *listItems;

- (void)requestPhotoAccessAuthorization:(void (^)(BOOL success))handler;

@end
