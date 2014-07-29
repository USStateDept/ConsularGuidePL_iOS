//
//  RssNewsItem.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 2/5/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "RssNewsItem.h"

@implementation RssNewsItem

- (void)setTitleString:(NSString *)titleString {
    if (titleString == (NSString*)[NSNull null]) {  // casting to supress compiler warnings
        _titleString = nil;
    }
    else {
        _titleString = [titleString copy];
    }
}

- (void)setDateString:(NSString *)dateString {
    if (dateString == (NSString*)[NSNull null]) {  // casting to supress compiler warnings
        _dateString = nil;
    }
    else {
        _dateString = [dateString copy];
    }
}

- (void)setContentString:(NSString *)contentString {
    if (contentString == (NSString*)[NSNull null]) {  // casting to supress compiler warnings
        _contentString = nil;
    }
    else {
        _contentString = [contentString copy];
    }
}

@end
