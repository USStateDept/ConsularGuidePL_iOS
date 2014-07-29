//
//  MainMenuAlertView.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/21/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "MainMenuAlertView.h"
#import "MainMenuAlert.h"

@implementation MainMenuAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.masksToBounds = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:POST_NOTIFICATION_SHOW_ALERT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsLayout) name:POST_NOTIFICATION_SWITCH_LANGUAGE object:nil];
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:backgroundImageView];
        self.backgroundImageView = backgroundImageView;
        
        MainMenuAlert *alert = [MainMenuAlert alert];
        
        if (alert == nil || [MainMenuAlert alert].isEnabled == NO) {
            self.hidden = YES;
        }
        
        NSString *backgroundTextEn;
        NSString *backgroundTextPl;
        
        backgroundTextEn = [self backgroundTextForTitle:alert.titleEn];
        backgroundTextPl = [self backgroundTextForTitle:alert.titlePl];
        
        BilingualLabel *backgroundLabel = [[BilingualLabel alloc] initWithTextEnglish:backgroundTextEn polish:backgroundTextPl];
        backgroundLabel.lineBreakMode = NSLineBreakByCharWrapping;
        backgroundLabel.textColor = [UIColor colorWithWhite:1 alpha:0.15f];
        [self addSubview:backgroundLabel];
        self.backgroundLabel = backgroundLabel;
        
        
        BilingualLabel *titleLabel = [[BilingualLabel alloc] initWithTextEnglish:alert.titleEn polish:alert.titlePl];
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.numberOfLines = 0;
        titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        
        BilingualLabel *descriptionLabel = [[BilingualLabel alloc] initWithTextEnglish:alert.descriptionEn polish:alert.descriptionPl];
        descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.textColor = [UIColor whiteColor];
        [self addSubview:descriptionLabel];
        self.descriptionLabel = descriptionLabel;
        
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        self.closeButton = closeButton;
        
        UIImageView *closeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"crossIcon.png"]];
        [closeButton addSubview:closeImageView];
        self.closeImageView = closeImageView;
        
        BilingualLabel *alertTypeLabel = [[BilingualLabel alloc] init];
        if ([alert.type isEqualToString:@"emergency"]) {
            alertTypeLabel.textEN = @"Emergency";
            alertTypeLabel.textPL = @"Uwaga";
        }
        else if ([alert.type isEqualToString:@"sec_adv"]) {
            alertTypeLabel.textEN = @"Security Advisory";
            alertTypeLabel.textPL = @"Ostrzeżenie";
        }
        else if ([alert.type isEqualToString:@"calendar"]) {
            alertTypeLabel.textEN = @"Calendar Update";
            alertTypeLabel.textPL = @"Kalendarz";
        }
        else if ([alert.type isEqualToString:@"media"]) {
            alertTypeLabel.textEN = @"New Media Release";
            alertTypeLabel.textPL = @"Aktualności";
        }
        else if ([alert.type isEqualToString:@"general"]) {
            alertTypeLabel.textEN = @"General Update";
            alertTypeLabel.textPL = @"Nowość";
        }
        
        alertTypeLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2f];
        alertTypeLabel.textColor = [UIColor whiteColor];
        alertTypeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:alertTypeLabel];
        self.alertTypeLabel = alertTypeLabel;
        
        self.backgroundLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:30]; //initial values, size will change
        self.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:22]; //when layoutSubviews is called
        self.descriptionLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:14];
        
        
        [self setCorrectImage];
    }
    return self;
}

- (void)show {
    
    MainMenuAlert *alert = [MainMenuAlert alert];
    
    
    NSString *backgroundTextEn;
    NSString *backgroundTextPl;
    
    backgroundTextEn = [self backgroundTextForTitle:alert.titleEn];
    backgroundTextPl = [self backgroundTextForTitle:alert.titlePl];
    
    self.backgroundLabel.textEN = backgroundTextEn;
    self.backgroundLabel.textPL = backgroundTextPl;
    
    self.titleLabel.textEN = alert.titleEn;
    self.titleLabel.textPL = alert.titlePl;
    
    self.descriptionLabel.textEN = alert.descriptionEn;
    self.descriptionLabel.textPL = alert.descriptionPl;
    
    if ([alert.type isEqualToString:@"emergency"]) {
        self.alertTypeLabel.textEN = @"Emergency";
        self.alertTypeLabel.textPL = @"Uwaga";
    }
    else if ([alert.type isEqualToString:@"sec_adv"]) {
        self.alertTypeLabel.textEN = @"Security Advisory";
        self.alertTypeLabel.textPL = @"Ostrzeżenie";
    }
    else if ([alert.type isEqualToString:@"calendar"]) {
        self.alertTypeLabel.textEN = @"Calendar Update";
        self.alertTypeLabel.textPL = @"Kalendarz";
    }
    else if ([alert.type isEqualToString:@"media"]) {
        self.alertTypeLabel.textEN = @"New Media Release";
        self.alertTypeLabel.textPL = @"Aktualności";
    }
    else if ([alert.type isEqualToString:@"general"]) {
        self.alertTypeLabel.textEN = @"General Update";
        self.alertTypeLabel.textPL = @"Nowość";
    }
    
    [self setCorrectImage];
    
    [self setNeedsLayout];
    
    self.hidden = NO;
    
}

