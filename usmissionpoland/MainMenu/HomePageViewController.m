//
//  HomePageViewController.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 2/25/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HomePageViewController.h"
#import "AGIPDFTableViewController.h"
#import "RandomNewsImageGenerator.h"
#import "NewsArticleViewController.h"
#import "FaqViewController.h"
#import "VideoViewController.h"
#import "DetailMenuViewController.h"
#import "AFNetworking.h"
#import "AGITermsConditionsViewController.h"
#import "AppDelegate.h"
#import "PassportStatusViewController.h"

#import "STTwitter.h"

@interface HomePageViewController ()

@property (nonatomic, retain) NSMutableArray *tweetsArray;

@property (nonatomic, retain) RssNewsItem *newsItem1EN;
@property (nonatomic, retain) RssNewsItem *newsItem2EN;
@property (nonatomic, retain) RssNewsItem *newsItem3EN;
@property (nonatomic, retain) RssNewsItem *newsItem1PL;
@property (nonatomic, retain) RssNewsItem *newsItem2PL;
@property (nonatomic, retain) RssNewsItem *newsItem3PL;
@property (nonatomic, retain) NSString *tweetText1;
@property (nonatomic, retain) NSString *tweetText2;

@property (nonatomic, unsafe_unretained) CAGradientLayer *newsShadowOverlay1;
@property (nonatomic, unsafe_unretained) CAGradientLayer *newsShadowOverlay2;
@property (nonatomic, unsafe_unretained) CAGradientLayer *newsShadowOverlay3;

@property (nonatomic, assign) BOOL isFirstAppear;

@end

@implementation HomePageViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _tweetsArray = [[NSMutableArray alloc] init];
        _embeddedViewControllersArray = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAdditionalInfo:) name:POST_NOTIFICATION_SHOW_ADDITIONAL_INFO object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideAdditionalInfo:) name:POST_NOTIFICATION_HIDE_ADDITIONAL_INFO object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStartDatabaseUpdate:) name:POST_NOTIFICATION_DID_START_DATABASE_UPDATE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHideAlertView:) name:POST_NOTIFICATION_DID_HIDE_ALERT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(widenMainContainerView) name:POST_NOTIFICATION_NEWS_DID_APPEAR object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(narrowMainContainerView) name:POST_NOTIFICATION_NEWS_DID_DISAPPEAR object:nil];
        
        _isFirstAppear = YES;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didStartDatabaseUpdate:(NSNotification*)notification {
    [self.slidingViewController resetTopView];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self removeAllEmbeddedViewControllers];
}

- (void)showAdditionalInfo:(NSNotification*)notification {
    if (self.iPadRightColumn) {
        CGRect additionalInfoRect = self.iPadRightColumn.bounds;
        if (!self.alertView.hidden) {
            additionalInfoRect.size.height -= self.alertView.frame.size.height;
        }
        
        BaseViewController *baseVc = notification.object;
        AdditionalContentViewController *additionalContentViewController = [[AdditionalContentViewController alloc] initWithFrame:additionalInfoRect contentEN:[baseVc.page additionalEN] contentPL:[baseVc.page additionalPL] buttonDelegate:self];
        [self.iPadRightColumn addSubview:additionalContentViewController.view];
        self.additionalContentViewController = additionalContentViewController;
        
        
    }
}

- (void)hideAdditionalInfo:(NSNotification*)notification {
    [self.additionalContentViewController.view removeFromSuperview];
    self.additionalContentViewController = nil;
}

- (void)didHideAlertView:(NSNotification*)notification {
    if (self.additionalContentViewController) {
        [self.additionalContentViewController.view removeFromSuperview];
        
        AdditionalContentViewController *additionalContentViewController = [[AdditionalContentViewController alloc] initWithFrame:self.iPadRightColumn.bounds contentEN:self.additionalContentViewController.contentEN contentPL:self.additionalContentViewController.contentPL buttonDelegate:self];
        [self.iPadRightColumn addSubview:additionalContentViewController.view];
        self.additionalContentViewController = additionalContentViewController;
    }
}

- (void)openPageWithString:(NSString *)pageString {
    NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = [NSEntityDescription entityForName:@"Page" inManagedObjectContext:managedObjectContext];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"pageId = %@", pageString];
    
    Page *pageToOpen = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] firstObject];
    
    [self openPage:pageToOpen];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = CustomUSAppBlueColor;
    
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        [self setupPortraitUI];
    }
    else {
        [self setupLandscapeUI];
    }
    
    
    [self loadNewsAndTweets];
    
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastVersion = [defaults objectForKey:@"appVersion"];
    
    if (![version isEqualToString:lastVersion]) {
        
        AGITermsConditionsViewController *termsConditionsViewController = [[AGITermsConditionsViewController alloc] init];
        [self presentViewController:termsConditionsViewController animated:NO completion:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.isFirstAppear) {
        self.isFirstAppear = NO;
        [self performSelector:@selector(slideSelfToRight) withObject:nil afterDelay:1];
    }
    
    /* this is to fix errors in layout when device is rotated while there is a presented view controller on top */
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && self.mainContainerView.frame.size.height != self.view.frame.size.height) {
        [self setupPortraitUI];
    }
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && self.mainContainerView.frame.size.height != self.view.frame.size.height) {
        [self setupLandscapeUI];
    }
}

