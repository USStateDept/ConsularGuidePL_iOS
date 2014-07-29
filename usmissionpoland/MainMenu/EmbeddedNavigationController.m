//
//  EmbeddedNavigationController.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 3/11/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "EmbeddedNavigationController.h"
#import "VideoViewController.h"
#import "AGIPDFTableViewController.h"
#import "HomePageViewController.h"

@interface EmbeddedNavigationController ()

@end

@implementation EmbeddedNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[VideoViewController class]] || [viewController isKindOfClass:[AGIPDFTableViewController class]]) {
        viewController.view.frame = self.view.bounds;
    }
    else {
        viewController.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width)];
        CGRect thisFrame = viewController.view.frame;
        thisFrame.size.width = self.view.frame.size.height;
        thisFrame.size.height = self.view.frame.size.width;
        viewController.view.frame = thisFrame;
        [viewController viewDidLoad];
    }
    HomePageViewController *homeVc = ((HomePageViewController*)self.parentViewController);
    if (![homeVc.embeddedViewControllersArray containsObject:viewController]) {
        [homeVc.embeddedViewControllersArray addObject:viewController];
    }
    
    BaseViewController *baseVc = (BaseViewController*)viewController;
    if ([baseVc respondsToSelector:@selector(setEmbeddingViewController:)]) {
        baseVc.embeddingViewController = homeVc;
    }
    
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *poppedVc = [super popViewControllerAnimated:animated];
    
    HomePageViewController *homeVc = ((HomePageViewController*)self.parentViewController);
    if ([homeVc.embeddedViewControllersArray containsObject:poppedVc]) {
        [homeVc.embeddedViewControllersArray removeObject:poppedVc];
    }
    
    return poppedVc;
}

- (void)removeFromParentViewController {
    
    [super removeFromParentViewController];
    
}

- (void)dealloc {
    HomePageViewController *homeVc = ((HomePageViewController*)self.parentViewController);
    for (UIViewController *viewController in self.viewControllers) {
        if ([homeVc.embeddedViewControllersArray containsObject:viewController]) {
            [homeVc.embeddedViewControllersArray removeObject:viewController];
        }
    }
}

@end
