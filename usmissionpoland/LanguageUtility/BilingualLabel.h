//
//  BilingualLabel.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 11/28/13.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>

/** This label will automatically adjust its text when app changes language */
@interface BilingualLabel : UILabel

@property (nonatomic, copy) NSString *textEN;
@property (nonatomic, copy) NSString *textPL;

-(id)initWithTextEnglish:(NSString*)textEnglish polish:(NSString*)textPolish;

-(void)registerForLanguageChanges;
-(void)unregisterForLanguageChanges;


@end