- (void)slideSelfToRight {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)setupPortraitUI {
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.iPadRightColumn = nil;
    self.newsView3 = nil;
    self.tweetView2 = nil;
    self.embeddedNavController = nil;
    [self.alertView removeFromSuperview];
    self.alertView = nil;
    for (UIViewController *child in [self.childViewControllers copy]) {
        [child removeFromParentViewController];
    }
    
    UIView *mainContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:mainContainerView];
    self.mainContainerView = mainContainerView;
    
    UIView *welcomeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainContainerView.frame.size.width, mainContainerView.frame.size.height * 0.4f)];
    [mainContainerView addSubview:welcomeView];
    welcomeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.welcomeView = welcomeView;
    
    UIImageView *welcomeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? @"flag640-x-332.png" : @"flag1366-x-938.png")]];
    welcomeImageView.frame = welcomeView.bounds;
    welcomeImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [welcomeView addSubview:welcomeImageView];
    
    BilingualLabel *welcomeLabel1 = [[BilingualLabel alloc] initWithTextEnglish:@"Welcome" polish:@"Witamy"];
    welcomeLabel1.frame = CGRectMake(15, welcomeView.frame.size.height - 68, welcomeView.frame.size.width - 30, 30);
    welcomeLabel1.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:24];
    welcomeLabel1.textColor = [UIColor darkGrayColor];
    welcomeLabel1.textAlignment = NSTextAlignmentRight;
    welcomeLabel1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [welcomeView addSubview:welcomeLabel1];
    self.welcomeLabel1 = welcomeLabel1;
    
    BilingualLabel *welcomeLabel2 = [[BilingualLabel alloc] initWithTextEnglish:@"US Mission Poland" polish:@"Misja USA w Polsce"];
    welcomeLabel2.frame = CGRectMake(15, welcomeView.frame.size.height - 36, welcomeView.frame.size.width - 30, 20);
    welcomeLabel2.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:18];
    welcomeLabel2.textColor = [UIColor blackColor];
    welcomeLabel2.textAlignment = NSTextAlignmentRight;
    welcomeLabel2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [welcomeView addSubview:welcomeLabel2];
    self.welcomeLabel1 = welcomeLabel2;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        welcomeLabel1.frame = CGRectMake(15, welcomeView.frame.size.height - 150, welcomeView.frame.size.width - 45, 80);
        welcomeLabel1.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:65];
        welcomeLabel2.frame = CGRectMake(15, welcomeView.frame.size.height - 70, welcomeView.frame.size.width - 45, 50);
        welcomeLabel2.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:38];
        
    }
    
    
    UIView *newsView1 = [[UIView alloc] initWithFrame:CGRectMake(welcomeView.frame.origin.x, CGRectGetMaxY(welcomeView.frame), welcomeView.frame.size.width, welcomeView.frame.size.height/2.0f)];
    newsView1.layer.masksToBounds = YES;
    newsView1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [mainContainerView addSubview:newsView1];
    self.newsView1 = newsView1;
    
    UIImageView *news1ImageView = [[UIImageView alloc] initWithImage:[RandomNewsImageGenerator image]];
    news1ImageView.contentMode = UIViewContentModeScaleAspectFill;
    news1ImageView.frame = CGRectMake(0, 0, self.mainContainerView.frame.size.width, newsView1.frame.size.height);
    news1ImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [newsView1 addSubview:news1ImageView];
    self.newsImageView1 = news1ImageView;
    
    CAGradientLayer *newsShadowOverlay1 = [CAGradientLayer layer];
    newsShadowOverlay1.frame = news1ImageView.bounds;
    newsShadowOverlay1.colors = [[NSArray alloc] initWithObjects:(id)[UIColor colorWithWhite:0 alpha:0.75f].CGColor, (id)[UIColor colorWithWhite:0 alpha:0].CGColor, nil];
    newsShadowOverlay1.startPoint = CGPointMake(0, 0.5f);
    newsShadowOverlay1.endPoint = CGPointMake(1.0f, 0.5f);
    [news1ImageView.layer addSublayer:newsShadowOverlay1];
    self.newsShadowOverlay1 = newsShadowOverlay1;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIImageView *moreImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mobile_icon_more.png"]];
        moreImageView.frame = CGRectMake(newsView1.frame.size.width - 28, newsView1.frame.size.height - 28, 18, 18);
        moreImageView.backgroundColor = [UIColor clearColor];
        [newsView1 addSubview:moreImageView];
    }
    else {
        UIImageView *moreImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tablet_icon_alert_more.png"]];
        moreImageView.frame = CGRectMake(newsView1.frame.size.width - 44, newsView1.frame.size.height - 44, 24, 24);
        moreImageView.backgroundColor = [UIColor clearColor];
        [newsView1 addSubview:moreImageView];
    }
    
    BilingualLabel *newsLabel1 = [[BilingualLabel alloc] initWithFrame:CGRectMake(15, 6, newsView1.frame.size.width - 30, newsView1.frame.size.height * 0.8f)];
    newsLabel1.backgroundColor = [UIColor clearColor];
    newsLabel1.numberOfLines = 0;
    newsLabel1.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:newsView1.frame.size.height / 6];
    newsLabel1.lineBreakMode = NSLineBreakByTruncatingTail;
    newsLabel1.textColor = [UIColor whiteColor];
    [newsView1 addSubview:newsLabel1];
    newsLabel1.textPL = self.newsItem1PL.titleString;
    newsLabel1.textEN = self.newsItem1EN.titleString;
    if (!newsLabel1.text && self.newsLabel1.text) { //it means that we are offline and rotated
        newsLabel1.textEN = self.newsLabel1.textEN;
        newsLabel1.textPL = self.newsLabel1.textPL;
    }
    self.newsLabel1 = newsLabel1;
    
    UIButton *newsButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    newsButton1.backgroundColor = [UIColor clearColor];
    newsButton1.frame = newsView1.bounds;
    [newsButton1 addTarget:self action:@selector(didTapNewsView1) forControlEvents:UIControlEventTouchUpInside];
    [newsView1 addSubview:newsButton1];
    self.newsButton1 = newsButton1;
    
    
    UIView *newsView2 = [[UIView alloc] initWithFrame:CGRectMake(welcomeView.frame.origin.x, CGRectGetMaxY(newsView1.frame), welcomeView.frame.size.width, welcomeView.frame.size.height/2.0f)];
    newsView2.layer.masksToBounds = YES;
    newsView2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [mainContainerView addSubview:newsView2];
    self.newsView2 = newsView2;
    
    UIImageView *news2ImageView = [[UIImageView alloc] initWithImage:[RandomNewsImageGenerator image]];
    news2ImageView.contentMode = UIViewContentModeScaleAspectFill;
    news2ImageView.frame = CGRectMake(0, 0, self.mainContainerView.frame.size.width, newsView2.frame.size.height);
    news2ImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [newsView2 addSubview:news2ImageView];
    self.newsImageView2 = news2ImageView;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIImageView *moreImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mobile_icon_more.png"]];
        moreImageView.frame = CGRectMake(newsView2.frame.size.width - 28, newsView2.frame.size.height - 28, 18, 18);
        moreImageView.backgroundColor = [UIColor clearColor];
        [newsView2 addSubview:moreImageView];
    }
    else {
        UIImageView *moreImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tablet_icon_alert_more.png"]];
        moreImageView.frame = CGRectMake(newsView2.frame.size.width - 44, newsView2.frame.size.height - 44, 24, 24);
        moreImageView.backgroundColor = [UIColor clearColor];
        [newsView2 addSubview:moreImageView];
    }
    
    CAGradientLayer *newsShadowOverlay2 = [CAGradientLayer layer];
    newsShadowOverlay2.frame = news2ImageView.bounds;
    newsShadowOverlay2.colors = [[NSArray alloc] initWithObjects:(id)[UIColor colorWithWhite:0 alpha:0.75f].CGColor, (id)[UIColor colorWithWhite:0 alpha:0].CGColor, nil];
    newsShadowOverlay2.startPoint = CGPointMake(0, 0.5f);
    newsShadowOverlay2.endPoint = CGPointMake(1.0f, 0.5f);
    [news2ImageView.layer addSublayer:newsShadowOverlay2];
    self.newsShadowOverlay2 = newsShadowOverlay2;
    
    BilingualLabel *newsLabel2 = [[BilingualLabel alloc] initWithFrame:CGRectMake(15, 6, newsView2.frame.size.width - 30, newsView2.frame.size.height * 0.8f)];
    newsLabel2.backgroundColor = [UIColor clearColor];
    newsLabel2.numberOfLines = 0;
    newsLabel2.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:newsView2.frame.size.height / 6];
    newsLabel2.lineBreakMode = NSLineBreakByTruncatingTail;
    newsLabel2.textColor = [UIColor whiteColor];
    [newsView2 addSubview:newsLabel2];
    newsLabel2.textPL = self.newsItem2PL.titleString;
    newsLabel2.textEN = self.newsItem2EN.titleString;
    if (!newsLabel2.text && self.newsLabel2.text) { //it means that we are offline and rotated
        newsLabel2.textEN = self.newsLabel2.textEN;
        newsLabel2.textPL = self.newsLabel2.textPL;
    }
    self.newsLabel2 = newsLabel2;
    
    UIButton *newsButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    newsButton2.backgroundColor = [UIColor clearColor];
    newsButton2.frame = newsView2.bounds;
    [newsButton2 addTarget:self action:@selector(didTapNewsView2) forControlEvents:UIControlEventTouchUpInside];
    [newsView2 addSubview:newsButton2];
    self.newsButton2 = newsButton2;
    
    
    UIView *tweetView1 = [[UIView alloc] initWithFrame:CGRectMake(welcomeView.frame.origin.x, CGRectGetMaxY(newsView2.frame), welcomeView.frame.size.width, welcomeView.frame.size.height/2.0f)];
    tweetView1.backgroundColor = [UIColor colorWithRed:0.25f green:0.67f blue:0.94f alpha:1];
    tweetView1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [mainContainerView addSubview:tweetView1];
    self.tweetView1 = tweetView1;
    
    UIImageView *tweetImageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mobile_icon_twitter.png"]];
    tweetImageView1.frame = CGRectMake(20, tweetView1.frame.size.height - 61 - 4, 75, 61);
    [tweetView1 addSubview:tweetImageView1];
    self.tweetImageView1 = tweetImageView1;
    
    BilingualLabel *tweetLabel1 = [[BilingualLabel alloc] initWithFrame:CGRectMake(15, 6, tweetView1.frame.size.width - 30, tweetView1.frame.size.height * 0.8f - 15)];
    tweetLabel1.numberOfLines = 0;
    tweetLabel1.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:tweetView1.frame.size.height / 6];
    tweetLabel1.lineBreakMode = NSLineBreakByTruncatingTail;
    tweetLabel1.textColor = [UIColor whiteColor];
    [tweetView1 addSubview:tweetLabel1];
    tweetLabel1.textEN = tweetLabel1.textPL = self.tweetText1;
    if (!tweetLabel1.text && self.tweetLabel1.text) { //it means that we are offline and rotated
        tweetLabel1.textEN = self.tweetLabel1.textEN;
        tweetLabel1.textPL = self.tweetLabel1.textPL;
    }
    self.tweetLabel1 = tweetLabel1;
    
    UIButton *tweetButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    tweetButton1.backgroundColor = [UIColor clearColor];
    tweetButton1.frame = tweetView1.bounds;
    [tweetButton1 addTarget:self action:@selector(didTapTweetView1) forControlEvents:UIControlEventTouchUpInside];
    [tweetView1 addSubview:tweetButton1];
    self.tweetButton1 = tweetButton1;
    
    
    self.tweetLabel2 = [[BilingualLabel alloc] initWithTextEnglish:self.tweetLabel2.textEN polish:self.tweetLabel2.textPL];
    self.newsLabel3 = [[BilingualLabel alloc] initWithTextEnglish:self.newsLabel2.textEN polish:self.newsLabel2.textPL];
    
    MainMenuAlertView *alertView = [[MainMenuAlertView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(welcomeView.frame), self.mainContainerView.frame.size.width, self.mainContainerView.frame.size.height - CGRectGetMaxY(welcomeView.frame))];
    [self.mainContainerView addSubview:alertView];
    self.alertView = alertView;
    
    if (self.embeddedViewControllersArray.count != 0) {
        for (BaseViewController* viewController in self.embeddedViewControllersArray) {
            if ([viewController isKindOfClass:[NewsTableViewController class]]) {
                ((NewsTableViewController*)viewController).isTripleColumn = NO;
            }
            [viewController.view removeFromSuperview];
            viewController.view = nil;
            [self.navigationController pushViewController:viewController animated:NO];
            viewController.embeddingViewController = nil;
        }
        
        [self.embeddedViewControllersArray removeAllObjects];
    }
    
}

