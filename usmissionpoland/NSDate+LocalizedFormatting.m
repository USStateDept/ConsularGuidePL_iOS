//
//  NSDate+LocalizedFormatting.m
//  usmissionpoland
//
//  Created by Paweł Nowosad on 13.02.2014.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "NSDate+LocalizedFormatting.h"

@implementation NSDate (LocalizedFormatting)

- (NSString *)localizedStringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[LanguageSettings sharedSettings] localeForCurrentLanguage];
    dateFormatter.dateStyle = dateStyle;
    dateFormatter.timeStyle = timeStyle;
    return [dateFormatter stringFromDate:self];
}

@end
