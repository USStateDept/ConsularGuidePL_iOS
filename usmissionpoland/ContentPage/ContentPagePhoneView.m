//
//  ContentPagePhoneView.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/7/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPagePhoneView.h"

@interface ContentPagePhoneView ()

@property (nonatomic, retain) NSString* phoneNumber;

@end

@implementation ContentPagePhoneView

- (id)initWithFrame:(CGRect)frame phoneNumber:(NSString *)phoneNumber {
    self = [super initWithFrame:frame];
    if (self) {
        self.leftSubviewOffset = 30;
        self.phoneNumber = phoneNumber;
        
        UIButton *phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        phoneButton.backgroundColor = [UIColor clearColor];
        [phoneButton setBackgroundImage:[UIImage imageNamed:@"phoneIcon.png"] forState:UIControlStateNormal];
        phoneButton.frame = CGRectMake(0, 0, 24, 24);
        if (phoneNumber != nil) {
            [phoneButton addTarget:self action:@selector(showCallAlert) forControlEvents:UIControlEventTouchUpInside];
        }
        [self addSubview:phoneButton];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame phoneNumber:nil];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)showCallAlert {
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
        UIAlertView *callAlert = [[UIAlertView alloc] initWithTitle:@"Jesteś pewien?" message:[NSString stringWithFormat:@"Czy chcesz wykonać połączenie z numerem %@", self.phoneNumber] delegate:self cancelButtonTitle:@"NIE" otherButtonTitles:@"TAK", nil];
        [callAlert show];
    }
    else {
        UIAlertView *callAlert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:[NSString stringWithFormat:@"Do you want to make a call to %@", self.phoneNumber] delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [callAlert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self call];
    }
}

- (void)call {
    NSURL *callUrl = [NSURL URLWithString:[[NSString stringWithFormat:@"tel://%@", self.phoneNumber] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    if ([[UIApplication sharedApplication] canOpenURL:callUrl]) {
        [[UIApplication sharedApplication] openURL:callUrl];
    }
    else {
        if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
            UIAlertView *callAlert = [[UIAlertView alloc] initWithTitle:nil message:@"To urządzenie nie pozwala na dzwonienie" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [callAlert show];
        }
        else {
            UIAlertView *callAlert = [[UIAlertView alloc] initWithTitle:nil message:@"This device does not allow to make phone calls" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [callAlert show];
        }
    }
}

@end