- (void)setupLandscapeUI {
    [self.alertView removeFromSuperview];
    self.alertView = nil;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UIView *mainContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ceilf(self.view.bounds.size.width *2.0f / 3.0f), self.view.frame.size.height)];
    [self.view addSubview:mainContainerView];
    self.mainContainerView = mainContainerView;
    
    UIView *iPadRightColumn = [[UIView alloc] initWithFrame:CGRectMake(mainContainerView.frame.origin.x + mainContainerView.frame.size.width, 0, self.view.frame.size.width - mainContainerView.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:iPadRightColumn];
    self.iPadRightColumn = iPadRightColumn;
    
    UIView *welcomeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainContainerView.frame.size.width, mainContainerView.frame.size.height * 2.0f / 3.0f)];
    [mainContainerView addSubview:welcomeView];
    welcomeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.welcomeView = welcomeView;
    
    UIImageView *welcomeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flag1536-x-768.png"]];
    welcomeImageView.frame = welcomeView.bounds;
    welcomeImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [welcomeView addSubview:welcomeImageView];
    
    BilingualLabel *welcomeLabel1 = [[BilingualLabel alloc] initWithTextEnglish:@"Welcome" polish:@"Witamy"];
    welcomeLabel1.frame = CGRectMake(15, welcomeView.frame.size.height - 150, welcomeView.frame.size.width - 45, 80);
    welcomeLabel1.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:65];
    welcomeLabel1.textColor = [UIColor darkGrayColor];
    welcomeLabel1.textAlignment = NSTextAlignmentRight;
    welcomeLabel1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [welcomeView addSubview:welcomeLabel1];
    self.welcomeLabel1 = welcomeLabel1;
    
    BilingualLabel *welcomeLabel2 = [[BilingualLabel alloc] initWithTextEnglish:@"US Mission Poland" polish:@"Misja USA w Polsce"];
    welcomeLabel2.frame = CGRectMake(15, welcomeView.frame.size.height - 70, welcomeView.frame.size.width - 45, 50);
    welcomeLabel2.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:38];
    welcomeLabel2.textColor = [UIColor blackColor];
    welcomeLabel2.textAlignment = NSTextAlignmentRight;
    welcomeLabel2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [welcomeView addSubview:welcomeLabel2];
    self.welcomeLabel1 = welcomeLabel2;
    
    
    
    UIView *newsView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, iPadRightColumn.frame.size.width, welcomeView.frame.size.height/2.0f)];
    newsView1.layer.masksToBounds = YES;
    newsView1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [iPadRightColumn addSubview:newsView1];
    self.newsView1 = newsView1;
    
    UIImageView *newsImageView1 = [[UIImageView alloc] initWithImage:[RandomNewsImageGenerator image]];
    newsImageView1.contentMode = UIViewContentModeScaleAspectFill;
    newsImageView1.frame = CGRectMake(0, 0, self.iPadRightColumn.frame.size.width, newsView1.frame.size.height);
    newsImageView1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [newsView1 addSubview:newsImageView1];
    self.newsImageView1 = newsImageView1;
    
    UIImageView *moreImageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tablet_icon_alert_more.png"]];
    moreImageView1.frame = CGRectMake(newsView1.frame.size.width - 36, newsView1.frame.size.height - 36, 24, 24);
    moreImageView1.backgroundColor = [UIColor clearColor];
    [newsView1 addSubview:moreImageView1];
    
    CAGradientLayer *newsShadowOverlay1 = [CAGradientLayer layer];
    newsShadowOverlay1.frame = newsImageView1.bounds;
    newsShadowOverlay1.colors = [[NSArray alloc] initWithObjects:(id)[UIColor colorWithWhite:0 alpha:0.75f].CGColor, (id)[UIColor colorWithWhite:0 alpha:0].CGColor, nil];
    newsShadowOverlay1.startPoint = CGPointMake(0, 0.5f);
    newsShadowOverlay1.endPoint = CGPointMake(1.0f, 0.5f);
    [newsImageView1.layer addSublayer:newsShadowOverlay1];
    self.newsShadowOverlay1 = newsShadowOverlay1;
    
    BilingualLabel *newsLabel1 = [[BilingualLabel alloc] initWithFrame:CGRectMake(15, 20, newsView1.frame.size.width * 0.8f - 15, newsView1.frame.size.height - 40)];
    newsLabel1.backgroundColor = [UIColor clearColor];
    newsLabel1.numberOfLines = 0;
    newsLabel1.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:20];
    newsLabel1.lineBreakMode = NSLineBreakByTruncatingTail;
    newsLabel1.textColor = [UIColor whiteColor];
    [newsView1 addSubview:newsLabel1];
    newsLabel1.textPL = self.newsItem1PL.titleString;
    newsLabel1.textEN = self.newsItem1EN.titleString;
    if (!newsLabel1.text && self.newsLabel1.text) { //it means that we are offline and rotated
        newsLabel1.textEN = self.newsLabel1.textEN;
        newsLabel1.textPL = self.newsLabel1.textPL;
    }
    self.newsLabel1 = newsLabel1;
    
    UIButton *newsButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    newsButton1.backgroundColor = [UIColor clearColor];
    newsButton1.frame = newsView1.bounds;
    [newsButton1 addTarget:self action:@selector(didTapNewsView1) forControlEvents:UIControlEventTouchUpInside];
    [newsView1 addSubview:newsButton1];
    self.newsButton1 = newsButton1;
    
    
    UIView *tweetView1 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(newsView1.frame), iPadRightColumn.frame.size.width, welcomeView.frame.size.height - newsView1.frame.size.height)];
    tweetView1.backgroundColor = [UIColor colorWithRed:0.25f green:0.67f blue:0.94f alpha:1];
    tweetView1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [iPadRightColumn addSubview:tweetView1];
    self.tweetView1 = tweetView1;
    
    UIImageView *tweetImageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tablet_icon_twitter.png"]];
    tweetImageView1.frame = CGRectMake(20, tweetView1.frame.size.height - 81 - 20, 100, 81);
    [tweetView1 addSubview:tweetImageView1];
    
    BilingualLabel *tweetLabel1 = [[BilingualLabel alloc] initWithFrame:CGRectMake(15, 20, tweetView1.frame.size.width * 0.8f - 15, tweetView1.frame.size.height - 80)];
    tweetLabel1.numberOfLines = 0;
    tweetLabel1.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:20];
    tweetLabel1.lineBreakMode = NSLineBreakByTruncatingTail;
    tweetLabel1.textColor = [UIColor whiteColor];
    [tweetView1 addSubview:tweetLabel1];
    tweetLabel1.textEN = tweetLabel1.textPL = self.tweetText1;
    if (!tweetLabel1.text && self.tweetLabel1.text) { //it means that we are offline and rotated
        tweetLabel1.textEN = self.tweetLabel1.textEN;
        tweetLabel1.textPL = self.tweetLabel1.textPL;
    }
    self.tweetLabel1 = tweetLabel1;
    
    
    UIButton *tweetButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    tweetButton1.backgroundColor = [UIColor clearColor];
    tweetButton1.frame = tweetView1.bounds;
    [tweetButton1 addTarget:self action:@selector(didTapTweetView1) forControlEvents:UIControlEventTouchUpInside];
    [tweetView1 addSubview:tweetButton1];
    self.tweetButton1 = tweetButton1;
    
    
    UIView *newsView2 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tweetView1.frame), iPadRightColumn.frame.size.width, iPadRightColumn.frame.size.height - CGRectGetMaxY(tweetView1.frame))];
    newsView2.layer.masksToBounds = YES;
    newsView2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [iPadRightColumn addSubview:newsView2];
    self.newsView2 = newsView2;
    
    UIImageView *newsImageView2 = [[UIImageView alloc] initWithImage:[RandomNewsImageGenerator image]];
    newsImageView2.contentMode = UIViewContentModeScaleAspectFill;
    newsImageView2.frame = CGRectMake(0, 0, self.iPadRightColumn.frame.size.width, newsView2.frame.size.height);
    newsImageView2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [newsView2 addSubview:newsImageView2];
    self.newsImageView2 = newsImageView2;
    
    UIImageView *moreImageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tablet_icon_alert_more.png"]];
    moreImageView2.frame = CGRectMake(newsView2.frame.size.width - 36, newsView2.frame.size.height - 36, 24, 24);
    moreImageView2.backgroundColor = [UIColor clearColor];
    [newsView2 addSubview:moreImageView2];
    
    CAGradientLayer *newsShadowOverlay2 = [CAGradientLayer layer];
    newsShadowOverlay2.frame = newsImageView2.bounds;
    newsShadowOverlay2.colors = [[NSArray alloc] initWithObjects:(id)[UIColor colorWithWhite:0 alpha:0.75f].CGColor, (id)[UIColor colorWithWhite:0 alpha:0].CGColor, nil];
    newsShadowOverlay2.startPoint = CGPointMake(0, 0.5f);
    newsShadowOverlay2.endPoint = CGPointMake(1.0f, 0.5f);
    [newsImageView2.layer addSublayer:newsShadowOverlay2];
    self.newsShadowOverlay2 = newsShadowOverlay2;
    
    BilingualLabel *newsLabel2 = [[BilingualLabel alloc] initWithFrame:CGRectMake(15, 20, newsView2.frame.size.width * 0.8f - 15, newsView2.frame.size.height - 40)];
    newsLabel2.backgroundColor = [UIColor clearColor];
    newsLabel2.numberOfLines = 0;
    newsLabel2.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:20];
    newsLabel2.lineBreakMode = NSLineBreakByTruncatingTail;
    newsLabel2.textColor = [UIColor whiteColor];
    [newsView2 addSubview:newsLabel2];
    newsLabel2.textPL = self.newsItem2PL.titleString;
    newsLabel2.textEN = self.newsItem2EN.titleString;
    if (!newsLabel2.text && self.newsLabel2.text) { //it means that we are offline and rotated
        newsLabel2.textEN = self.newsLabel2.textEN;
        newsLabel2.textPL = self.newsLabel2.textPL;
    }
    self.newsLabel2 = newsLabel2;
    
    UIButton *newsButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    newsButton2.backgroundColor = [UIColor clearColor];
    newsButton2.frame = newsView2.bounds;
    [newsButton2 addTarget:self action:@selector(didTapNewsView2) forControlEvents:UIControlEventTouchUpInside];
    [newsView2 addSubview:newsButton2];
    self.newsButton2 = newsButton2;
    
    
    UIView *newsView3 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(welcomeView.frame), iPadRightColumn.frame.size.width, mainContainerView.frame.size.height - welcomeView.frame.size.height)];
    newsView3.layer.masksToBounds = YES;
    newsView3.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [mainContainerView addSubview:newsView3];
    self.newsView3 = newsView3;
    
    UIImageView *newsImageView3 = [[UIImageView alloc] initWithImage:[RandomNewsImageGenerator image]];
    newsImageView3.contentMode = UIViewContentModeScaleAspectFill;
    newsImageView3.frame = CGRectMake(0, 0, self.mainContainerView.frame.size.width/2, newsView3.frame.size.height);
    newsImageView3.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [newsView3 addSubview:newsImageView3];
    self.newsImageView3 = newsImageView3;
    
    UIImageView *moreImageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tablet_icon_alert_more.png"]];
    moreImageView3.frame = CGRectMake(newsView3.frame.size.width - 36, newsView3.frame.size.height - 36, 24, 24);
    moreImageView3.backgroundColor = [UIColor clearColor];
    [newsView3 addSubview:moreImageView3];
    
    CAGradientLayer *newsShadowOverlay3 = [CAGradientLayer layer];
    newsShadowOverlay3.frame = newsImageView3.bounds;
    newsShadowOverlay3.colors = [[NSArray alloc] initWithObjects:(id)[UIColor colorWithWhite:0 alpha:0.75f].CGColor, (id)[UIColor colorWithWhite:0 alpha:0].CGColor, nil];
    newsShadowOverlay3.startPoint = CGPointMake(0, 0.5f);
    newsShadowOverlay3.endPoint = CGPointMake(1.0f, 0.5f);
    [newsImageView3.layer addSublayer:newsShadowOverlay3];
    self.newsShadowOverlay2 = newsShadowOverlay3;
    
    BilingualLabel *newsLabel3 = [[BilingualLabel alloc] initWithFrame:CGRectMake(15, 20, newsView3.frame.size.width * 0.8f - 15, newsView3.frame.size.height - 40)];
    newsLabel3.backgroundColor = [UIColor clearColor];
    newsLabel3.numberOfLines = 0;
    newsLabel3.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:20];
    newsLabel3.lineBreakMode = NSLineBreakByTruncatingTail;
    newsLabel3.textColor = [UIColor whiteColor];
    [newsView3 addSubview:newsLabel3];
    newsLabel3.textPL = self.newsItem3PL.titleString;
    newsLabel3.textEN = self.newsItem3EN.titleString;
    if (!newsLabel3.text && self.newsLabel3.text) { //it means that we are offline and rotated
        newsLabel3.textEN = self.newsLabel3.textEN;
        newsLabel3.textPL = self.newsLabel3.textPL;
    }
    self.newsLabel3 = newsLabel3;
    
    UIButton *newsButton3 = [UIButton buttonWithType:UIButtonTypeCustom];
    newsButton3.backgroundColor = [UIColor clearColor];
    newsButton3.frame = newsView3.bounds;
    [newsButton3 addTarget:self action:@selector(didTapNewsView3) forControlEvents:UIControlEventTouchUpInside];
    [newsView3 addSubview:newsButton3];
    self.newsButton3 = newsButton3;
    
    
    UIView *tweetView2 = [[UIView alloc] initWithFrame:CGRectMake(newsView3.frame.size.width, CGRectGetMaxY(welcomeView.frame), mainContainerView.frame.size.width - newsView3.frame.size.width, mainContainerView.frame.size.height - welcomeView.frame.size.height)];
    tweetView2.backgroundColor = [UIColor colorWithRed:0.25f green:0.67f blue:0.94f alpha:1];
    tweetView2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [mainContainerView addSubview:tweetView2];
    self.tweetView2 = tweetView2;
    
    UIImageView *tweetImageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tablet_icon_twitter.png"]];
    tweetImageView2.frame = CGRectMake(20, tweetView2.frame.size.height - 81 - 20, 100, 81);
    [tweetView2 addSubview:tweetImageView2];
    
    BilingualLabel *tweetLabel2 = [[BilingualLabel alloc] initWithFrame:CGRectMake(15, 20, tweetView2.frame.size.width * 0.8f - 15, tweetView2.frame.size.height - 80)];
    tweetLabel2.numberOfLines = 0;
    tweetLabel2.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:20];
    tweetLabel2.lineBreakMode = NSLineBreakByTruncatingTail;
    tweetLabel2.textColor = [UIColor whiteColor];
    [tweetView2 addSubview:tweetLabel2];
    tweetLabel2.textEN = tweetLabel2.textPL = self.tweetText2;
    if (!tweetLabel2.text && self.tweetLabel2.text) { //it means that we are offline and rotated
        tweetLabel2.textEN = self.tweetLabel2.textEN;
        tweetLabel2.textPL = self.tweetLabel2.textPL;
    }
    self.tweetLabel2 = tweetLabel2;
    
    UIButton *tweetButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    tweetButton2.backgroundColor = [UIColor clearColor];
    tweetButton2.frame = tweetView2.bounds;
    [tweetButton2 addTarget:self action:@selector(didTapTweetView2) forControlEvents:UIControlEventTouchUpInside];
    [tweetView2 addSubview:tweetButton2];
    self.tweetButton2 = tweetButton2;
    
    
    MainMenuAlertView *alertView = [[MainMenuAlertView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(welcomeView.frame), self.mainContainerView.frame.size.width, self.mainContainerView.frame.size.height - CGRectGetMaxY(welcomeView.frame))];
    [self.mainContainerView addSubview:alertView];
    self.alertView = alertView;
    
    if (self.embeddedViewControllersArray.count != 0) { //after rotation, at this point we have the view controllers that were on top of current one in this array
        self.alertView.frame = self.newsView2.frame;
        [self.iPadRightColumn addSubview:self.alertView];
        
        EmbeddedNavigationController *embeddedNavVc = [[EmbeddedNavigationController alloc] init];
        self.embeddedNavController = embeddedNavVc;
        self.embeddedNavController.view.frame = self.mainContainerView.bounds;
        self.embeddedNavController.navigationBarHidden = YES;
        [self.mainContainerView addSubview:self.embeddedNavController.view];
        [self addChildViewController:self.embeddedNavController];
        
        for (BaseViewController *viewController in self.embeddedViewControllersArray) {
            if ([viewController isKindOfClass:[NewsTableViewController class]]) {
                NewsTableViewController *newsVc = (NewsTableViewController*)viewController;
                newsVc.isTripleColumn = YES;
                [newsVc.view removeFromSuperview];
                
                if (self.embeddedViewControllersArray.lastObject == newsVc) {
                    [self widenMainContainerView];
                }
            }
            else if (!([viewController isKindOfClass:[AGIPDFTableViewController class]] || [viewController isKindOfClass:[VideoViewController class]])) {
                [viewController.view removeFromSuperview];
            }
            else {
                viewController.view.frame = self.mainContainerView.bounds;
                [viewController.view removeFromSuperview];
            }
            viewController.embeddingViewController = self;
            
            
            self.embeddedNavController.view.frame = self.mainContainerView.bounds;
            [self.embeddedNavController pushViewController:viewController animated:NO];
            
            
        }
        
        self.mainContainerView.frame = CGRectMake(0, 0, self.mainContainerView.frame.size.width, self.mainContainerView.frame.size.height);
        self.iPadRightColumn.frame = CGRectMake(self.view.frame.size.width - self.iPadRightColumn.frame.size.width, 0, self.iPadRightColumn.frame.size.width, self.iPadRightColumn.frame.size.height);
    }
}

