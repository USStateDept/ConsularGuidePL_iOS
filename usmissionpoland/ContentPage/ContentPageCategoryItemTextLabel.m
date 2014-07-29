//
//  ContentPageCategoryItemTextLabel.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/7/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageCategoryItemTextLabel.h"

@implementation ContentPageCategoryItemTextLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:14];
    }
    return self;
}

@end
