//
//  ContentPageUnorderedListItemView.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/7/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageUnorderedListItemView.h"

@implementation ContentPageUnorderedListItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.leftSubviewOffset = 16;
        UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(0, 7, 5, 5)];
        dotView.layer.cornerRadius = 2.5f;
        dotView.backgroundColor = [UIColor blackColor];
        [self addSubview:dotView];
    }
    return self;
}

@end