- (void)makeNavigationBar {
    // this view controller shouldn't have extra navigation bar, hence this empty implementation
}

- (void)loadNewsAndTweets {
    [self loadRssNews];
    
    [self loadMoreTweetsWithMaxId:nil];
}

- (void)loadRssNews {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"method": @"GetRssNews", @"count": [NSNumber numberWithInt:3]};
    [manager POST:API_POST_DATA_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *resultsArray = responseObject[@"result"];
        for (NSDictionary *newsItemDictionary in resultsArray) {
            RssNewsItem *newsItem = [[RssNewsItem alloc] init];
            if ([newsItemDictionary[@"language"] isEqualToString:@"PL"]) {
                newsItem.language = LanguagePolish;
            }
            else {
                newsItem.language = LanguageEnglish;
            }
            newsItem.titleString = newsItemDictionary[@"title"];
            newsItem.dateString = newsItemDictionary[@"subtitle"];
            newsItem.contentString = newsItemDictionary[@"text"];
            
            if (newsItem.language == LanguagePolish) {
                if (self.newsItem1PL != nil && self.newsItem2PL != nil && self.newsItem3PL != nil) {
                    self.newsItem1PL = nil;
                    self.newsItem2PL = nil;
                    self.newsItem3PL = nil;
                }
                
                if (self.newsItem1PL == nil) {
                    self.newsItem1PL = newsItem;
                    self.newsLabel1.textPL = newsItem.titleString;
                }
                else if (self.newsItem2PL == nil) {
                    self.newsItem2PL = newsItem;
                    self.newsLabel2.textPL = newsItem.titleString;
                }
                else if (self.newsItem3PL == nil) {
                    self.newsItem3PL = newsItem;
                    self.newsLabel3.textPL = newsItem.titleString;
                }
            }
            else {
                if (self.newsItem1EN != nil && self.newsItem2EN != nil && self.newsItem3EN != nil) {
                    self.newsItem1EN = nil;
                    self.newsItem2EN = nil;
                    self.newsItem3EN = nil;
                }
                
                if (self.newsItem1EN == nil) {
                    self.newsItem1EN = newsItem;
                    self.newsLabel1.textEN = newsItem.titleString;
                }
                else if (self.newsItem2EN == nil) {
                    self.newsItem2EN = newsItem;
                    self.newsLabel2.textEN = newsItem.titleString;
                }
                else if (self.newsItem3EN == nil) {
                    self.newsItem3EN = newsItem;
                    self.newsLabel3.textEN = newsItem.titleString;
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"RSS Error: %@", [error localizedDescription]);
        
        if (![operation.request.URL.absoluteString isEqualToString:API_POST_DATA_URL] || [[ServerPicker picker] switchServer]) {
            [self loadRssNews];
        }
        else {
            self.newsLabel1.textEN = self.newsLabel2.textEN = self.newsLabel3.textEN = @"News are not available\nin offline mode";
            self.newsLabel1.textPL = self.newsLabel2.textPL = self.newsLabel3.textPL = @"Artykuły nie są dostępne\nw trybie offline";
        }
    }];
}

