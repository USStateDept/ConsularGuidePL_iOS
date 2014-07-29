//
//  ContentPageCategoryItemNameLabel.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/7/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageCategoryItemNameLabel.h"

@implementation ContentPageCategoryItemNameLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:15];
        self.backgroundColor = [UIColor colorWithWhite:0.93f alpha:1];
        self.numberOfLines = 2;
        self.lineBreakMode = NSLineBreakByCharWrapping;
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

@end
