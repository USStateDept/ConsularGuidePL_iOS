//
//  MainPageCell.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 2/26/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "MainPageCell.h"

@implementation MainPageCell

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentFrame = self.contentView.frame, textFrame = self.textLabel.frame, accessoryFrame = self.accessoryView.frame;
    contentFrame.size.width = self.contentWidth - 24;
    self.contentView.frame = contentFrame;
    self.textLabel.frame = CGRectMake(10, textFrame.origin.y, self.contentWidth - 34, textFrame.size.height);
    accessoryFrame.origin.x = self.contentWidth - 24;
    self.accessoryView.frame = accessoryFrame;
    
}
@end