- (void)loadMoreTweetsWithMaxId:(NSString*)maximumId {
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:TWITTER_CONSUMER_KEY
                                                            consumerSecret:TWITTER_CONSUMER_SECRET];
    
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *bearerToken) {
        
        [twitter getUserTimelineWithScreenName:@"USEmbassyWarsaw"
                                       sinceID:nil
                                         maxID:maximumId
                                         count:30
                                  successBlock:^(NSArray *statuses) {
                                      if (![statuses isKindOfClass:[NSArray class]]) { //if there is an error from twitter, this would actually be a string, not an array and therefore the app would crash in the next line
                                          return;
                                      }
                                      NSLog(@"tweets:\n%@", statuses);
                                      for (int i = 0; i < statuses.count; ++i) {
                                          NSDictionary *status = [statuses objectAtIndex:i];
                                          if ([status objectForKey:@"retweeted_status"] == nil) {
                                              [self.tweetsArray addObject:status];
                                          }
                                      }
                                      NSString *maxId;
                                      if (statuses.count > 0) {
                                          maxId = [statuses.lastObject objectForKey:@"id_str"];
                                      }
                                      else {
                                          maxId = [self.tweetsArray.lastObject objectForKey:@"id_str"];
                                      }
                                      
                                      if (self.tweetsArray.count < 2) {
                                          [self loadMoreTweetsWithMaxId:maxId];
                                      }
                                      else {
                                          self.tweetText1 =[[self.tweetsArray firstObject] objectForKey:@"text"];
                                          self.tweetLabel1.textEN = self.tweetLabel1.textPL = self.tweetText1;
                                          self.tweetText2 = [[self.tweetsArray objectAtIndex:1] objectForKey:@"text"];
                                          self.tweetLabel2.textEN = self.tweetLabel2.textPL = self.tweetText2;
                                      }
                                      
                                  } errorBlock:^(NSError *error) {
                                      //NSLog(@"failed to retrieve tweets");
                                  }];
    } errorBlock:^(NSError *error) {
        //NSLog(@"failed to authenticate");
        
        if (!self.tweetLabel1.text) {
            self.tweetLabel1.textEN = @"Tweets are not available\nin offline mode";
            self.tweetLabel1.textPL = @"Tweety nie są dostępne\nw trybie offline";
        }
        if (!self.tweetLabel2.text) {
            self.tweetLabel2.textEN = @"Tweets are not available\nin offline mode";
            self.tweetLabel2.textPL = @"Tweety nie są dostępne\nw trybie offline";
        }
    }];
    
    
}

