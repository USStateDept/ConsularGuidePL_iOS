//
//  NSArray+LayoutConstraints.m
//  usmissionpoland
//
//  Created by Paweł Nowosad on 26.02.2014.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "NSArray+LayoutConstraints.h"

@implementation NSArray (LayoutConstraints)

- (void)updateLayoutConstraintsWithConstant:(CGFloat)constant
{
    for (NSLayoutConstraint *constraint in self)
    {
        [constraint setConstant:constant];
    }
}

@end
