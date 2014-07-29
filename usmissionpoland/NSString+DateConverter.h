//
//  NSString+DateConverter.h
//  usmissionpoland
//
//  Created by Paweł Nowosad on 11.12.2013.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DateConverter)

- (NSDate *)dateFromStringWithFormat:(NSString *)format;

@end
