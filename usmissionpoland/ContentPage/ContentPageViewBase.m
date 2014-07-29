//
//  ContentPageViewBase.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/2/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageViewBase.h"

@implementation ContentPageViewBase

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.leftSubviewOffset = 0;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
