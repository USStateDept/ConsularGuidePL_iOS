//
//  ContentPageCategoryItemView.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/7/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageCategoryItemView.h"

@implementation ContentPageCategoryItemView

- (id)initWithFrame:(CGRect)frame delegate:(id<ContentPageButtonDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = delegate;
    }
    return self;
}

- (void)setPageToOpenString:(NSString *)pageToOpenString {
    if (_pageToOpenString == nil && pageToOpenString != nil) {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
        [self addGestureRecognizer:recognizer];
    }
    else if (pageToOpenString == nil) {
        for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
            [self removeGestureRecognizer:recognizer];
        }
    }
    _pageToOpenString = [pageToOpenString copy];
    
}

- (void)didTap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(openPageWithString:)] && self.pageToOpenString) {
        [self.delegate openPageWithString:self.pageToOpenString];
    }
}

@end
