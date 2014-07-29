//
//  LanguageSettings.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 11/28/13.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import "LanguageSettings.h"

@implementation LanguageSettings {
    Language _currentLanguage;
}


+ (id)allocWithZone:(NSZone *)zone { return [self sharedSettings]; }
- (id)copyWithZone:(NSZone *)zone { return self; }
- (void)dealloc {  /* should never be called */ }

+(id)sharedSettings {
    static LanguageSettings* sharedInstance = nil;
    
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        // --- call to super avoids a deadlock with the above allocWithZone
        sharedInstance = [[super allocWithZone:nil] init];
        
        [sharedInstance initializeLanguage];
    });
    
    return sharedInstance;
}

-(Language)currentLanguage {
    return _currentLanguage;
}

- (void)initializeLanguage { //setting language at the initialization; doesn't send a notification
    _currentLanguage = [self languageWithDefaultLanguageString:[[NSLocale preferredLanguages] objectAtIndex:0]];
}

-(void)setLanguage:(Language)language {
    if (language != _currentLanguage) {
        _currentLanguage = language;
        if (language == LanguagePolish) {
            [[NSUserDefaults standardUserDefaults] setObject:@"pl" forKey:@"language"];
        }
        else {
            [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:@"language"];
            
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:POST_NOTIFICATION_SWITCH_LANGUAGE object:nil];
    }
}

-(Language)languageWithDefaultLanguageString:(NSString*)defaultLanguageString {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastLanguage = [defaults objectForKey:@"language"];
    
    if (lastLanguage != nil) {
        if ([lastLanguage isEqualToString:@"pl"]) {
            return LanguagePolish;
        }
        else {
            return LanguageEnglish;
        }
    }
    else if ([defaultLanguageString isEqualToString:@"pl"]) {
        [defaults setObject:@"pl" forKey:@"language"];
        return LanguagePolish;
    }
    else {
        [defaults setObject:@"en" forKey:@"language"];
        return LanguageEnglish;
    }
}

-(NSLocale *)localeForCurrentLanguage {
    if (_currentLanguage == LanguagePolish)
        return [[NSLocale alloc] initWithLocaleIdentifier:@"pl_PL"];
    else
        return [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
}


@end
