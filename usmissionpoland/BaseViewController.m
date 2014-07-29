//
//  BaseViewController.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 11/28/13.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import "BaseViewController.h"
#import "HomePageViewController.h"
#import "NewsArticleViewController.h"
#import "AppDelegate.h"
#import "EmbeddedNavigationController.h"
#import "AdditionalContentViewController.h"
#import "FeedbackViewController.h"

#import "FaqViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.languageMenuView removeFromSuperview];
    self.languageMenuView = nil;
    self.rightBarButton.selected = NO;
    
    if ([self.page localizedAdditionalContent]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:POST_NOTIFICATION_HIDE_ADDITIONAL_INFO object:self];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.page localizedAdditionalContent]) {
        NSLog(@"additional content is %@", [self.page localizedAdditionalContent]  );
        [[NSNotificationCenter defaultCenter] postNotificationName:POST_NOTIFICATION_SHOW_ADDITIONAL_INFO object:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Wróć" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    else {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:POST_NOTIFICATION_SWITCH_LANGUAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeLanguage:) name:POST_NOTIFICATION_SWITCH_LANGUAGE object:nil];
    
    
    /* in order to make self.view.frame valid in viewDidLoad, resizing that normally happens later because of navigation and status bars taking part of the screen is already done here */
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) && ![self.navigationController isKindOfClass:[EmbeddedNavigationController class]] && ![self isKindOfClass:[AdditionalContentViewController class]]) {
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.height, self.view.frame.size.width);
    }
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.origin.y - self.navigationController.navigationBar.frame.size.height);
    
    UIButton *rightBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBarButton setBackgroundImage:[UIImage imageNamed:@"icon_menu-circles_44x12.png"] forState:UIControlStateNormal];
    rightBarButton.frame = CGRectMake(0, 0, 22, 6);
    [rightBarButton addTarget:self action:@selector(didTapRightBarButton) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    self.rightBarButton = rightBarButton;
    
    if (self.slidingViewController.topViewController == self.navigationController) {
        UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftBarButton addTarget:self action:@selector(didTapLeftBarButton) forControlEvents:UIControlEventTouchUpInside];
        [leftBarButton setBackgroundImage:[UIImage imageNamed:@"icon_hamburger_38x30.png"] forState:UIControlStateNormal];
        leftBarButton.frame = CGRectMake(0, 0, 19, 15);
        
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
        self.navigationItem.leftBarButtonItem = leftBarButtonItem;
        self.leftBarButton = leftBarButton;
    }
    
    if (self.isStep) {
        
        if ([self.page.type isEqualToString:@"stps"]) {
            NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
            
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            fetchRequest.entity = [NSEntityDescription entityForName:@"Page" inManagedObjectContext:managedObjectContext];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"parentId = %d", [self.page.pageId  intValue]];
            
            NSArray *unorderedChildrenPagesArray = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
            
            NSArray *childrenPagesArray = [unorderedChildrenPagesArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSNumber *first = [(Page*)a index];
                NSNumber *second = [(Page*)b index];
                return [first compare:second];
            }];
            self.nextStepPage = childrenPagesArray.firstObject;
            
            self.numberOfSteps = childrenPagesArray.count + 1;
            self.stepIndex = 0;
        }
        else {
            NSManagedObjectContext *managedObjectContext = [(AppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
            
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            fetchRequest.entity = [NSEntityDescription entityForName:@"Page" inManagedObjectContext:managedObjectContext];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"parentId = %d AND pageId != %d", [self.page.parentId  intValue], [self.page.pageId intValue]];
            
            NSArray *unorderedChildrenPagesArray = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
            
            NSArray *childrenPagesArray = [unorderedChildrenPagesArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSNumber *first = [(Page*)a index];
                NSNumber *second = [(Page*)b index];
                return [first compare:second];
            }];
            
            self.numberOfSteps = childrenPagesArray.count + 2;
            self.stepIndex = 1;
            
            for (Page *page in childrenPagesArray) {
                if (page.index.intValue < self.page.index.intValue) {
                    self.previousStepPage = page;
                    self.stepIndex += 1;
                }
                else if (page.index.intValue > self.page.index.intValue && self.nextStepPage == nil) {
                    self.nextStepPage = page;
                }
            }
            
            if (self.previousStepPage == nil) {
                fetchRequest = [[NSFetchRequest alloc] init];
                fetchRequest.entity = [NSEntityDescription entityForName:@"Page" inManagedObjectContext:managedObjectContext];
                fetchRequest.predicate = [NSPredicate predicateWithFormat:@"pageId == %d", [self.page.parentId  intValue]];
                
                self.previousStepPage = [managedObjectContext executeFetchRequest:fetchRequest error:nil].firstObject;
            }
            
        }
        
        if (self.previousStepPage) {
            
            UISwipeGestureRecognizer *prevPageGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(openPreviousStep)];
            prevPageGesture.direction = UISwipeGestureRecognizerDirectionRight;
            [self.view addGestureRecognizer:prevPageGesture];
        }
        
        if (self.nextStepPage) {
            
            UISwipeGestureRecognizer *nextPageGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(openNextStep)];
            nextPageGesture.direction = UISwipeGestureRecognizerDirectionLeft;
            [self.view addGestureRecognizer:nextPageGesture];
        }
    }
    
    [self makeNavigationBar];
}

