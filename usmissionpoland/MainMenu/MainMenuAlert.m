//
//  MainMenuAlert.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/21/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "MainMenuAlert.h"

@implementation MainMenuAlert

+ (id)allocWithZone:(NSZone *)zone { return [self alert]; }
- (id)copyWithZone:(NSZone *)zone { return self; }
- (void)dealloc {  /* should never be called */ }

static MainMenuAlert *staticAlert = nil;

+ (MainMenuAlert*)alert {
    return staticAlert;
}

+ (void)showAlertTitleEn:(NSString*)titleEn descriptionEn:(NSString*)descriptionEn titlePl:(NSString*)titlePl descriptionPl:(NSString*)descriptionPl type:(NSString *)type {
    if (staticAlert == nil) {
        staticAlert = [[super allocWithZone:nil] init];
    }
    staticAlert.isEnabled = YES;
    
    staticAlert.titleEn = titleEn;
    
    staticAlert.descriptionEn = descriptionEn;
    
    staticAlert.titlePl = titlePl;
    
    staticAlert.descriptionPl = descriptionPl;
    
    staticAlert.type = type;
    if (titleEn != nil || descriptionEn != nil || titlePl != nil || descriptionPl != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:POST_NOTIFICATION_SHOW_ALERT object:nil];
    }
    
}

@end
