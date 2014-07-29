//
//  QAView.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/17/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "QAView.h"

@implementation QAView

- (id)initWithFrame:(CGRect)frame question:(NSString *)question answer:(NSString *)answer buttonDelegate:(id<ContentPageButtonDelegate>)buttonDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 1)];
        line.backgroundColor = [UIColor grayColor];
        [self addSubview:line];
        
        UILabel *questionLabel = [[UILabel alloc] init];
        questionLabel.text = question;
        questionLabel.numberOfLines = 0;
        questionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        questionLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:16];
        questionLabel.textColor = CustomUSAppBlueColor;
        
        questionLabel.frame = CGRectMake(15, 10, frame.size.width - 60, ceilf([question sizeWithFont:questionLabel.font constrainedToSize:CGSizeMake(frame.size.width - 60, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height));
        if (questionLabel.frame.size.height < 6) {
            CGRect questionFrame = questionLabel.frame;
            questionFrame.size.height = 6;
            questionLabel.frame = questionFrame;
        }
        [self addSubview:questionLabel];
        self.questionLabel = questionLabel;
        
        CGRect answerRect = CGRectMake(15, CGRectGetMaxY(questionLabel.frame) + 10, frame.size.width - 45, 1000);
        AdditionalContentViewController *answerViewVc = [[AdditionalContentViewController alloc] initWithFrame:answerRect contentEN:answer contentPL:answer buttonDelegate:buttonDelegate];
        [self addSubview:answerViewVc.view];
        [answerViewVc.separatorLine removeFromSuperview];
        answerViewVc.separatorLine = nil;
        answerRect.size.height = answerViewVc.scrollView.contentSize.height + 8;
        answerViewVc.view.frame = answerRect;
        answerViewVc.scrollView.frame = CGRectMake(answerViewVc.scrollView.frame.origin.x, answerViewVc.scrollView.frame.origin.y, answerViewVc.scrollView.contentSize.width, answerViewVc.scrollView.contentSize.height);
        answerViewVc.view.hidden = YES;
        self.answerView = answerViewVc.view;
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rightArrowBlack.png"]];
        arrowImageView.frame = CGRectMake(frame.size.width - 35, 10, 16, 16);
        
        [self addSubview:arrowImageView];
        self.arrowImageView = arrowImageView;
        
        [self addTarget:self action:@selector(switchState) forControlEvents:UIControlEventTouchUpInside];
        
        self.layer.masksToBounds = YES;
    }
    return self;
}

/** Called when tapped */
- (void)switchState {
    if (self.answerView.hidden == YES) {
        self.answerView.hidden = NO;
        self.questionLabel.textColor = [UIColor blackColor];
        self.questionLabel.frame = CGRectMake(15, 10, self.frame.size.width - 45, ceilf([self.questionLabel.text sizeWithFont:self.questionLabel.font constrainedToSize:CGSizeMake(self.frame.size.width - 45, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height));
        if (self.questionLabel.frame.size.height < 6) {
            CGRect questionFrame = self.questionLabel.frame;
            questionFrame.size.height = 6;
            self.questionLabel.frame = questionFrame;
        }
        self.answerView.frame = CGRectMake(self.answerView.frame.origin.x, CGRectGetMaxY(self.questionLabel.frame) + 10, self.answerView.frame.size.width, self.answerView.frame.size.height);
        self.arrowImageView.image = [UIImage imageNamed:@"downArrowBlack.png"];
    }
    else {
        self.answerView.hidden = YES;
        self.questionLabel.textColor = CustomUSAppBlueColor;
        self.questionLabel.frame = CGRectMake(15, 10, self.frame.size.width - 45, ceilf([self.questionLabel.text sizeWithFont:self.questionLabel.font constrainedToSize:CGSizeMake(self.frame.size.width - 45, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height));
        if (self.questionLabel.frame.size.height < 6) {
            CGRect questionFrame = self.questionLabel.frame;
            questionFrame.size.height = 6;
            self.questionLabel.frame = questionFrame;
        }
        self.answerView.frame = CGRectMake(self.answerView.frame.origin.x, CGRectGetMaxY(self.questionLabel.frame) + 10, self.answerView.frame.size.width, self.answerView.frame.size.height);
        self.arrowImageView.image = [UIImage imageNamed:@"rightArrowBlack.png"];
    }
}

@end
