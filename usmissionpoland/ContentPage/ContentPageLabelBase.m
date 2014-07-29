//
//  ContentPageLabelBase.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/2/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageLabelBase.h"

@implementation ContentPageLabelBase

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.numberOfLines = 0;
        self.lineBreakMode = NSLineBreakByTruncatingTail;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
