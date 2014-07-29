//
//  CustomNavigationController.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/28/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "CustomNavigationController.h"
#import "NewsArticleViewController.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationBar.translucent = NO;
        
        if ([self.navigationBar respondsToSelector:@selector(setBarTintColor:)]) {
            self.navigationBar.barTintColor = CustomUSAppBlueColor;
            self.navigationBar.tintColor = [UIColor whiteColor];
        }
        else {
            self.navigationBar.tintColor = CustomUSAppBlueColor;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowOffset = CGSizeMake(-10, 0);
    
    UIView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mobile_usa.png"]];
    logoView.frame = CGRectMake(self.view.bounds.size.width/2 - 27, [[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending ? 23 : 3, 54, 54);
    logoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:logoView];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSUInteger)supportedInterfaceOrientations
{
    if (self.topViewController) {
        return [self.topViewController supportedInterfaceOrientations];
    }
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    }
    else {
        return UIInterfaceOrientationMaskAll;
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (self.topViewController) {
        return [self.topViewController supportedInterfaceOrientations];
    }
    
    return interfaceOrientation == UIInterfaceOrientationPortrait || [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

- (BOOL)shouldAutorotate {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return [super shouldAutorotate];
    }
    else {
        return NO;
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (!animated || ![viewController isKindOfClass:[NewsArticleViewController class]]) {
        [super pushViewController:viewController animated:animated];
    }
    else {
        [UIView
         transitionWithView:self.view
         duration:0.4f
         options:UIViewAnimationOptionTransitionCrossDissolve
         animations:^{
             [super
              pushViewController:viewController
              animated:NO];
         }
         completion:NULL];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews {
    return;
}

- (void)viewDidLayoutSubviews {
    return;
}


@end
