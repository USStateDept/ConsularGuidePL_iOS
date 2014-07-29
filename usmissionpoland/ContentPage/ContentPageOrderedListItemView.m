//
//  ContentPageOrderedListItemView.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/7/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageOrderedListItemView.h"

@implementation ContentPageOrderedListItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame index:0];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithIndex:(NSInteger)index {
    return [self initWithFrame:CGRectZero index:index];
}

- (id)initWithFrame:(CGRect)frame index:(NSInteger)index {
    self = [super initWithFrame:frame];
    if (self) {
        self.leftSubviewOffset = 25;
        UILabel *indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        indexLabel.textAlignment = NSTextAlignmentLeft;
        indexLabel.text = [NSString stringWithFormat:@"%ld.", (long)index];
        indexLabel.textColor = [UIColor blackColor];
        indexLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:15];
        indexLabel.frame = CGRectMake(0, 0, 30, ceilf([indexLabel.text sizeWithFont:indexLabel.font constrainedToSize:CGSizeMake(25, 30)].height));
        [self addSubview:indexLabel];
    }
    return self;
}

@end
