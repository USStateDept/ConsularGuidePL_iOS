//
//  AGIPdfInfoTableHeaderFooterView.m
//  usmissionpoland
//
//  Created by Paweł Nowosad on 13.12.2013.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import "AGIPdfInfoTableHeaderFooterView.h"
#import "AGIDocumentsTableHeaderView.h"

@implementation AGIPdfInfoTableHeaderFooterView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self)
    {
        NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"AGIPdfInfoTableHeaderFooterView" owner:self options:nil];
        UIView *nibView = [nibViews firstObject];
        nibView.frame = (CGRect){ .origin = nibView.frame.origin, .size = CGSizeMake(nibView.frame.size.width, [AGIDocumentsTableHeaderView defaultViewHeight]) };
        UIView *contentView = self.contentView;
        [contentView addSubview:nibView];
    }
    
    return self;
}

@end