- (void)didChangeLanguage:(NSNotification *)notification {
    [super didChangeLanguage:notification];
}

- (void)openPage:(Page*)pageToOpen {
    if (self.rightBarButton.selected) {
        [self didTapRightBarButton];
    }
    if ([pageToOpen.type isEqualToString:@"face"]) {
        NSURL *fbUrl = [NSURL URLWithString:@"https://pl-pl.facebook.com/USEmbassyWarsaw"];
        if ([[UIApplication sharedApplication] canOpenURL:fbUrl]) {
            [[UIApplication sharedApplication] openURL:fbUrl];
        }
    }
    else {
        if ([pageToOpen.type isEqualToString:@"text"] || [pageToOpen.type isEqualToString:@"cont"] || [pageToOpen.type isEqualToString:@"list"] || [pageToOpen.type isEqualToString:@"stps"]) {
            [self openContentPage:pageToOpen];
        }
        else if ([pageToOpen.type isEqualToString:@"file"]) {
            [self openFileManager:pageToOpen];
        }
        else if ([pageToOpen.type isEqualToString:@"head"]) {
            [self openNewsPage:pageToOpen];
        }
        else if ([pageToOpen.type isEqualToString:@"faqs"]) {
            [self openFaqWithPage:pageToOpen];
        }
        else if ([pageToOpen.type isEqualToString:@"vids"]) {
            [self openVideosPage:pageToOpen];
        }
        else if ([pageToOpen.type isEqualToString:@"pasp"]) {
            [self openPassportPage:pageToOpen];
        }
    }
}

- (void)createEmbeddedNavController {
    [self.embeddedNavController.view removeFromSuperview];
    [self.embeddedNavController removeFromParentViewController];
    self.embeddedNavController = nil;
    
    EmbeddedNavigationController *menuNavController = [[EmbeddedNavigationController alloc] init];
    menuNavController.view.frame = CGRectMake(0, 0, self.mainContainerView.frame.size.width, self.mainContainerView.frame.size.height);
    menuNavController.navigationBarHidden = YES;
    [self addChildViewController:menuNavController];
    self.embeddedNavController = menuNavController;
    
    [self.mainContainerView addSubview:menuNavController.view];
    
    if (self.iPadRightColumn) {
        self.alertView.frame = self.newsView2.frame;
        [self.iPadRightColumn addSubview:self.alertView];
    }
}

- (void)openPassportPage:(Page*)page {
    PassportStatusViewController *passportStatusVc = [[PassportStatusViewController alloc] init];
    passportStatusVc.page = page;
    if (!self.iPadRightColumn) {
        [self.navigationController pushViewController:passportStatusVc animated:YES];
    }
    else {
        if (self.embeddedNavController == nil) {
            [self createEmbeddedNavController];
        }
        [self.embeddedNavController pushViewController:passportStatusVc animated:YES];
    }
}

- (void)openMenuPage:(Page *)page {
    if (self.rightBarButton.selected) {
        [self didTapRightBarButton];
    }
    DetailMenuViewController *menuVc = [[DetailMenuViewController alloc] initWithPage:page];
    if (!self.iPadRightColumn) {
        [self.navigationController pushViewController:menuVc animated:YES];
    }
    else {
        if (self.embeddedNavController == nil) {
            [self createEmbeddedNavController];
        }
        [self.embeddedNavController pushViewController:menuVc animated:YES];
    }
}

- (void)openContentPage:(Page*)page {
    ContentPageViewController *contentVc = [[ContentPageViewController alloc] init];
    contentVc.page = page;
    if (!self.iPadRightColumn) {
        [self.navigationController pushViewController:contentVc animated:YES];
    }
    else {
        if (self.embeddedNavController == nil) {
            [self createEmbeddedNavController];
        }
        [self.embeddedNavController pushViewController:contentVc animated:YES];
    }
    
}

- (void)openNewsPage:(Page*)page {
    NewsTableViewController *newsController = [[NewsTableViewController alloc] init];
    newsController.page = page;
    if (!self.iPadRightColumn) {
        [self.navigationController pushViewController:newsController animated:YES];
    }
    else {
        if (self.embeddedNavController == nil) {
            newsController.isTripleColumn = YES;
            [self widenMainContainerView];
            
            [self createEmbeddedNavController];
        }
        [self.embeddedNavController pushViewController:newsController animated:YES];
    }
}

- (void)openFaqWithPage:(Page*)page {
    FaqViewController *faqViewController = [[FaqViewController alloc] init];
    faqViewController.page = page;
    if (!self.iPadRightColumn) {
        [self.navigationController pushViewController:faqViewController animated:YES];
    }
    else {
        if (self.embeddedNavController == nil) {
            [self createEmbeddedNavController];
        }
        else {
            [self.embeddedNavController pushViewController:faqViewController animated:YES];
        }
    }
    
}

