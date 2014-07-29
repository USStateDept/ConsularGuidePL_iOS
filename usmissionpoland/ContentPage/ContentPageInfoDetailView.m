//
//  ContentPageInfoDetailView.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/16/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageInfoDetailView.h"

@implementation ContentPageInfoDetailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self.button setImage:[UIImage imageNamed:@"crossIconYellow.png"] forState:UIControlStateNormal];
        
    }
    return self;
}

- (void)didTapButton {
    self.hidden = YES;
    [self.shadowOverlay removeFromSuperview];
    self.shadowOverlay = nil;
}

@end
