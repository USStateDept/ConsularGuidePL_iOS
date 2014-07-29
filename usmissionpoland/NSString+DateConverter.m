//
//  NSString+DateConverter.m
//  usmissionpoland
//
//  Created by Paweł Nowosad on 11.12.2013.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import "NSString+DateConverter.h"

@implementation NSString (DateConverter)

- (NSDate *)dateFromStringWithFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:format];
    return [dateFormatter dateFromString:self];
}

@end