- (void)hide {
    self.hidden = YES;
    [MainMenuAlert alert].isEnabled = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:POST_NOTIFICATION_DID_HIDE_ALERT object:nil];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
}

- (NSString*)backgroundTextForTitle:(NSString*)titleString {
    if (titleString.length >= 5) {
        return [titleString substringFromIndex:2];
    }
    else {
        return titleString;
    }
}

- (void)layoutSubviews {
    self.backgroundImageView.frame = self.bounds;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) { //layout for portrait phone
        self.closeButton.frame = CGRectMake(self.frame.size.width - 44, 0, 44, 44);
        self.closeImageView.frame = CGRectMake(0, self.closeButton.frame.size.height - 24, 24.5f, 24);
        
        self.backgroundLabel.frame = CGRectMake(-5, self.frame.size.height/10, self.frame.size.width*2, 80);
        self.backgroundLabel.font = [UIFont fontWithName:self.backgroundLabel.font.fontName size:50];
        
        self.titleLabel.frame = CGRectMake(15, self.frame.size.height/3, self.frame.size.width *0.75f - 15, 60);
        self.titleLabel.font = [UIFont fontWithName:self.titleLabel.font.fontName size:25];
        
        self.descriptionLabel.frame = CGRectMake(15, CGRectGetMaxY(self.titleLabel.frame) + 5, self.frame.size.width *0.75f - 15, self.frame.size.height - CGRectGetMaxY(self.titleLabel.frame) - 20);
        self.descriptionLabel.font = [UIFont fontWithName:self.descriptionLabel.font.fontName size:16];
        
        self.alertTypeLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:13];
        CGSize alertTypeSize = [self.alertTypeLabel.text sizeWithFont:self.alertTypeLabel.font constrainedToSize:CGSizeMake(self.frame.size.width - self.titleLabel.frame.origin.x, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        self.alertTypeLabel.frame = CGRectMake(0, 22, alertTypeSize.width + (self.titleLabel.frame.origin.x * 2), ceilf(alertTypeSize.height) + 4);
        
    }
    else if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) { //layout for iPad portrait
        self.backgroundLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:30];
        self.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:22];
        self.descriptionLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:14];
        
        self.closeButton.frame = CGRectMake(self.frame.size.width - 44, 0, 44, 44);
        self.closeImageView.frame = CGRectMake(0, self.closeButton.frame.size.height - 24, 24.5f, 24);

        
        self.backgroundLabel.frame = CGRectMake(-5, self.frame.size.height/10, self.frame.size.width*2, self.frame.size.height * 0.4f);
        self.backgroundLabel.font = [UIFont fontWithName:self.backgroundLabel.font.fontName size:self.backgroundLabel.frame.size.height * 0.8f];
        
        self.titleLabel.frame = CGRectMake(15, self.frame.size.height * 0.3f, self.frame.size.width *0.75f - 15, self.frame.size.height * 0.35f);
        self.titleLabel.font = [UIFont fontWithName:self.titleLabel.font.fontName size:self.titleLabel.frame.size.height * 0.35f];
        
        self.descriptionLabel.frame = CGRectMake(15, CGRectGetMaxY(self.titleLabel.frame) + 5, self.frame.size.width *0.75f - 15, self.frame.size.height - CGRectGetMaxY(self.titleLabel.frame) - 20);
        self.descriptionLabel.font = [UIFont fontWithName:self.descriptionLabel.font.fontName size:self.frame.size.height /20];
        
        self.alertTypeLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:self.descriptionLabel.font.pointSize * 0.8f];
        CGSize alertTypeSize = [self.alertTypeLabel.text sizeWithFont:self.alertTypeLabel.font constrainedToSize:CGSizeMake(self.frame.size.width - self.titleLabel.frame.origin.x, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        self.alertTypeLabel.frame = CGRectMake(0, 22, alertTypeSize.width + (self.titleLabel.frame.origin.x * 2), ceilf(alertTypeSize.height) + 4);
    }
    else if (self.frame.size.width > self.frame.size.height*2) { //layout for iPad landscape main menu
        self.backgroundLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:30];
        self.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:22];
        self.descriptionLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:16];
        
        self.closeButton.frame = CGRectMake(self.frame.size.width - 44, 0, 44, 44);
        self.closeImageView.frame = CGRectMake(0, self.closeButton.frame.size.height - 24, 24.5f, 24);

        
        self.backgroundLabel.frame = CGRectMake(-15, 0, self.frame.size.width*2, self.frame.size.height);
        self.backgroundLabel.font = [UIFont fontWithName:self.backgroundLabel.font.fontName size:self.frame.size.height * 0.8f];
        
        self.titleLabel.frame = CGRectMake(15, self.frame.size.height/3, self.frame.size.width *0.75f - 15, 80);
        self.titleLabel.font = [UIFont fontWithName:self.titleLabel.font.fontName size:35];
        
        self.descriptionLabel.frame = CGRectMake(15, CGRectGetMaxY(self.titleLabel.frame) + 5, self.frame.size.width *0.75f - 15, self.frame.size.height - CGRectGetMaxY(self.titleLabel.frame) - 20);
        self.descriptionLabel.font = [UIFont fontWithName:self.descriptionLabel.font.fontName size:20];
        
        self.alertTypeLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:self.descriptionLabel.font.pointSize * 0.8f];
        CGSize alertTypeSize = [self.alertTypeLabel.text sizeWithFont:self.alertTypeLabel.font constrainedToSize:CGSizeMake(self.frame.size.width - self.titleLabel.frame.origin.x, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        self.alertTypeLabel.frame = CGRectMake(0, 22, alertTypeSize.width + (self.titleLabel.frame.origin.x * 2), ceilf(alertTypeSize.height) + 4);
    }
    else { //layout for iPad lanscape in the right column
        self.backgroundLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:30];
        self.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:22];
        self.descriptionLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:14];
        
        self.closeButton.frame = CGRectMake(self.frame.size.width - 44, 0, 44, 44);
        self.closeImageView.frame = CGRectMake(0, self.closeButton.frame.size.height - 24, 24.5f, 24);

        
        self.backgroundLabel.frame = CGRectMake(-10, self.frame.size.height/10, self.frame.size.width*2, self.frame.size.height/2);
        self.backgroundLabel.font = [UIFont fontWithName:self.backgroundLabel.font.fontName size:100];
        
        self.titleLabel.frame = CGRectMake(15, self.frame.size.height/6, self.frame.size.width *0.8f - 15, self.frame.size.height/3);
        self.titleLabel.font = [UIFont fontWithName:self.titleLabel.font.fontName size:32];
        
        self.descriptionLabel.frame = CGRectMake(15, CGRectGetMaxY(self.titleLabel.frame) + 5, self.frame.size.width *0.8f - 15, self.frame.size.height - CGRectGetMaxY(self.titleLabel.frame) - 20);
        self.descriptionLabel.font = [UIFont fontWithName:self.descriptionLabel.font.fontName size:20];
        
        self.alertTypeLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:self.descriptionLabel.font.pointSize * 0.8f];
        CGSize alertTypeSize = [self.alertTypeLabel.text sizeWithFont:self.alertTypeLabel.font constrainedToSize:CGSizeMake(self.frame.size.width - self.titleLabel.frame.origin.x, 1000) lineBreakMode:NSLineBreakByWordWrapping];
        self.alertTypeLabel.frame = CGRectMake(0, 22, alertTypeSize.width + (self.titleLabel.frame.origin.x * 2), ceilf(alertTypeSize.height) + 4);
    }
}

