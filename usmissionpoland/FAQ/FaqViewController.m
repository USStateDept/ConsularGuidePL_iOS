//
//  FaqViewController.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/17/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "FaqViewController.h"
#import "QAView.h"
#import "AppDelegate.h"

@interface FaqViewController ()

@end

@implementation FaqViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.qAViewsArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupLayout) name:POST_NOTIFICATION_SWITCH_LANGUAGE object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self makeStepBarIfNeeded];
    [self setupLayout];
}

- (void)setupLayout {
    for (UIView *subview in self.view.subviews) {
        if (subview != self.navBar && subview != self.stepPageControl) {
            [subview removeFromSuperview];
        }
    }
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake([AppDelegate marginSpace], self.navBar.frame.size.height + self.stepPageControl.frame.size.height, self.view.frame.size.width - [AppDelegate marginSpace]*2, self.view.frame.size.height - self.navBar.frame.size.height - self.stepPageControl.frame.size.height)];
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, 20);
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    NSArray *contentArray;
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
        contentArray = [NSJSONSerialization JSONObjectWithData:[self.page.contentPL dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        NSLog(@"%@", self.page.contentPL);
    }
    else {
        contentArray = [NSJSONSerialization JSONObjectWithData:[self.page.contentEN dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        NSLog(@"%@", self.page.contentEN);
    }
    
    for (NSDictionary *qADict in contentArray) {
        if (((NSString*)qADict[@"question"]).length > 0 && ((NSString*)qADict[@"answer"]).length > 0) {
            UIViewController<ContentPageButtonDelegate> *homeVc = ((UINavigationController*)self.slidingViewController.topViewController).viewControllers.firstObject;
            
            QAView *qAView = [[QAView alloc] initWithFrame:CGRectMake(0, self.scrollView.contentSize.height, self.scrollView.frame.size.width, 0) question:[qADict objectForKey:@"question"] answer:[qADict objectForKey:@"answer"] buttonDelegate:homeVc];
            qAView.frame = CGRectMake(0, qAView.frame.origin.y, qAView.frame.size.width, qAView.questionLabel.frame.size.height + 20);
            
            [qAView addTarget:self action:@selector(didTapQAView:) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:qAView];
            self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height + qAView.frame.size.height);
            [self.qAViewsArray addObject:qAView];
        }
    }
    
    [self.view bringSubviewToFront:self.stepPageControl];
}

/** Shows/hides an FAQ answer connected to tapped question. */
- (void)didTapQAView:(QAView*)tappedQAView {
    if (tappedQAView.answerView.hidden == NO) {
        tappedQAView.frame = CGRectMake(tappedQAView.frame.origin.x, tappedQAView.frame.origin.y, tappedQAView.frame.size.width, CGRectGetMaxY(tappedQAView.answerView.frame) + 10);
        self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height + (CGRectGetMaxY(tappedQAView.answerView.frame) - CGRectGetMaxY(tappedQAView.questionLabel.frame)));
    }
    else {
        tappedQAView.frame = CGRectMake(tappedQAView.frame.origin.x, tappedQAView.frame.origin.y, tappedQAView.frame.size.width, CGRectGetMaxY(tappedQAView.questionLabel.frame) + 10);
        self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height + (CGRectGetMaxY(tappedQAView.questionLabel.frame) - CGRectGetMaxY(tappedQAView.answerView.frame)));
    }
    for (NSInteger i = [self.qAViewsArray indexOfObject:tappedQAView] + 1; i < self.qAViewsArray.count; ++i) {
        QAView *qAView = [self.qAViewsArray objectAtIndex:i];
        qAView.frame = CGRectMake(qAView.frame.origin.x, ceilf(CGRectGetMaxY(((QAView*)[self.qAViewsArray objectAtIndex:i-1]).frame)), qAView.frame.size.width, qAView.frame.size.height);
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
