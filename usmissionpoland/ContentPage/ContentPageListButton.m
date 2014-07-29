//
//  ContentPageListButton.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/17/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageListButton.h"

@implementation ContentPageListButton

- (id)initWithFrame:(CGRect)frame page:(Page *)page
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.page = page;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 1)];
        line.backgroundColor = [UIColor grayColor];
        line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:line];
        
        UILabel *label = [[UILabel alloc] init];
        if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
            label.text = page.titlePL;
        }
        else {
            label.text = page.titleEN;
        }
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:18];
        label.textColor = CustomUSAppBlueColor;
        
        label.frame = CGRectMake(-self.frame.origin.x + 10, 10, frame.size.width - 80, ceilf([label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(frame.size.width - 80, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height));
        [self addSubview:label];
        self.label = label;
        
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rightArrowBlack.png"]];
        arrowImageView.frame = CGRectMake(frame.size.width - 35, self.frame.size.height/2 - 8, 16, 16);
        arrowImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        
        [self addSubview:arrowImageView];
        self.arrowImageView = arrowImageView;
    }
    return self;
}

@end