- (void)openPreviousStep {
    BaseViewController *viewController;
    if ([self.previousStepPage.type isEqualToString:@"text"] || [self.previousStepPage.type isEqualToString:@"cont"] || [self.previousStepPage.type isEqualToString:@"list"] || [self.previousStepPage.type isEqualToString:@"stps"]) {
        viewController = [[ContentPageViewController alloc] init];
    }
    else if ([self.previousStepPage.type isEqualToString:@"faqs"]) {
        viewController = [[FaqViewController alloc] init];
    }
    
    if (viewController != nil) {
        viewController.page = self.previousStepPage;
        viewController.isStep = YES;
        UINavigationController *navigationController = self.navigationController;
        
        [navigationController popViewControllerAnimated:NO];
        [navigationController pushViewController:viewController animated:NO];
        [navigationController pushViewController:self animated:NO];
        [navigationController popViewControllerAnimated:YES];
        
    }
    
}

- (void)openNextStep {
    BaseViewController *viewController;
    if ([self.nextStepPage.type isEqualToString:@"text"] || [self.nextStepPage.type isEqualToString:@"cont"] || [self.nextStepPage.type isEqualToString:@"list"] || [self.nextStepPage.type isEqualToString:@"stps"]) {
        viewController = [[ContentPageViewController alloc] init];
    }
    else if ([self.nextStepPage.type isEqualToString:@"faqs"]) {
        viewController = [[FaqViewController alloc] init];
    }
    
    if (viewController != nil) {
        viewController.page = self.nextStepPage;
        viewController.isStep = YES;
        UINavigationController *navigationController = self.navigationController;
        navigationController.delegate = self;
        [navigationController pushViewController:viewController animated:YES];
    }
    
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (animated) {
        navigationController.delegate = nil;
        UIViewController *topVc = [navigationController popViewControllerAnimated:NO];
        [navigationController popViewControllerAnimated:NO];
        [navigationController pushViewController:topVc animated:NO];
    }
}

