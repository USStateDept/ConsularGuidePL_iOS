//
//  ContentPageInfoDetailContentView.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/16/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageInfoDetailContentView.h"

@implementation ContentPageInfoDetailContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        scrollView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
        [super addSubview:scrollView];
        self.scrollView = scrollView;
    }
    return self;
}

- (void)addSubview:(UIView *)view {
    [self.scrollView addSubview:view];
}

@end
