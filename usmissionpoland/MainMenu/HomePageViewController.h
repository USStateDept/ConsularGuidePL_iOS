//
//  HomePageViewController.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 2/25/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "NewsTableViewController.h"
#import "BaseViewController.h"
#import "ContentPageViewController.h"
#import "RssNewsItem.h"
#import "MainMenuAlertView.h"
#import "EmbeddedNavigationController.h"
#import "AdditionalContentViewController.h"

/** The controller that manages home page. When in landscape mode, it also does most of the view controller's management - instead of being added on top of it in its navigation controller, they are added to embeddedNavController, whose view is a subview of HomePageViewController's mainContainerView. */
@interface HomePageViewController : BaseViewController <EmbeddingViewController, ContentPageButtonDelegate>

/** Contains welcomeView, embeddedNavigationController's view and either newsView1, newsView2 and tweetView1 (if in portrait) or newsView3 and tweetView2 (if in landscape) */
@property (nonatomic, unsafe_unretained) UIView *mainContainerView;

/** The view that says "Welcome (..)", with US flag in background */
@property (nonatomic, unsafe_unretained) UIView *welcomeView;
@property (nonatomic, unsafe_unretained) BilingualLabel *welcomeLabel1;
@property (nonatomic, unsafe_unretained) BilingualLabel *welcomeLabel2;

@property (nonatomic, unsafe_unretained) UIView *newsView1;
@property (nonatomic, unsafe_unretained) UIImageView *newsImageView1;
@property (nonatomic, strong) BilingualLabel *newsLabel1;
@property (nonatomic, unsafe_unretained) UIButton *newsButton1;
@property (nonatomic, unsafe_unretained) UIView *newsView2;
@property (nonatomic, unsafe_unretained) UIImageView *newsImageView2;
@property (nonatomic, strong) BilingualLabel *newsLabel2;
@property (nonatomic, unsafe_unretained) UIButton *newsButton2;
@property (nonatomic, unsafe_unretained) UIView *newsView3;
@property (nonatomic, unsafe_unretained) UIImageView *newsImageView3;
@property (nonatomic, strong) BilingualLabel *newsLabel3;
@property (nonatomic, unsafe_unretained) UIButton *newsButton3;

@property (nonatomic, unsafe_unretained) UIView *tweetView1;
@property (nonatomic, unsafe_unretained) UIImageView *tweetImageView1;
@property (nonatomic, strong) BilingualLabel *tweetLabel1;
@property (nonatomic, unsafe_unretained) UIButton *tweetButton1;
@property (nonatomic, unsafe_unretained) UIView *tweetView2;
@property (nonatomic, unsafe_unretained) UIImageView *tweetImageView2;
@property (nonatomic, strong) BilingualLabel *tweetLabel2;
@property (nonatomic, unsafe_unretained) UIButton *tweetButton2;

@property (nonatomic, unsafe_unretained) MainMenuAlertView *alertView;

/** iPadRightColumn is an extra right column that is displayed on iPad in landscape mode (if there is no iPadRightColumnt, mainContainerView takes whole width of this view controller's view). */
@property (nonatomic, unsafe_unretained) UIView *iPadRightColumn;

/** Some pages have additional content - it will be displayed in landscape mode by this AdditionalContentViewController. */
@property (nonatomic, strong) AdditionalContentViewController *additionalContentViewController;

/** For managing view controller's hierarchy in landscape mode */
@property (nonatomic, strong) EmbeddedNavigationController *embeddedNavController;
@property (nonatomic, strong) NSMutableArray *embeddedViewControllersArray;

- (void)createEmbeddedNavController;

@end
