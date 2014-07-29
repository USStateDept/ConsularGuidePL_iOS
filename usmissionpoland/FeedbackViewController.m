//
//  FeedbackViewController.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/30/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "FeedbackViewController.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "HomePageViewController.h"

@interface FeedbackViewController ()

@property (nonatomic, copy) NSString* emailString;
@property (nonatomic, copy) NSString* messageString;

@end

@implementation FeedbackViewController

- (id)initWithPageId:(NSInteger)pageId {
    self = [super init];
    if (self) {
        _pageId = pageId;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.navBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.navBar.frame.size.height)];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:containerView];
    self.containerView = containerView;
    
    UIButton *closeKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeKeyboardButton.frame = containerView.bounds;
    closeKeyboardButton.backgroundColor = [UIColor clearColor];
    closeKeyboardButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [closeKeyboardButton addTarget:self action:@selector(closeKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:closeKeyboardButton];
    
    BilingualLabel *feedbackLabel = [[BilingualLabel alloc]  initWithTextEnglish:@"Please share with us your comments and suggestions on your experience using our Consular App through this page. If you have questions about visa status or non-app related questions, click here:" polish:@"Prosimy o przekazywanie komentarzy lub sugestii dotyczących aplikacji konsularnej. W przypadku pytań dotyczących statusu podania wizowego lub pytań niezwiązanych z aplikacją, kliknij tutaj:"];
    feedbackLabel.frame = CGRectMake(16, 15, self.containerView.frame.size.width - 32, 30);
    feedbackLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:16];
    feedbackLabel.numberOfLines = 0;
    feedbackLabel.lineBreakMode = NSLineBreakByWordWrapping;
    feedbackLabel.textColor = [UIColor blackColor];
    feedbackLabel.userInteractionEnabled = NO;
    [feedbackLabel sizeToFit];
    [self.containerView addSubview:feedbackLabel];
    self.feedbackLabel = feedbackLabel;
    
    id<ContentPageButtonDelegate> homeVc = ((AppDelegate*)[UIApplication sharedApplication].delegate).navController.viewControllers.firstObject;
    ContentPageButtonView *contactButtonView = [[ContentPageButtonView alloc] initWithFrame:CGRectMake(feedbackLabel.frame.origin.x, CGRectGetMaxY(feedbackLabel.frame) + 10, feedbackLabel.frame.size.width, 40) pageString:@"274" delegate:homeVc];
    contactButtonView.label.text = [[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish ? @"Kontakt" : @"Contact information";
    contactButtonView.label.font = feedbackLabel.font;
    [self.containerView addSubview:contactButtonView];
    self.contactButton = contactButtonView;
    
    UIView *emailTextFieldContainerView = [[UIView alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(contactButtonView.frame) + 10, feedbackLabel.frame.size.width, 24)];
    emailTextFieldContainerView.backgroundColor = [UIColor whiteColor];
    emailTextFieldContainerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    emailTextFieldContainerView.layer.borderWidth = 1;
    [self.containerView addSubview:emailTextFieldContainerView];
    self.emailTextFieldContainerView = emailTextFieldContainerView;
    
    UITextField *emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 0, emailTextFieldContainerView.frame.size.width - 10, emailTextFieldContainerView.frame.size.height)];
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
        emailTextField.placeholder = @"Twój adres e-mail (opcjonalne)";
    }
    else {
        emailTextField.placeholder = @"Enter your e-mail (optional)";
    }
    emailTextField.backgroundColor = [UIColor clearColor];
    emailTextField.textColor = [UIColor blackColor];
    emailTextField.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:16.0f];
    emailTextField.returnKeyType = UIReturnKeyNext;
    emailTextField.textAlignment = NSTextAlignmentLeft;
    emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    emailTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    emailTextField.delegate = self;
    [self.emailTextFieldContainerView addSubview:emailTextField];
    self.emailTextField = emailTextField;
    if (self.emailString) {
        self.emailTextField.text = self.emailString;
    }
    
    
    UITextView *contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(emailTextFieldContainerView.frame) + 5, emailTextFieldContainerView.frame.size.width, containerView.frame.size.height - CGRectGetMaxY(emailTextFieldContainerView.frame) - 65)];
    contentTextView.backgroundColor = [UIColor whiteColor];
    contentTextView.textColor = [UIColor blackColor];
    contentTextView.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:16.0f];
    contentTextView.returnKeyType = UIReturnKeyDone;
    contentTextView.textAlignment = NSTextAlignmentLeft;
    contentTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    contentTextView.layer.borderWidth = 1;
    contentTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentTextView.delegate = self;
    [self.containerView addSubview:contentTextView];
    self.contentTextView = contentTextView;
    if (self.messageString) {
        self.contentTextView.text = self.messageString;
    }
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.backgroundColor = [UIColor clearColor];
    sendButton.frame = CGRectMake(self.view.frame.size.width - 96, CGRectGetMaxY(contentTextView.frame) + 5, 80, 40);
    [sendButton addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.containerView addSubview:sendButton];
    self.sendButton = sendButton;
    
    BilingualLabel *sendLabel = [[BilingualLabel alloc] initWithTextEnglish:@"Send »" polish:@"Wyślij »"];
    sendLabel.textColor = [UIColor blackColor];
    sendLabel.frame = sendButton.bounds;
    sendLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:20];
    sendLabel.textAlignment = NSTextAlignmentRight;
    [self.sendButton addSubview:sendLabel];
    
    
    self.navBar.topItem.title = [[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish ? @"Opinia" : @"Feedback";
    [self.view bringSubviewToFront:self.navBar];
}

- (void)viewDidLayoutSubviews {
    self.feedbackLabel.frame = CGRectMake(16, 15, self.containerView.frame.size.width - 32, 30);
    [self.feedbackLabel sizeToFit];
    
    self.contactButton.frame = CGRectMake(self.feedbackLabel.frame.origin.x, CGRectGetMaxY(self.feedbackLabel.frame) + 10, self.feedbackLabel.frame.size.width, 40);
    
    self.emailTextFieldContainerView.frame = CGRectMake(16, CGRectGetMaxY(self.contactButton.frame) + 10, self.feedbackLabel.frame.size.width, 24);
    
    self.contentTextView.frame = CGRectMake(16, CGRectGetMaxY(self.emailTextFieldContainerView.frame) + 5, self.emailTextFieldContainerView.frame.size.width, self.containerView.frame.size.height - CGRectGetMaxY(self.emailTextFieldContainerView.frame) - 65);
    
    self.sendButton.frame = CGRectMake(self.view.frame.size.width - 96, CGRectGetMaxY(self.contentTextView.frame) + 5, 80, 40);
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self.contentTextView becomeFirstResponder];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGRect contentFrame = self.containerView.frame;
    contentFrame = CGRectMake(contentFrame.origin.x, contentFrame.origin.y - self.emailTextFieldContainerView.frame.origin.y, contentFrame.size.width, contentFrame.size.height);
    [UIView animateWithDuration:0.3f animations:^{
        self.containerView.frame = contentFrame;
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    CGRect contentFrame = self.containerView.frame;
    contentFrame = CGRectMake(contentFrame.origin.x, contentFrame.origin.y + self.emailTextFieldContainerView.frame.origin.y, contentFrame.size.width, contentFrame.size.height);
    [UIView animateWithDuration:0.3f animations:^{
        self.containerView.frame = contentFrame;
    }];
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    CGRect contentFrame = self.containerView.frame;
    contentFrame = CGRectMake(contentFrame.origin.x, contentFrame.origin.y - textView.frame.origin.y, contentFrame.size.width, contentFrame.size.height);
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.containerView.frame = contentFrame;
    }completion:nil];
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    CGRect contentFrame = self.containerView.frame;
    contentFrame = CGRectMake(contentFrame.origin.x, contentFrame.origin.y + self.contentTextView.frame.origin.y, contentFrame.size.width, contentFrame.size.height);
    [UIView animateWithDuration:0.3f animations:^{
        self.containerView.frame = contentFrame;
    }];
}

