//
//  LanguageSettings.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 11/28/13.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    LanguageEnglish,
    LanguagePolish
}Language;

/** Singleton class that manages language settings in app */
@interface LanguageSettings : NSObject

+(id)sharedSettings;

-(Language)currentLanguage;
-(void)setLanguage:(Language)language;
-(NSLocale *)localeForCurrentLanguage;

@end
