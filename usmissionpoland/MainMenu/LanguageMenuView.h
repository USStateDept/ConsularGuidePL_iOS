//
//  LanguageMenuView.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 12/12/13.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>

/** This is a simple view with 3 buttons: "EN" and "PL buttons that change language of the app and a "Feedback" button that opens FeedbackViewController's instance */
@interface LanguageMenuView : UIView

@property (nonatomic, unsafe_unretained) UIButton *languageEnglishButton;
@property (nonatomic, unsafe_unretained) UIButton *languagePolishButton;
@property (nonatomic, unsafe_unretained) UIButton *feedbackButton;
@property (nonatomic, unsafe_unretained) BilingualLabel *feedbackLabel;
@property (nonatomic, unsafe_unretained) UIImageView *feedbackIcon;
@property (nonatomic, unsafe_unretained) UIView *separatorLine;

@end
