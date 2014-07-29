//
//  ContentPageMailView.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/8/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageMailView.h"

@implementation ContentPageMailView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.leftSubviewOffset = 30;
        UIButton *mailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        mailButton.backgroundColor = [UIColor clearColor];
        [mailButton setBackgroundImage:[UIImage imageNamed:@"mailIcon.png"] forState:UIControlStateNormal];
        [mailButton addTarget:self action:@selector(sendMail) forControlEvents:UIControlEventTouchUpInside];
        mailButton.frame = CGRectMake(0, 0, 24, 24);
        [self addSubview:mailButton];
    }
    return self;
}

- (void)sendMail {
    if (self.mailAdress) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", self.mailAdress]]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", self.mailAdress]]];
        }
    }
}

@end