- (void)openVideosPage:(Page*)page {
    VideoViewController *videoViewController = [[VideoViewController alloc] initWithNibName:@"VideoViewController" bundle:nil];
    videoViewController.page = page;
    if (!self.iPadRightColumn) {
        [self.navigationController pushViewController:videoViewController animated:YES];
    }
    else {
        
        if (self.embeddedNavController == nil) {
            [self createEmbeddedNavController];
        }
        [self.embeddedNavController pushViewController:videoViewController animated:YES];
    }
}

- (void)openFileManager:(Page*)page {
    AGIPDFTableViewController *pdfController = [[AGIPDFTableViewController alloc] initWithNibName:@"AGIPDFTableViewController" bundle:nil];
    pdfController.page = page;
    if (!self.iPadRightColumn) {
        [self.navigationController pushViewController:pdfController animated:YES];
    }
    else {
        if (self.embeddedNavController == nil) {
            [self createEmbeddedNavController];
        }
        [self.embeddedNavController pushViewController:pdfController animated:YES];
    }
}

- (void)openNewsArticleWithFeedItem:(RssNewsItem*)feedItem topImage:(UIImage*)topImage { //this is only called on iPad in landscape
    if ([self.embeddedNavController.viewControllers.lastObject isKindOfClass:[NewsArticleViewController class]]) {
        if (self.embeddedNavController.viewControllers.count == 1) {
            [self.embeddedNavController.view removeFromSuperview];
            [self.embeddedNavController removeFromParentViewController];
            self.embeddedNavController = nil;
        }
        else {
            [self.embeddedNavController popViewControllerAnimated:NO];
        }
    }
    if ([self.embeddedNavController.viewControllers.lastObject isKindOfClass:[NewsTableViewController class]]) {
        [self narrowMainContainerView];
    }
    
    NewsArticleViewController *articleVc = [[NewsArticleViewController alloc] initWithFeedItem:feedItem topImage:topImage];
    
    if (self.embeddedNavController == nil) {
        [self createEmbeddedNavController];
    }
    [self.embeddedNavController pushViewController:articleVc animated:NO];
    
}

//- (NSMutableArray *)embeddedViewControllersArray {
//    return _embeddedViewControllersArray;
//}

/** Opens news article kept in newsItem1; if in portrait, an animation preceeds appearance of the article. */
- (void)didTapNewsView1 {
    if (([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish && self.newsItem1PL == nil) || ([[LanguageSettings sharedSettings] currentLanguage] == LanguageEnglish && self.newsItem1EN == nil)) {
        return;
    }
    if (!self.iPadRightColumn) {
        [UIView animateWithDuration:1 delay:0 options:0 animations:^{
            self.welcomeView.frame = CGRectMake(0, -self.welcomeView.frame.size.height, self.welcomeView.frame.size.width, self.welcomeView.frame.size.height);
            self.newsView1.frame = CGRectMake(0, 50, self.newsView1.frame.size.width, self.newsView1.frame.size.height);
            self.newsView2.frame = CGRectMake(0, self.mainContainerView.frame.size.height, self.newsView2.frame.size.width, self.newsView2.frame.size.height);
            self.tweetView1.frame = CGRectMake(0, self.mainContainerView.frame.size.height + self.newsView2.frame.size.height, self.tweetView1.frame.size.width, self.tweetView1.frame.size.height);
        }completion:^(BOOL finished){
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                [self openNewsArticleWithFeedItem:[[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish ? self.newsItem1PL : self.newsItem1EN topImage:self.newsImageView1.image];
            }
            else {
                NewsArticleViewController *articleVc;
                if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish){
                    articleVc = [[NewsArticleViewController alloc] initWithFeedItem:self.newsItem1PL topImage:self.newsImageView1.image];
                }
                else {
                    articleVc = [[NewsArticleViewController alloc] initWithFeedItem:self.newsItem1EN topImage:self.newsImageView1.image];
                }
                
                
                [self.navigationController pushViewController:articleVc animated:YES];
                
                self.mainContainerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
                self.newsShadowOverlay1.hidden = NO;
                self.newsLabel1.hidden = NO;
                self.welcomeView.frame = CGRectMake(0, 0, self.welcomeView.frame.size.width, self.welcomeView.frame.size.height);
                self.newsView1.frame = CGRectMake(0, CGRectGetMaxY(self.welcomeView.frame), self.newsView1.frame.size.width, self.newsView1.frame.size.height);
                self.newsView2.frame = CGRectMake(0, CGRectGetMaxY(self.newsView1.frame), self.newsView2.frame.size.width, self.newsView2.frame.size.height);
                self.tweetView1.frame = CGRectMake(0, CGRectGetMaxY(self.newsView2.frame), self.tweetView1.frame.size.width, self.tweetView1.frame.size.height);
                
            }
            
        }];
        
    }
    else {
        if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish){
            [self openNewsArticleWithFeedItem:self.newsItem1PL topImage:self.newsImageView1.image];
        }
        else {
            [self openNewsArticleWithFeedItem:self.newsItem1EN topImage:self.newsImageView1.image];
        }
    }
}

/** Opens news article kept in newsItem1; if in portrait, an animation preceeds appearance of the article. */
- (void)didTapNewsView2 {
    if (([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish && self.newsItem2PL == nil) || ([[LanguageSettings sharedSettings] currentLanguage] == LanguageEnglish && self.newsItem2EN == nil)) {
        return;
    }
    if (!self.iPadRightColumn) {
        [UIView animateWithDuration:1 delay:0 options:0 animations:^{
            self.welcomeView.frame = CGRectMake(0, -self.welcomeView.frame.size.height - self.newsView1.frame.size.height, self.welcomeView.frame.size.width, self.welcomeView.frame.size.height);
            self.newsView1.frame = CGRectMake(0, -self.newsView1.frame.size.height, self.newsView1.frame.size.width, self.newsView1.frame.size.height);
            self.newsView2.frame = CGRectMake(0, 50, self.newsView2.frame.size.width, self.newsView2.frame.size.height);
            self.tweetView1.frame = CGRectMake(0, self.mainContainerView.frame.size.height, self.tweetView1.frame.size.width, self.tweetView1.frame.size.height);
        }completion:^(BOOL finished){
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                [self openNewsArticleWithFeedItem:[[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish ? self.newsItem2PL : self.newsItem2EN topImage:self.newsImageView2.image];
            }
            else {
                NewsArticleViewController *articleVc;
                if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish){
                    articleVc = [[NewsArticleViewController alloc] initWithFeedItem:self.newsItem2PL topImage:self.newsImageView2.image];
                }
                else {
                    articleVc = [[NewsArticleViewController alloc] initWithFeedItem:self.newsItem2EN topImage:self.newsImageView2.image];
                }
                
                [self.navigationController pushViewController:articleVc animated:YES];
                
                self.mainContainerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
                self.newsShadowOverlay2.hidden = NO;
                self.newsLabel2.hidden = NO;
                self.welcomeView.frame = CGRectMake(0, 0, self.welcomeView.frame.size.width, self.welcomeView.frame.size.height);
                self.newsView1.frame = CGRectMake(0, CGRectGetMaxY(self.welcomeView.frame), self.newsView1.frame.size.width, self.newsView1.frame.size.height);
                self.newsView2.frame = CGRectMake(0, CGRectGetMaxY(self.newsView1.frame), self.newsView2.frame.size.width, self.newsView2.frame.size.height);
                self.tweetView1.frame = CGRectMake(0, CGRectGetMaxY(self.newsView2.frame), self.tweetView1.frame.size.width, self.tweetView1.frame.size.height);
            }
            
        }];
    }
    else {
        if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish){
            [self openNewsArticleWithFeedItem:self.newsItem2PL topImage:self.newsImageView2.image];
        }
        else {
            [self openNewsArticleWithFeedItem:self.newsItem2EN topImage:self.newsImageView2.image];
        }
    }
}

