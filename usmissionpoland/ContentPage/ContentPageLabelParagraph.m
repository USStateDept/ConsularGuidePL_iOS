//
//  ContentPageLabelParagraph.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/2/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageLabelParagraph.h"

@implementation ContentPageLabelParagraph

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:15.5f];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

@end
