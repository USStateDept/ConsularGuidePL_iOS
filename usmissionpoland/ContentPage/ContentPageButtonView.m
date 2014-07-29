//
//  ContentPageButtonView.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/17/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageButtonView.h"

@implementation ContentPageButtonView

- (id)initWithFrame:(CGRect)frame urlString:(NSString*)urlString
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.urlToOpen = [NSURL URLWithString:urlString];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = self.bounds;
        button.layer.borderColor = CustomUSAppBlueColor.CGColor;
        button.layer.borderWidth = 1;
        button.backgroundColor = [UIColor whiteColor];
        [button addTarget:self action:@selector(didTapButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        self.button = button;
        
        UILabel *label = [[UILabel alloc] init];
        CGRect labelFrame = self.bounds;
        label.backgroundColor = [UIColor clearColor];
        labelFrame.size.width = self.frame.size.width - 57;
        labelFrame.origin.x = 11;
        label.frame = labelFrame;
        label.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:18];
        label.textColor = CustomUSAppBlueColor;
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        [self.button addSubview:label];
        self.label = label;
        
        UIImageView * internetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button-InternetIcon.png"]];
        internetImageView.frame = CGRectMake(ceilf(self.frame.size.width - 35), 0, 24, 24);
        internetImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:internetImageView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame pageString:(NSString *)pageString delegate:(id)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.pageToOpenString = pageString;
        self.delegate = delegate;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect buttonFrame = self.bounds;
        buttonFrame.size.height = self.frame.size.width - 57;
        buttonFrame.origin.x = 11;
        button.frame = buttonFrame;
        button.layer.borderColor = CustomUSAppBlueColor.CGColor;
        button.layer.borderWidth = 1;
        button.backgroundColor = CustomUSAppBlueColor;
        [button addTarget:self action:@selector(didTapButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        self.button = button;
        
        UILabel *label = [[UILabel alloc] init];
        CGRect labelFrame = self.bounds;
        label.backgroundColor = [UIColor clearColor];
        labelFrame.size.width = self.frame.size.width - 57;
        labelFrame.origin.x = 11;
        label.frame = labelFrame;
        label.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:18];
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        [self.button addSubview:label];
        self.label = label;
        
        UIImageView * arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rightArrowWhite.png"]];
        arrowImageView.frame = CGRectMake(ceilf(self.frame.size.width - 28), ceilf(self.bounds.size.height/2 - 8), 9, 16);
        arrowImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:arrowImageView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.button.frame = self.bounds;
    self.label.frame = CGRectMake(10, 10, self.button.frame.size.width - 57, self.button.frame.size.height - 20);
}

- (void)didTapButton {
    if (self.urlToOpen) {
        if ([[UIApplication sharedApplication] canOpenURL:self.urlToOpen]) {
            [[UIApplication sharedApplication] openURL:self.urlToOpen];
        }
    }
    else if (self.pageToOpenString && [self.delegate respondsToSelector:@selector(openPageWithString:)]) {
        [self.delegate openPageWithString:self.pageToOpenString];
    }
}

- (UIFont*)font {
    return self.label.font;
}

- (void)setFont:(UIFont*)font {
    [self.label setFont:font];
}

@end
