//
//  NSDate+LocalizedFormatting.h
//  usmissionpoland
//
//  Created by Paweł Nowosad on 13.02.2014.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (LocalizedFormatting)

- (NSString *)localizedStringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;

@end
