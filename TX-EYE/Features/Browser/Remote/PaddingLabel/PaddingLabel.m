//
//  PaddingLabel.m
//  GoTrack
//
//  Created by CoreCat on 2019/1/21.
//  Copyright © 2019年 CoreCat. All rights reserved.
//

#import "PaddingLabel.h"

@implementation PaddingLabel

@synthesize edgeInsets;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [super intrinsicContentSize];
    size.width += self.edgeInsets.left + self.edgeInsets.right;
    size.height += self.edgeInsets.top + self.edgeInsets.bottom;
    return size;
}

@end
