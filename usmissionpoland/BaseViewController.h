//
//  BaseViewController.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 11/28/13.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LanguageSettings.h"
#import "LanguageMenuView.h"
#import "Page.h"
#import "RssNewsItem.h"
#import "ECSlidingViewController.h"

@protocol EmbeddingViewController <NSObject>

- (void)openPage:(Page*)pageToOpen;
- (void)openMenuPage:(Page*)page;
- (void)openContentPage:(Page*)page;
- (void)openNewsPage:(Page*)page;
- (void)openFaqWithPage:(Page*)page;
- (void)openVideosPage:(Page*)page;
- (void)openFileManager:(Page*)page;
- (void)openNewsArticleWithFeedItem:(RssNewsItem*)feedItem topImage:(UIImage*)topImage;
- (void)openPassportPage:(Page*)page;
- (void)removeLastEmbeddedViewController;
- (void)removeAllEmbeddedViewControllers;
@property (nonatomic, strong) NSMutableArray *embeddedViewControllersArray;

@end

/** View controller from which most view controllers in this app inherit from. Provides functionality that is needed everywhere in the app, no matter what view controller is user currently on. */
@interface BaseViewController : UIViewController <UINavigationBarDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) Page *page;
@property (nonatomic, assign) BOOL isStep;
@property (nonatomic, assign) int numberOfSteps;
@property (nonatomic, assign) int stepIndex;
@property (nonatomic, unsafe_unretained) UIPageControl *stepPageControl;

@property (nonatomic, strong) Page *previousStepPage;
@property (nonatomic, strong) Page *nextStepPage;

@property (nonatomic, weak) UIButton *rightBarButton;
@property (nonatomic, weak) UIButton *leftBarButton;
@property (nonatomic, weak) LanguageMenuView *languageMenuView;

@property (nonatomic, weak) UINavigationBar *navBar;

@property (nonatomic, weak) UIViewController<EmbeddingViewController>* embeddingViewController;

- (void)didChangeLanguage:(NSNotification*)notification;
- (void)didTapRightBarButton;

- (void)makeStepBarIfNeeded;

// for subclassing purposes
- (void)makeNavigationBar;

@end
