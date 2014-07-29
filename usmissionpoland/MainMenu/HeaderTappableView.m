//
//  HeaderTappableView.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 2/28/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "HeaderTappableView.h"

@implementation HeaderTappableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.headerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapHeader)];
        [self addGestureRecognizer:self.headerTapRecognizer];
    }
    return self;
}

- (void)didTapHeader {
    [self.delegate didTapHeaderInSection:self.section];
}

@end
