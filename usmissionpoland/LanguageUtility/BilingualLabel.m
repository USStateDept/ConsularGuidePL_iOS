//
//  BilingualLabel.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 11/28/13.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import "BilingualLabel.h"

@implementation BilingualLabel

- (id)initWithTextEnglish:(NSString *)textEnglish polish:(NSString *)textPolish
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        // Initialization code
        _textEN = [textEnglish copy];
        _textPL = [textPolish copy];
        Language language = [[LanguageSettings sharedSettings] currentLanguage];
        if (language == LanguagePolish) {
            self.text = _textPL;
        }
        else {
            self.text = _textEN;
        }
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self registerForLanguageChanges];
        
    }
    return self;
}

-(void)registerForLanguageChanges {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeLanguage:) name:POST_NOTIFICATION_SWITCH_LANGUAGE object:nil];
}

-(void)unregisterForLanguageChanges {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)didChangeLanguage:(NSNotification*)notification {
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
        self.text = self.textPL;
    }
    else {
        self.text = self.textEN;
    }
    
}

-(void)setTextEN:(NSString *)textEN {
    _textEN = [textEN copy];
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguageEnglish) {
        self.text = _textEN;
    }
}

-(void)setTextPL:(NSString *)textPL {
    _textPL = [textPL copy];
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
        self.text = _textPL;
    }
}

-(void)dealloc {
    [self unregisterForLanguageChanges];
}

@end
