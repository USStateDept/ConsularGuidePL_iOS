//
//  ContentPageInfoShortView.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/16/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageInfoContentView.h"

@implementation ContentPageInfoContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width - 44, frame.size.height);
    }
    return self;
}

@end
