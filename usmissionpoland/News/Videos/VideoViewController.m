//
//  VideoViewController.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/23/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "VideoViewController.h"
#import "AFNetworking.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AGIVideoCollectionViewCell.h"
#import "AGIVideoContext.h"
#import "NSDate+LocalizedFormatting.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "AppDelegate.h"
#import "NSArray+LayoutConstraints.h"


@interface VideoViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) NSLayoutConstraint *collectionViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *recentVideoLabel;
@property (weak, nonatomic) IBOutlet UILabel *mostViewedLabel;

@property (weak, nonatomic) IBOutlet UIImageView *mostViewedThumbnail;
@property (weak, nonatomic) IBOutlet UIImageView *mostViewedPlayIcon;
@property (weak, nonatomic) IBOutlet UILabel *mostviewedTitle;
@property (weak, nonatomic) IBOutlet UILabel *mostViewedDate;
@property (weak, nonatomic) NSLayoutConstraint *mostViewedThumbnailHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollVIew;
@property (weak, nonatomic) IBOutlet UIView *contentVIew;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *smallSpaceConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *mediumSpaceConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *bigSpaceConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *xxlSpaceConstraints;

@property (nonatomic, strong) NSArray *recentVideos;
@property (nonatomic, strong) AGIVideoModel *mostViewedVideo;


@property (nonatomic, assign) BOOL didRotateWhilePresentingVideo;
@property (nonatomic, assign) UIInterfaceOrientation orientationBeforePlayingVideo;


@end


@implementation VideoViewController

static NSString *const recentVideoCellIdentifier = @"recentVideoCell";
static NSString *const recentVideoCellNibName = @"RecentVideoCollectionViewCell";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)dealloc
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:POST_NOTIFICATION_SWITCH_LANGUAGE
                                                  object:nil];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    [self.smallSpaceConstraints updateLayoutConstraintsWithConstant:[AppDelegate smallSpace]];
    [self.mediumSpaceConstraints updateLayoutConstraintsWithConstant:[AppDelegate mediumSpace]];
    [self.bigSpaceConstraints updateLayoutConstraintsWithConstant:[AppDelegate largeSpace]];
    [self.xxlSpaceConstraints updateLayoutConstraintsWithConstant:[AppDelegate veryLargeSpace]];
    
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat cellWidth = viewWidth / 2.5f;
    CGFloat cellThumbnailHeight = (9.0f * cellWidth) / 16.0f;
    CGFloat cellHeight = cellThumbnailHeight + [AGIVideoCollectionViewCell textFragmentHeight];
    
    if (!self.collectionViewHeightConstraint)
    {
        self.collectionViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.view
                                                                           attribute:NSLayoutAttributeWidth
                                                                          multiplier:9.0f/(16.0f * 2.5f)
                                                                            constant:[AGIVideoCollectionViewCell textFragmentHeight]];
        [self.view addConstraint:self.collectionViewHeightConstraint];
    }
    
    CGFloat veryLargeSpace = [AppDelegate veryLargeSpace];
    UICollectionViewLayout *layout = [self.collectionView collectionViewLayout];
    if ([layout isKindOfClass:[UICollectionViewFlowLayout class]])
    {
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)layout;
        flowLayout.itemSize = CGSizeMake(cellWidth, cellHeight);
        flowLayout.sectionInset = UIEdgeInsetsMake(0.0f, veryLargeSpace, 0.0f, veryLargeSpace);
    }
    
    if (!self.mostViewedThumbnailHeightConstraint)
    {
        self.mostViewedThumbnailHeightConstraint = [NSLayoutConstraint constraintWithItem:self.mostViewedThumbnail
                                                                                attribute:NSLayoutAttributeHeight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.mostViewedThumbnail
                                                                                attribute:NSLayoutAttributeWidth
                                                                               multiplier:9.0f/16.0f
                                                                                 constant:0];
        [self.mostViewedThumbnail addConstraint:self.mostViewedThumbnailHeightConstraint];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self localizeView];
    
    UIView *contentView = self.view;
    self.contentVIew = contentView;
    
    UIView *mainView = [[UIView alloc] initWithFrame:self.contentVIew.frame];
    mainView.backgroundColor = [UIColor whiteColor];
    [self setView:mainView];
    self.mainView = mainView;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [scrollView setBackgroundColor:[UIColor whiteColor]];
    [scrollView addSubview:contentView];
    [mainView addSubview:scrollView];
    self.scrollVIew = scrollView;
    
    CGRect mostViewedDateFrame = self.mostViewedDate.frame;
    CGFloat contentViewHeight = mostViewedDateFrame.origin.y + mostViewedDateFrame.size.height;
    [scrollView setContentSize:CGSizeMake(contentView.frame.size.width, contentViewHeight)];
    
    [mainView addSubview:self.navBar];
    
    UINib *recentVideoCellNib = [UINib nibWithNibName:recentVideoCellNibName bundle:nil];
    [self.collectionView registerNib:recentVideoCellNib forCellWithReuseIdentifier:recentVideoCellIdentifier];
    
    __weak VideoViewController *weakSelf = self;
    [[AGIVideoContext defaultContext] getAllVideosUsingBlock:^(AGIVideoModel *mostViewed, NSArray *recentVideos)
    {
        VideoViewController *blockSelf = weakSelf;
        
        blockSelf.mostViewedVideo = mostViewed;
        
        blockSelf.recentVideos = recentVideos;
        [blockSelf.collectionView reloadData];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localizeViewWithNotification:)
                                                 name:POST_NOTIFICATION_SWITCH_LANGUAGE
                                               object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat navBarHeight = CGRectGetHeight(self.navBar.frame);
    CGRect newScrollViewFrame = (CGRect){ .origin = CGPointMake(0.0f, navBarHeight), .size = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - navBarHeight) };
    [self.scrollVIew setFrame:newScrollViewFrame];
    
    CGRect mostViewedDateFrame = self.mostViewedDate.frame;
    CGFloat contentViewHeight = mostViewedDateFrame.origin.y + mostViewedDateFrame.size.height + [AppDelegate largeSpace];
    CGRect newContentViewFrame = (CGRect){ .origin = CGPointZero, .size = CGSizeMake(self.view.frame.size.width, contentViewHeight) };
    [self.contentVIew setFrame:newContentViewFrame];
    [self.scrollVIew setContentSize:newContentViewFrame.size];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self.view setNeedsUpdateConstraints];
}