- (void)keyboardWasShown:(NSNotification *)notification {
    
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        keyboardSize = CGSizeMake(keyboardSize.height, keyboardSize.width);
    }
    if (self.contentTextView.isFirstResponder) {
        CGRect textViewFrame = self.contentTextView.frame;
        textViewFrame.size.height = self.containerView.frame.size.height - keyboardSize.height;
        self.contentTextView.frame = textViewFrame;
        
        self.sendButton.frame = CGRectMake(self.view.frame.size.width - 96, CGRectGetMaxY(self.contentTextView.frame) + 5, 80, 40);
        
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        keyboardSize = CGSizeMake(keyboardSize.height, keyboardSize.width);
    }
    if (self.contentTextView.isFirstResponder) {
        CGRect textViewFrame = self.contentTextView.frame;
        textViewFrame.size.height = self.containerView.frame.size.height - CGRectGetMaxY(self.emailTextFieldContainerView.frame) - 65;
        self.contentTextView.frame = textViewFrame;
        
        self.sendButton.frame = CGRectMake(self.view.frame.size.width - 96, CGRectGetMaxY(self.contentTextView.frame) + 5, 80, 40);
    }
}

- (void)send {
    AppDelegate *appDelegate = ((AppDelegate*)[[UIApplication sharedApplication] delegate]);
    if (appDelegate.feedbackTimer != nil && appDelegate.feedbackTimer.isValid) {
        if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
            UIAlertView *timerAlert = [[UIAlertView alloc] initWithTitle:@"Uwaga" message:@"Nie jest możliwe przesyłanie nam swojej opinii częściej niż raz na minutę, spróbuj ponownie później" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [timerAlert show];
        }
        else {
            UIAlertView *timerAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"It is not possible to send feedback more than once every minute. Please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [timerAlert show];
        }
    }
    else if (self.contentTextView.text.length > 0) {
        self.sendButton.enabled = NO;
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"feedback": self.contentTextView.text,
                                 @"method": @"AddFeedback"}];
        if (self.pageId != 0) {
            [params setObject:[NSNumber numberWithInteger:self.pageId] forKey:@"from_page"];
        }
        if (self.emailTextField.text.length > 0) {
            [params setObject:self.emailTextField.text forKey:@"email"];
        }
        
        [manager POST:API_MASTER_POST_DATA_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Send feedback response JSON: %@", responseObject);
            self.sendButton.enabled = YES;
            if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"Dziękujemy za przesłanie nam swojej opinii."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"Thank you for sending us your feedback."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            [self closeFeedbackView];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            self.sendButton.enabled = YES;
            if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"Operacja nie udała się. Spróbuj ponownie później."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"Operation failed. Please try again later."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }];
        
        appDelegate.feedbackTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:appDelegate selector:@selector(nop) userInfo:nil repeats:NO];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish? @"Nie jest możliwe wysłanie pustej opinii" : @"You can not send an empty feedback message."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)nop {
    
}

- (void)didTapRightBarButton {
    [super didTapRightBarButton];
    if (self.languageMenuView) {
        self.languageMenuView.feedbackButton.hidden = YES;
    }
}

- (void)closeKeyboard {
    [self.emailTextField resignFirstResponder];
    [self.contentTextView resignFirstResponder];
}

- (void)closeFeedbackView {
    [self navigationBar:self.navBar shouldPopItem:self.navBar.topItem];
}

-(void)didChangeLanguage:(NSNotification *)notification {
    [super didChangeLanguage:notification];
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
        self.emailTextField.placeholder = @"Twój adres e-mail (opcjonalne)";
        self.navBar.topItem.title = @"Opinia";
        self.contactButton.label.text = @"Kontakt";
    }
    else {
        self.emailTextField.placeholder = @"Enter your e-mail (optional)";
        self.navBar.topItem.title = @"Feedback";
        self.contactButton.label.text = @"Contact Information";
    }
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.emailString = self.emailTextField.text;
    self.messageString = self.contentTextView.text;
    
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if (self.navigationController.viewControllers.count > 1 && [[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2] isKindOfClass:[HomePageViewController class]]) {
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    else {
        return [super navigationBar:navigationBar shouldPopItem:item];
    }
}

@end
