//
//  ContentPageInfoView.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/16/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageInfoView.h"
#import "ContentPageInfoDetailView.h"

@implementation ContentPageInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.leftSubviewOffset = 10;
        
        self.backgroundColor = [UIColor colorWithRed:1 green:0.97f blue:0.85f alpha:1];
        
        self.layer.borderColor = [UIColor colorWithRed:1 green:0.8f blue:0.15f alpha:1].CGColor;
        self.layer.borderWidth = 1;
        
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [infoButton addTarget:self action:@selector(didTapButton) forControlEvents:UIControlEventTouchUpInside];
        [infoButton setImage:[UIImage imageNamed:@"infoBox.png"] forState:UIControlStateNormal];
        infoButton.frame = CGRectMake(frame.size.width - 44, 10, 32, 32);
        self.button = infoButton;
        
        [self addSubview:infoButton];
    }
    return self;
}

- (void)didTapButton {
    self.infoDetailView.hidden = NO;
    [self.infoDetailView.superview bringSubviewToFront:self.infoDetailView];
    UIButton *overlay = [UIButton buttonWithType:UIButtonTypeCustom];
    overlay.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6f];
    [overlay addTarget:self action:@selector(didTapOverlay:) forControlEvents:UIControlEventTouchUpInside];
    overlay.frame = self.infoDetailView.superview.bounds;
    [self.infoDetailView.superview insertSubview:overlay belowSubview:self.infoDetailView];
    
    self.infoDetailView.shadowOverlay = overlay;
}

- (void)didTapOverlay:(id)sender {
    UIButton *overlay = (UIButton*)sender;
    [overlay removeFromSuperview];
    self.infoDetailView.hidden = YES;
}

@end