/** Opens news article kept in newsItem1; only called in landscape mode, as there's only 2 news views in portrait. */
- (void)didTapNewsView3 {
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish){
        if (self.newsItem3PL) {
            [self openNewsArticleWithFeedItem:self.newsItem3PL topImage:self.newsImageView3.image];
        }
    }
    else {
        if (self.newsItem3EN) {
            [self openNewsArticleWithFeedItem:self.newsItem3EN topImage:self.newsImageView3.image];
        }
    }
}

- (void)didTapTweetView1 {
    if (self.tweetsArray.count > 0) {
        NSString *tweetId = [[self.tweetsArray objectAtIndex:0] objectForKey:@"id_str"];
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitter://status?id=%@", tweetId]]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitter://status?id=%@", tweetId]]];
        }
        else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.twitter.com/USEmbassyWarsaw/status/%@", tweetId]]];
        }
    }
}

- (void)didTapTweetView2 {
    if (self.tweetsArray.count > 1) {
        NSString *tweetId = [[self.tweetsArray objectAtIndex:1] objectForKey:@"id_str"];
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitter://status?id=%@", tweetId]]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitter://status?id=%@", tweetId]]];
        }
        else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.twitter.com/USEmbassyWarsaw/status/%@", tweetId]]];
        }
    }
}

-(void)removeLastEmbeddedViewController {
    BaseViewController *lastEmbeddedVc = self.embeddedViewControllersArray.lastObject;
    [lastEmbeddedVc.view removeFromSuperview];
    lastEmbeddedVc.embeddingViewController = nil;
    [self.embeddedViewControllersArray removeLastObject];
    
    if ([lastEmbeddedVc isKindOfClass:[NewsArticleViewController class]] && [self.embeddedViewControllersArray.lastObject isKindOfClass:[NewsTableViewController class]] && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        
        [self widenMainContainerView];
    }
    else if ([lastEmbeddedVc isKindOfClass:[NewsTableViewController class]]) {
        [self narrowMainContainerView];
    }
}

-(void)removeAllEmbeddedViewControllers {
    while (self.embeddedViewControllersArray.count > 0) {
        if ([self.embeddedViewControllersArray.lastObject isKindOfClass:[NewsTableViewController class]]) {
            [self narrowMainContainerView]; //in case we had NewsTableViewController opened
        }
        [self removeLastEmbeddedViewController];
    }
    [self.embeddedNavController.view removeFromSuperview];
    [self.embeddedNavController removeFromParentViewController];
    self.embeddedNavController = nil;
    
    
    self.alertView.frame = CGRectMake(0, CGRectGetMaxY(self.welcomeView.frame), self.mainContainerView.frame.size.width, self.mainContainerView.frame.size.height - CGRectGetMaxY(self.welcomeView.frame));
    [self.mainContainerView addSubview:self.alertView];
    
    if (self.rightBarButton.selected) {
        [self didTapRightBarButton];
    }
}

-(BOOL)shouldAutorotate {
    return YES;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && (!UIInterfaceOrientationIsPortrait(fromInterfaceOrientation) || self.iPadRightColumn)) {
        [self.embeddedViewControllersArray removeAllObjects];
        [self.embeddedViewControllersArray addObjectsFromArray:self.embeddedNavController.viewControllers];
        [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self setupPortraitUI];
        self.rightBarButton.selected = NO;
    }
    else if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && (!UIInterfaceOrientationIsLandscape(fromInterfaceOrientation) || !self.iPadRightColumn)) {
        [self.embeddedViewControllersArray addObjectsFromArray:self.navigationController.viewControllers];
        [self.embeddedViewControllersArray removeObject:self];
        [self.navigationController popToRootViewControllerAnimated:NO];
        [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self setupLandscapeUI];
        self.rightBarButton.selected = NO;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    /* this was implemented to handle issues with view's frame if user rotated iPad while on terms & conditions screen */
    CGRect myFrame = self.view.frame;
    if (myFrame.size.height != self.navigationController.view.frame.size.height - (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? self.navigationController.view.frame.size.width : self.navigationController.view.frame.size.height) - (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? [UIApplication sharedApplication].statusBarFrame.size.width : [UIApplication sharedApplication].statusBarFrame.size.height)) {
        /* for unknown reasons, on iOS6 sometimes navigation controller has height of 733 points, which is total nonsense and causes HomePageViewController to display in a wrong way - this is a hotfix for it */
        if (self.navigationController.view.frame.size.height == 733) {
            CGRect navFrame = self.navigationController.view.frame;
            navFrame.size.height = 768;
            self.navigationController.view.frame = navFrame;
        }
        
        
        myFrame.size.width = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? self.navigationController.view.frame.size.width : self.navigationController.view.frame.size.height;
        myFrame.size.height = (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? self.navigationController.view.frame.size.height : self.navigationController.view.frame.size.width) - self.navigationController.navigationBar.frame.size.height;
        if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
            myFrame.size.height -= (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? [UIApplication sharedApplication].statusBarFrame.size.width : [UIApplication sharedApplication].statusBarFrame.size.height);
        }
        self.view.frame = myFrame;
    }
    [self didRotateFromInterfaceOrientation:self.iPadRightColumn?UIInterfaceOrientationLandscapeRight:UIInterfaceOrientationPortrait];
    return;
    
}

/** Makes mainContainerView wider, which is needed when we're showing news table in landscape mode. */
- (void)widenMainContainerView {
    self.mainContainerView.frame = CGRectMake(self.mainContainerView.frame.origin.x, self.mainContainerView.frame.origin.y, self.view.frame.size.width, self.mainContainerView.frame.size.height);
    [self.view insertSubview:self.mainContainerView aboveSubview:self.iPadRightColumn];
    if (self.embeddedNavController) {
        self.embeddedNavController.view.frame = self.mainContainerView.bounds;
    }
}

/** Reverts changes done by widenMainContainerView */
- (void)narrowMainContainerView {
    self.mainContainerView.frame = CGRectMake(self.mainContainerView.frame.origin.x, self.mainContainerView.frame.origin.y, self.view.frame.size.width - self.iPadRightColumn.frame.size.width, self.mainContainerView.frame.size.height);
    
    [self.view insertSubview:self.mainContainerView belowSubview:self.iPadRightColumn];
    if (self.embeddedNavController) {
        self.embeddedNavController.view.frame = self.mainContainerView.bounds;
    }
}

/** LanguageMenuView is needs to be modified if article view is shown */
- (void)didTapRightBarButton {
    [super didTapRightBarButton];
    if (self.rightBarButton.selected) {
        if ([self.embeddedNavController.topViewController isKindOfClass:[NewsArticleViewController class]]) {
            self.languageMenuView.languageEnglishButton.hidden = YES;
            self.languageMenuView.languagePolishButton.hidden = YES;
            self.languageMenuView.separatorLine.hidden = YES;
        }
        else {
            self.languageMenuView.languageEnglishButton.hidden = NO;
            self.languageMenuView.languagePolishButton.hidden = NO;
            self.languageMenuView.separatorLine.hidden = NO;
        }
    }
}

- (void)setIPadRightColumn:(UIView *)iPadRightColumn {
    if (self.alertView.superview == self.iPadRightColumn) {
        [iPadRightColumn addSubview:self.alertView];
    }
    [_iPadRightColumn removeFromSuperview];
    _iPadRightColumn = iPadRightColumn;
}

- (void)setMainContainerView:(UIView *)mainContainerView {
    if (self.alertView.superview == self.mainContainerView) {
        [mainContainerView addSubview:self.alertView];
    }
    [_mainContainerView removeFromSuperview];
    _mainContainerView = mainContainerView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
