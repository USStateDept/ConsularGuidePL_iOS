//
//  DetailPageCell.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 3/5/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "DetailPageCell.h"

@implementation DetailPageCell

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.accessoryView) {
        CGRect textFrame = self.textLabel.frame;
        textFrame.size.width -= 20;
        self.textLabel.frame = textFrame;
    }
    
}

@end
