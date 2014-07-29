//
//  NewsArticleViewController.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 11/20/13.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import "NewsArticleViewController.h"
#import "AFNetworking.h"

typedef enum {
    ParserStateUnknown,
    ParserStateParsingHeader,
    ParserStateParsingDate,
    ParserStateParsingParagraph
} ParserState;

@interface NewsArticleViewController ()

@property (nonatomic, assign) ParserState parserState;
@property (nonatomic, assign) NSUInteger openDivsCount;

@end

@implementation NewsArticleViewController

- (id)initWithFeedItem:(RssNewsItem *)feedItem topImage:(UIImage *)topImage
{
    self = [super init];
    if (self) {
        // Custom initialization
        _feedItem = feedItem;
        _topImage = topImage;
        _parserState = ParserStateUnknown;
        _openDivsCount = 0;
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *topImageView = [[UIImageView alloc] initWithImage:self.topImage];
    topImageView.contentMode = UIViewContentModeScaleAspectFill;
    topImageView.layer.masksToBounds = YES;
    topImageView.frame = CGRectMake(0, self.navBar.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height/5.0f);
    [self.view addSubview:topImageView];
    self.topImageView = topImageView;
    
    CAGradientLayer *imageOverlay = [CAGradientLayer layer];
    imageOverlay.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1 alpha:0].CGColor, (id)[UIColor colorWithWhite:1 alpha:1].CGColor, nil];
    imageOverlay.startPoint = CGPointMake(0.5f, 0.0f);
    imageOverlay.endPoint = CGPointMake(0.5f, 1.0f);
    imageOverlay.frame = topImageView.bounds;
    [topImageView.layer addSublayer:imageOverlay];
    
    UIScrollView *articleScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.navBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.navBar.frame.size.height)];
    articleScrollView.backgroundColor = [UIColor clearColor];
    articleScrollView.contentSize = CGSizeMake(articleScrollView.frame.size.width, self.topImageView.frame.size.height - 20);
    [self.view addSubview:articleScrollView];
    self.articleScrollView = articleScrollView;
    
    UILabel *articleTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, articleScrollView.frame.size.width - 32, 0)];
    articleTitleLabel.backgroundColor = [UIColor clearColor];
    articleTitleLabel.numberOfLines = 0;
    articleTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    articleTitleLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:18];
    articleTitleLabel.text = self.feedItem.titleString;
    [articleScrollView addSubview:articleTitleLabel];
    self.articleTitleLabel = articleTitleLabel;
    
    UIImageView *calendarIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"calendar.png"]];
    calendarIcon.backgroundColor = [UIColor clearColor];
    [articleScrollView addSubview:calendarIcon];
    self.calendarIcon = calendarIcon;
    calendarIcon.hidden = YES;
    
    UILabel *articleDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, articleScrollView.frame.size.width - 55, 0)];
    articleDateLabel.backgroundColor = [UIColor clearColor];
    articleDateLabel.numberOfLines = 0;
    articleDateLabel.lineBreakMode = NSLineBreakByWordWrapping;
    articleDateLabel.font = [UIFont fontWithName:DEFAULT_FONT_BOLD size:13];
    articleDateLabel.textColor = [UIColor grayColor];
    articleDateLabel.text = self.feedItem.dateString;
    [articleScrollView addSubview:articleDateLabel];
    self.articleDateLabel = articleDateLabel;
    
    UILabel *articleTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, articleScrollView.frame.size.width - 30, 0)];
    articleTextLabel.backgroundColor = [UIColor clearColor];
    articleTextLabel.numberOfLines = 0;
    articleTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    articleTextLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:15];
    articleTextLabel.text = self.feedItem.contentString;
    [articleScrollView addSubview:articleTextLabel];
    self.articleTextLabel = articleTextLabel;
    
    
    CGSize titleSize = [self.articleTitleLabel.text sizeWithFont:self.articleTitleLabel.font constrainedToSize:CGSizeMake(self.articleTitleLabel.frame.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.articleTitleLabel.frame = CGRectMake(16, self.articleScrollView.contentSize.height, self.articleTitleLabel.frame.size.width, ceilf(titleSize.height));
    
    self.articleScrollView.contentSize = CGSizeMake(self.articleScrollView.contentSize.width, self.articleScrollView.contentSize.height + self.articleTitleLabel.frame.size.height + 11);
    
    self.calendarIcon.frame = CGRectMake(16, self.articleScrollView.contentSize.height - 2, 18, 17.5f);
    if (articleDateLabel.text != nil) {
        calendarIcon.hidden = NO;
    }
    
    
    
    CGSize dateSize = [self.articleDateLabel.text sizeWithFont:self.articleDateLabel.font constrainedToSize:CGSizeMake(self.articleDateLabel.frame.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.articleDateLabel.frame = CGRectMake(40, self.articleScrollView.contentSize.height, self.articleDateLabel.frame.size.width, ceilf(dateSize.height));
    
    self.articleScrollView.contentSize = CGSizeMake(self.articleScrollView.contentSize.width, self.articleScrollView.contentSize.height + self.articleDateLabel.frame.size.height + 11);
    
    
    
    CGSize textSize = [self.articleTextLabel.text sizeWithFont:self.articleTextLabel.font constrainedToSize:CGSizeMake(self.articleTextLabel.frame.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    self.articleTextLabel.frame = CGRectMake(16, CGRectGetMaxY(self.articleDateLabel.frame) + 11, self.articleTextLabel.frame.size.width, ceilf(textSize.height));
    
    self.articleScrollView.contentSize = CGSizeMake(self.articleScrollView.contentSize.width, CGRectGetMaxY(self.articleTextLabel.frame) + 16);
    
    
    ((UINavigationItem*)self.navBar.items.lastObject).title = articleTitleLabel.text;
}

- (void)didTapRightBarButton {
    [super didTapRightBarButton];
    if (self.languageMenuView) {
        self.languageMenuView.languageEnglishButton.hidden = YES;
        self.languageMenuView.languagePolishButton.hidden = YES;
        self.languageMenuView.separatorLine.hidden = YES;
    }
}

- (void)didChangeLanguage:(NSNotification *)notification {
    //article view should not react in any way to changes in language, hence the empty implementation
}

@end
