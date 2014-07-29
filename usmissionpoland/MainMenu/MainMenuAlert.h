//
//  MainMenuAlert.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/21/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>

/** This singleton class keeps the alert banner content that is displayed on home page. */
@interface MainMenuAlert : NSObject

@property (nonatomic, retain) NSString *titleEn;
@property (nonatomic, retain) NSString *descriptionEn;
@property (nonatomic, retain) NSString *titlePl;
@property (nonatomic, retain) NSString *descriptionPl;
@property (nonatomic, retain) NSString *type;

@property (nonatomic, assign) BOOL isEnabled;

+ (MainMenuAlert*)alert;
+ (void)showAlertTitleEn:(NSString*)titleEn descriptionEn:(NSString*)descriptionEn titlePl:(NSString*)titlePl descriptionPl:(NSString*)descriptionPl type:(NSString*)type;

@end