- (void)setCorrectImage {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) { //layout for portrait
        if ([[[MainMenuAlert alert] type] isEqualToString:@"emergency"]) {
            self.backgroundImageView.image = [UIImage imageNamed:@"mobile_bg_alert.png"];
        }
        else {
            self.backgroundImageView.image = [UIImage imageNamed:@"mobile_bg_banner.jpg"];
        }
    }
    else if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        if ([[[MainMenuAlert alert] type] isEqualToString:@"emergency"]) {
            self.backgroundImageView.image = [UIImage imageNamed:@"mobile_bg_alert.png"];
        }
        else {
            self.backgroundImageView.image = [UIImage imageNamed:@"mobile_bg_banner.jpg"];
        }
    }
    else if (self.frame.size.width > self.frame.size.height*2) {
        if ([[[MainMenuAlert alert] type] isEqualToString:@"emergency"]) {
            self.backgroundImageView.image = [UIImage imageNamed:@"mobile_bg_alert.png"];
        }
        else {
            self.backgroundImageView.image = [UIImage imageNamed:@"mobile_bg_banner.jpg"];
        }
    }
    else {
        if ([[[MainMenuAlert alert] type] isEqualToString:@"emergency"]) {
            self.backgroundImageView.image = [UIImage imageNamed:@"mobile_bg_alert.png"];
        }
        else {
            self.backgroundImageView.image = [UIImage imageNamed:@"mobile_bg_banner.jpg"];
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
