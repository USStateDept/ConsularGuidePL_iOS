//
//  AGIHorizontalParallaxViewController.m
//  usmissionpoland
//
//  Created by Paweł Nowosad on 04.03.2014.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "AGIHorizontalParallaxViewController.h"
#import "NSArray+LayoutConstraints.h"
#import "AppDelegate.h"

@interface AGIHorizontalParallaxViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;

@property (weak, nonatomic) IBOutlet UIPageControl *contentPageControl;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *largeSpaceConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *veryLargeSpaceConstraints;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageScrollViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageScrollViewYConstraint;

@property (weak, nonatomic) UIImageView *parallaxImage;

@property (strong, nonatomic) NSArray *contentViews;
@property (nonatomic, assign, readwrite) CGSize contentBounds;

@end

@implementation AGIHorizontalParallaxViewController

- (instancetype)initWithContentViews:(NSArray *)views
{
    self = [super initWithNibName:@"AGIHorizontalParallaxViewController" bundle:nil];
    if (self)
    {
        self.contentViews = views;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    UIImageView *imageView;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"banner-welcome-1690x574.png"]];
        
    }
    else {
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"banner-welcome-704x269.png"]];
    }
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    self.parallaxImage = imageView;
    
    [self.imageScrollView addSubview:imageView];
    [self.imageScrollView setContentSize:self.parallaxImage.frame.size];

    [self.contentScrollView setDelegate:self];
    [self loadContentViews:self.contentViews];
}

- (void)loadContentViews:(NSArray *)contentViews
{
    self.contentViews = contentViews;
    
    for (UIView *contentView in self.contentViews)
    {
        [self.contentScrollView addSubview:contentView];
    }
    
    [self.contentPageControl setNumberOfPages:[self.contentViews count]];
    [self.contentPageControl setCurrentPage:0];
}

- (void)updateContentViewsLayout
{
    CGFloat contentTopInset = CGRectGetHeight(self.imageScrollView.frame) + [AppDelegate largeSpace];
    [self.contentScrollView setContentInset:UIEdgeInsetsMake(contentTopInset, 0.0f, 0.0f, 0.0f)];
    
    NSInteger i = 0;
    CGFloat scrollWidth = CGRectGetWidth(self.contentScrollView.bounds);
    CGFloat contentWidth = scrollWidth - 2 * [AppDelegate largeSpace];
    CGFloat contentHeight = CGRectGetHeight(self.contentScrollView.frame) - contentTopInset;
    CGSize contentSize = CGSizeMake(contentWidth, contentHeight);
    self.contentBounds = contentSize;
    for (UIView *contentView in self.contentViews)
    {
        CGRect contentViewFrame = (CGRect){ .origin = CGPointMake(i * scrollWidth + [AppDelegate largeSpace], 0.0f), .size = contentSize };
        [contentView setFrame:contentViewFrame];
        
        ++i;
    }
    CGSize newContentSize = CGSizeApplyAffineTransform(self.contentScrollView.bounds.size, CGAffineTransformMakeScale(i, 1.0f));
    newContentSize.height = contentHeight;
    [self.contentScrollView setContentSize:newContentSize];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    [self.largeSpaceConstraints updateLayoutConstraintsWithConstant:[AppDelegate largeSpace]];
    [self.veryLargeSpaceConstraints updateLayoutConstraintsWithConstant:[AppDelegate veryLargeSpace]];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.imageScrollViewHeightConstraint.constant = 135;
        self.imageScrollViewYConstraint.constant = 75;
    }
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat parallaxImageWidth = 1.1f * CGRectGetWidth(self.imageScrollView.bounds);
    CGFloat parallaxImageHeight = CGRectGetHeight(self.imageScrollView.bounds);
    CGSize parallaxImageSize = CGSizeMake(parallaxImageWidth, parallaxImageHeight);
    [self.parallaxImage setFrame:(CGRect){ .origin = CGPointZero, .size = parallaxImageSize }];
    [self.imageScrollView setContentSize:parallaxImageSize];
    
    [self updateContentViewsLayout];
    
    if (self.contentScrollView.contentOffset.x > 0) {
        self.contentScrollView.contentOffset = CGPointMake(self.contentScrollView.contentSize.width/2, self.contentScrollView.contentOffset.y);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.contentScrollView) {
        CGFloat contentScrollingRange = self.contentScrollView.contentSize.width - CGRectGetWidth(self.contentScrollView.frame);
        CGFloat imageScrollingRange = self.imageScrollView.contentSize.width - CGRectGetWidth(self.imageScrollView.frame);
        CGFloat scrollingPercentage = self.contentScrollView.contentOffset.x / contentScrollingRange;
        self.imageScrollView.contentOffset = CGPointMake(scrollingPercentage * imageScrollingRange, 0.0f);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.contentScrollView) {
        CGFloat currentPage = self.contentScrollView.contentOffset.x / CGRectGetWidth(self.contentScrollView.bounds);
        [self.contentPageControl setCurrentPage:currentPage];
    }
    
}

@end
