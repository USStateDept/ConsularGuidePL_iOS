//
//  FeedbackViewController.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/30/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "BaseViewController.h"
#import "ContentPageButtonView.h"

/** View controller for sending feedback from user to our server */
@interface FeedbackViewController : BaseViewController <UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, assign) NSInteger pageId;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) BilingualLabel *feedbackLabel;
@property (nonatomic, weak) ContentPageButtonView *contactButton;
@property (nonatomic, weak) UIView *emailTextFieldContainerView;
@property (nonatomic, weak) UITextField *emailTextField;
@property (nonatomic, weak) UITextView *contentTextView;
@property (nonatomic, weak) UIButton *sendButton;

-(id)initWithPageId:(NSInteger)pageId;

@end
