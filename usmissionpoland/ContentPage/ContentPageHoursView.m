//
//  ContentPageHoursView.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/7/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageHoursView.h"

@implementation ContentPageHoursView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.leftSubviewOffset = 30;
        UIImageView *clockIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clockIcon.png"]];
        clockIcon.frame = CGRectMake(0, 0, 24, 24.5);
        [self addSubview:clockIcon];
    }
    return self;
}

@end
