//
//  AdditionalContentView.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 3/14/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "AdditionalContentViewController.h"

@implementation AdditionalContentViewController

- (id)initWithFrame:(CGRect)frame contentEN:(NSString*)contentEN contentPL:(NSString*)contentPL buttonDelegate:(id<ContentPageButtonDelegate>)buttonDelegate{
    self = [super init];
    if (self) {
        self.frame = frame;
        self.contentEN = contentEN;
        self.contentPL = contentPL;
        self.buttonDelegate = buttonDelegate;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.view.frame = self.frame;
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *separatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.view.frame.size.height)];
    separatorLine.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:separatorLine];
    separatorLine.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.separatorLine = separatorLine;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGPoint)scrollViewOrigin {
    return CGPointMake(8, 4);
}

- (NSString*)contentString {
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
        return self.contentPL;
    }
    else {
        return self.contentEN;
    }
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:self.frame];
}

- (void)makeNavigationBar {
    
}

@end
