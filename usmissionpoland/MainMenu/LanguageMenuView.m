//
//  LanguageMenuView.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 12/12/13.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import "LanguageMenuView.h"
#import "AppDelegate.h"
#import "FeedbackViewController.h"
#import "HomePageViewController.h"
#import "CustomNavigationController.h"

@implementation LanguageMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self initLanguageEnglishButton];
        [self initLanguagePolishButton];
        
        UIView *separatorLine = [[UIView alloc] init];
        separatorLine.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2f];
        [self addSubview:separatorLine];
        self.separatorLine = separatorLine;
        
        UIButton *feedBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [feedBackButton addTarget:self action:@selector(openFeedback) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:feedBackButton];
        self.feedbackButton = feedBackButton;
        
        BilingualLabel *feedbackLabel = [[BilingualLabel alloc] initWithTextEnglish:@"Feedback" polish:@"Opinia"];
        feedbackLabel.backgroundColor = [UIColor clearColor];
        feedbackLabel.textColor = [UIColor whiteColor];
        feedbackLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:16];
        feedbackLabel.textAlignment = NSTextAlignmentRight;
        [self.feedbackButton addSubview:feedbackLabel];
        self.feedbackLabel = feedbackLabel;
        
        UIImageView *feedbackIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_feedback_36x24.png"]];
        feedbackIcon.frame = CGRectMake(0, 0, 18, 12);
        feedbackIcon.alpha = 0.7f;
        [self.feedbackButton addSubview:feedbackIcon];
        self.feedbackIcon = feedbackIcon;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeLanguage:) name:POST_NOTIFICATION_SWITCH_LANGUAGE object:nil];
        
        self.backgroundColor = [UIColor colorWithRed:0.12f green:0.22f blue:0.38f alpha:1];
        [self setFrame:frame];
    }
    return self;
}

- (void)initLanguageEnglishButton {
    UIButton *languageEnglishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [languageEnglishButton setTitle:@"EN" forState:UIControlStateNormal];
    [languageEnglishButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.3f] forState:UIControlStateNormal];
    [languageEnglishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    languageEnglishButton.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:16];
    languageEnglishButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguageEnglish) {
        languageEnglishButton.selected = YES;
    }
    [languageEnglishButton addTarget:self action:@selector(didTapLanguageEnglishButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:languageEnglishButton];
    _languageEnglishButton = languageEnglishButton;
}

- (void)initLanguagePolishButton {
    UIButton *languagePolishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [languagePolishButton setTitle:@"PL" forState:UIControlStateNormal];
    [languagePolishButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.3f] forState:UIControlStateNormal];
    [languagePolishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    languagePolishButton.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:16];
    languagePolishButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
        languagePolishButton.selected = YES;
    }
    [languagePolishButton addTarget:self action:@selector(didTapLanguagePolishButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:languagePolishButton];
    _languagePolishButton = languagePolishButton;
}

- (void)layoutSubviews {
    self.languageEnglishButton.frame = CGRectMake(2, 2, self.bounds.size.height - 4, self.bounds.size.height - 4);
    self.languagePolishButton.frame = CGRectMake(self.bounds.size.height + 4, 2, self.bounds.size.height - 4, self.bounds.size.height - 4);
    
    self.feedbackLabel.frame = CGRectMake(0, 0, ceilf([@"FEEDBACK" sizeWithFont:self.feedbackLabel.font constrainedToSize:CGSizeMake(self.frame.size.width / 2 - 20 - self.feedbackIcon.frame.size.width, self.frame.size.height) lineBreakMode:NSLineBreakByWordWrapping].width), self.frame.size.height);
    self.feedbackButton.frame = CGRectMake(self.frame.size.width - 20 - self.feedbackIcon.frame.size.width - self.feedbackLabel.frame.size.width, 0, self.feedbackLabel.frame.size.width + self.feedbackIcon.frame.size.width + 10, self.frame.size.height);
    self.feedbackIcon.frame = CGRectMake(self.feedbackButton.frame.size.width - self.feedbackIcon.frame.size.width, (self.frame.size.height - self.feedbackIcon.frame.size.height) /2.0f - 1, self.feedbackIcon.frame.size.width, self.feedbackIcon.frame.size.height);
    
    self.separatorLine.frame = CGRectMake((self.languageEnglishButton.frame.origin.x + self.languageEnglishButton.frame.size.width + self.languagePolishButton.frame.origin.x)/2, 0, 1, self.frame.size.height);
}

- (void)didChangeLanguage:(NSNotification*)notification {
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
        self.languageEnglishButton.selected = NO;
        self.languagePolishButton.selected = YES;
    }
    else {
        self.languageEnglishButton.selected = YES;
        self.languagePolishButton.selected = NO;
    }
}

- (void)didTapLanguageEnglishButton {
    if (!self.languageEnglishButton.selected) {
        [[LanguageSettings sharedSettings] setLanguage:LanguageEnglish];
    }
}

- (void)didTapLanguagePolishButton {
    if (!self.languagePolishButton.selected) {
        [[LanguageSettings sharedSettings] setLanguage:LanguagePolish];
    }
}

- (void)openFeedback {
    FeedbackViewController *feedbackVc;
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    HomePageViewController *homeVc = appDelegate.navController.viewControllers.firstObject;
    
    BaseViewController *topVc = appDelegate.navController.viewControllers.lastObject;
    if (topVc.page != nil) {
        feedbackVc = [[FeedbackViewController alloc] initWithPageId:[topVc.page.pageId integerValue]];
    }
    else if (topVc.class == [HomePageViewController class]) {
        if (homeVc.embeddedViewControllersArray.count != 0) {
            BaseViewController *topEmbeddedVc = homeVc.embeddedViewControllersArray.lastObject;
            
            feedbackVc = [[FeedbackViewController alloc] initWithPageId:[topEmbeddedVc.page.pageId integerValue]];
        }
        else {
            feedbackVc = [[FeedbackViewController alloc] initWithPageId:0];
        }
    }
    else {
        feedbackVc = [[FeedbackViewController alloc] initWithPageId:0];
    }
    
    if (UIInterfaceOrientationIsPortrait(homeVc.interfaceOrientation)) {
        [homeVc.navigationController pushViewController:feedbackVc animated:YES];
    }
    else {
        if (!homeVc.embeddedNavController) {
            [homeVc createEmbeddedNavController];
        }
        
        [homeVc didTapRightBarButton];
        [homeVc.embeddedNavController pushViewController:feedbackVc animated:YES];
    }
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