- (void)setMostViewedVideo:(AGIVideoModel *)mostViewedVideo
{
    _mostViewedVideo = mostViewedVideo;
    
    if (!_mostViewedVideo)
        return;
    
    [self localizeMostViewedVideo];
    
    __weak VideoViewController *weakSelf = self;
    [self.mostViewedPlayIcon setHidden:YES];
    [self.mostViewedThumbnail setImageWithURL:_mostViewedVideo.thumbnail
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
    {
        VideoViewController *blockSelf = weakSelf;
        
        [blockSelf.mostViewedPlayIcon setHidden:NO];
    }
                  usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

#pragma mark - Actions

- (IBAction)playMostViewedVideo
{
    self.didRotateWhilePresentingVideo = NO;
    self.orientationBeforePlayingVideo = self.interfaceOrientation;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotateWithPresentedViewControllerVisible:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [self.mostViewedVideo playVideoInViewController:self];
    
    [[AGIVideoContext defaultContext] reportWatchedVideo:self.mostViewedVideo];
}

#pragma mark - Localization

- (void)localizeView
{
    [self.collectionView reloadData];
    
    [self localizeMostViewedLabel];
    [self localizeMostViewedVideo];
    [self localizeRecentVideoLabel];
}

- (void)localizeViewWithNotification:(NSNotification *)notification
{
    [self localizeView];
}

- (void)localizeRecentVideoLabel
{
    NSString *labelText;
    switch ([[LanguageSettings sharedSettings] currentLanguage])
    {
        case LanguagePolish:
            labelText = @"Najnowsze filmy";
            break;
            
        default:
            labelText = @"Recent video";
            break;
    }
    [self.recentVideoLabel setText:labelText];
}

- (void)localizeMostViewedLabel
{
    NSString *labelText;
    switch ([[LanguageSettings sharedSettings] currentLanguage])
    {
        case LanguagePolish:
            labelText = @"Najczęściej oglądane";
            break;
            
        default:
            labelText = @"Most viewed";
            break;
    }
    [self.mostViewedLabel setText:labelText];
}

- (void)localizeMostViewedVideo
{
    if (!self.mostViewedVideo)
        return;
    
    [self.mostviewedTitle setText:self.mostViewedVideo.localizedTitle];
    [self.mostViewedDate setText:[self.mostViewedVideo.date localizedStringWithDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle]];
    
    [self.mostviewedTitle sizeToFit];
    [self.mostViewedDate sizeToFit];
    [self.view setNeedsLayout];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (!self.recentVideos.count) {
        return 3;
    }
    return [self.recentVideos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AGIVideoCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:recentVideoCellIdentifier forIndexPath:indexPath];
    cell.model = self.recentVideos[indexPath.item];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AGIVideoModel *video = self.recentVideos[indexPath.item];
    self.didRotateWhilePresentingVideo = NO;
    self.orientationBeforePlayingVideo = self.interfaceOrientation;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotateWithPresentedViewControllerVisible:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [video playVideoInViewController:self];
    
    [[AGIVideoContext defaultContext] reportWatchedVideo:video];
}

- (void)makeNavigationBar {
    [super makeNavigationBar];
    self.navBar.autoresizingMask = self.navBar.autoresizingMask | UIViewAutoresizingFlexibleWidth;
}

- (void)didRotateWithPresentedViewControllerVisible:(NSNotification*)notification {
    self.didRotateWhilePresentingVideo = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && self.didRotateWhilePresentingVideo) {
        self.didRotateWhilePresentingVideo = NO;
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
        
        UIViewController *mVC = [[UIViewController alloc] init];
        [self presentViewController:mVC animated:NO completion:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && self.didRotateWhilePresentingVideo && UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        self.didRotateWhilePresentingVideo = NO;
        [self updateViewConstraints];
        [self.view setNeedsUpdateConstraints];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.didRotateWhilePresentingVideo) {
        [self didRotateFromInterfaceOrientation:self.orientationBeforePlayingVideo];
    }
}

@end