- (void)makeNavigationBar {
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    navBar.barStyle = UIBarStyleBlack;
    navBar.translucent = NO;
    
    UINavigationItem *firstItem = [[UINavigationItem alloc] initWithTitle:[self.page localizedTitle]];
    firstItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UINavigationItem *backItem = [[UINavigationItem alloc] initWithTitle:nil];
    backItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [navBar setItems:[NSArray arrayWithObjects:backItem, firstItem, nil]];
    if ([navBar respondsToSelector:@selector(setBarTintColor:)]) {
        navBar.barTintColor = [UIColor colorWithWhite:0.8 alpha:1];
        navBar.tintColor = [UIColor blackColor];
    }
    else {
        navBar.tintColor = [UIColor colorWithWhite:0.8 alpha:1];
    }
    navBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor blackColor], UITextAttributeFont : [UIFont fontWithName:DEFAULT_FONT_BOLD size:16]};
    navBar.delegate = self;
    [self.view addSubview:navBar];
    self.navBar = navBar;
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    
    if (!self.navigationController) {
        if (self.parentViewController) {
            [self.slidingViewController anchorTopViewTo:ECRight];
        }
        else {
            [self.embeddingViewController removeLastEmbeddedViewController];
        }
    }
    else {
        if (self.navigationController.viewControllers.count <= 1 && ([self isKindOfClass:[NewsArticleViewController class]] || [self isKindOfClass:[FeedbackViewController class]])) { //it means that we're in an embeddedNavController inside a HomePageViewController
            if (self.embeddingViewController) {
                [self.embeddingViewController.embeddedViewControllersArray removeObject:self];
                self.embeddingViewController = nil;
            }
            [self.navigationController.view removeFromSuperview];
            [((HomePageViewController*)self.navigationController.parentViewController).embeddedNavController removeFromParentViewController];
            ((HomePageViewController*)self.navigationController.parentViewController).embeddedNavController = nil;
        }
        else if ([self.navigationController viewControllers].count <= 1 || (self.navigationController.viewControllers.count == 2 && [self.navigationController.viewControllers.firstObject isKindOfClass:[HomePageViewController class]] && ![self.navigationController.viewControllers.lastObject isKindOfClass:[NewsArticleViewController class]])) {
            [self.slidingViewController anchorTopViewTo:ECRight];
        }
        else {
            if (self.embeddingViewController) {
                [self.embeddingViewController.embeddedViewControllersArray removeObject:self];
                self.embeddingViewController = nil;
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    
    return NO;
}

- (void)setLanguageEnglish {
    [[LanguageSettings sharedSettings] setLanguage:LanguageEnglish];
}

- (void)setLanguagePolish {
    [[LanguageSettings sharedSettings] setLanguage:LanguagePolish];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didChangeLanguage:(NSNotification*)notification {
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Wróć" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    else {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    if (self.navBar.items.count == 2 && ((UINavigationItem*)self.navBar.items.firstObject).title == nil) {
        ((UINavigationItem*)self.navBar.items.lastObject).title = [self.page localizedTitle];
    }
    
}

- (void)didTapRightBarButton {
    if (!self.rightBarButton.selected) {
        if (self.languageMenuView) {
            LanguageMenuView *languageMenuView = self.languageMenuView;
            [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                languageMenuView.frame = CGRectMake(0, 0, self.view.frame.size.width, 50);
            }completion:nil];
        }
        else {
            LanguageMenuView *languageMenuView = [[LanguageMenuView alloc] initWithFrame:CGRectMake(0, -50, self.view.frame.size.width, 50)];
            [self.view addSubview:languageMenuView];
            self.languageMenuView = languageMenuView;
            [UIView animateWithDuration:0.5f delay:0 options:0 animations:^{
                languageMenuView.frame = CGRectMake(0, 0, self.view.frame.size.width, 50);
            }completion:nil];
        }
    }
    else {
        LanguageMenuView *languageMenuView = self.languageMenuView;
        [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            languageMenuView.frame = CGRectMake(0, -50, self.view.frame.size.width, 50);
        }completion:^(BOOL finished) {
            if (finished) {
                [languageMenuView removeFromSuperview];
                if (languageMenuView == self.languageMenuView && CGRectEqualToRect(languageMenuView.frame, CGRectMake(0, -50, self.view.frame.size.width, 50))) {
                    self.languageMenuView = nil;
                }
            }
        }];
    }
    self.rightBarButton.selected = !self.rightBarButton.selected;
}

- (void)didTapLeftBarButton {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

-(NSUInteger)supportedInterfaceOrientations
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    }
    else {
        return UIInterfaceOrientationMaskAll;
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait || [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if (self.navigationController) {
        if (self.navigationController.viewControllers.firstObject != self) {
            ((BaseViewController*)self.navigationController.viewControllers.firstObject).view.frame = self.view.frame;
            [self.navigationController.viewControllers.firstObject didRotateFromInterfaceOrientation:fromInterfaceOrientation];
        }
    }
}

- (void)makeStepBarIfNeeded {
    if (self.isStep) {
        UIPageControl *stepPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 20, self.view.frame.size.width, 20)];
        
        stepPageControl.numberOfPages = self.numberOfSteps;
        stepPageControl.currentPage = self.stepIndex;
        
        stepPageControl.pageIndicatorTintColor = [UIColor grayColor];
        stepPageControl.currentPageIndicatorTintColor = [UIColor blackColor];
        
        stepPageControl.backgroundColor = [UIColor whiteColor];
        stepPageControl.userInteractionEnabled = NO;
        [self.view addSubview:stepPageControl];
        self.stepPageControl = stepPageControl;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
