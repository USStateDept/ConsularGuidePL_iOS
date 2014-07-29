//
//  PassportStatusViewController.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 3/28/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "BaseViewController.h"
#import "ContentPageButtonView.h"

@interface PassportStatusViewController : BaseViewController <NSXMLParserDelegate, UITextFieldDelegate>

@property (nonatomic, unsafe_unretained) UIScrollView *scrollView;
@property (nonatomic, unsafe_unretained) BilingualLabel *infoLabel;
@property (nonatomic, unsafe_unretained) ContentPageButtonView *tntButtonView;
@property (nonatomic, unsafe_unretained) UITextField *passportNumberField;
@property (nonatomic, unsafe_unretained) UILabel *statusLabel;
@property (nonatomic, assign) CGPoint offsetBeforeKeyboardWasShown;

@end
