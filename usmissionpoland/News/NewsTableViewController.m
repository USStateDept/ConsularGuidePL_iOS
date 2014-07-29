//
//  NewsTableViewController.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 11/19/13.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import "NewsTableViewController.h"
#import "STTwitter.h"
#import "AFNetworking.h"
#import "ALAlertBanner.h"
#import "AppDelegate.h"

@interface NewsTableViewController ()

@end


@implementation NewsTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _newsArrayEN = [NSMutableArray array];
        _newsArrayPL = [NSMutableArray array];
        _tweetsArray = [NSMutableArray array];
        
        _isTripleColumn = NO;
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated {
    CGRect tableRect = self.view.bounds;
    tableRect.origin.y = self.navBar.frame.size.height;
    tableRect.size.height -= self.navBar.frame.size.height;
    
    self.newsTableView.frame = tableRect;
    
    CGRect navbarFrame = self.navBar.frame;
    navbarFrame.size.width = self.view.bounds.size.width;
    self.navBar.frame = navbarFrame;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:POST_NOTIFICATION_NEWS_DID_APPEAR object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:POST_NOTIFICATION_NEWS_DID_DISAPPEAR object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.25f green:0.67f blue:0.94f alpha:1];
    
    
    UITableView *newsTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    newsTableView.dataSource = self;
    newsTableView.delegate = self;
    newsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    newsTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:newsTableView];
    [newsTableView reloadData];
    
    self.newsTableView = newsTableView;
    
    if (self.newsArrayPL.count == 0 || self.newsArrayEN.count == 0 || self.tweetsArray.count == 0) {
        [self loadNewsAndTweets];
    }
    
}

- (void)loadNewsAndTweets {
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:TWITTER_CONSUMER_KEY
                                                            consumerSecret:TWITTER_CONSUMER_SECRET];
    
    //difference between this call to twitter api and the one in loadMoreTweets is that in loadMoreTweets we're specifying maxId
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *bearerToken) {
        
        [twitter getUserTimelineWithScreenName:@"USEmbassyWarsaw"
                                         count:30
                                  successBlock:^(NSArray *statuses) {
                                      if (![statuses isKindOfClass:[NSArray class]] ) {
                                          return;
                                      }
                                      for (NSDictionary *status in statuses) {
                                          if ([status objectForKey:@"retweeted_status"] == nil) {
                                              [self.tweetsArray addObject:status];
                                          }
                                          
                                          NSLog(@"tweet %@", status);
                                      }
                                      NSString *maxId;
                                      if (statuses.count > 0) {
                                          maxId = [statuses.lastObject objectForKey:@"id_str"];
                                      }
                                      else {
                                          maxId = [self.tweetsArray.lastObject objectForKey:@"id_str"];
                                      }
                                      
                                      NSMutableArray *currentNewsArray = [[LanguageSettings sharedSettings] currentLanguage] == LanguageEnglish ? self.newsArrayEN : self.newsArrayPL;
                                      
                                      if (currentNewsArray.count/2 > 0) {
                                          NSMutableArray *visibleTweetCellsIndexPaths = [NSMutableArray array];
                                          for (UITableViewCell *cell in self.newsTableView.visibleCells) {
                                              if (cell.class == [NewsTableViewTweetCell class]) {
                                                  [visibleTweetCellsIndexPaths addObject:[self.newsTableView indexPathForCell:cell]];
                                              }
                                          }
                                          [self.newsTableView reloadRowsAtIndexPaths:visibleTweetCellsIndexPaths withRowAnimation:UITableViewRowAnimationNone];
                                      }
                                      
                                      if (currentNewsArray.count/2 > self.tweetsArray.count) {
                                          [self loadMoreTweetsWithMaxId:maxId];
                                      }
                                  } errorBlock:^(NSError *error) {
                                      NSLog(@"failed to retrieve tweets: %@", [error localizedDescription]);
                                  }];
    } errorBlock:^(NSError *error) {
        NSLog(@"failed to authenticate: %@", [error localizedDescription]);
        
        
        
//        NSString *titleEn = @"Error occurred during downloading from Tweeter";
//        NSString *titlePl = @"Wystąpił błąd podczas ściągania Tweetów";
//        
//        NSString *subtitleEn = @"Please check your Internet connection";
//        NSString *subtitlePl = @"Sprawdź swoje połączenie z Internetem";
//        
//        ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.view
//                                                            style:ALAlertBannerStyleFailure
//                                                         position:ALAlertBannerPositionTop
//                                                            title:([[LanguageSettings sharedSettings] currentLanguage] == LanguageEnglish) ? titleEn : titlePl
//                                                         subtitle:([[LanguageSettings sharedSettings] currentLanguage] == LanguageEnglish) ? subtitleEn : subtitlePl];
//        [banner show];
    }];
    
    
    [self loadNews];
}

- (void)loadNews {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"method": @"GetRssNews"};
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
                [self.newsArrayPL addObject:newsItem];
            }
            else {
                [self.newsArrayEN addObject:newsItem];
            }
        }
        [self.newsTableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"RSS Error: %@", [error localizedDescription]);
        
        if (![operation.request.URL.absoluteString isEqualToString:API_POST_DATA_URL] || [[ServerPicker picker] switchServer]) {
            [self loadNews];
        }
        else {
            [self didEncounterConnectionProblems];
        }
        
//        NSString *titleEn = @"Error occurred during connection with server";
//        NSString *titlePl = @"Wystąpił błąd podczas łączenia z serwerem";
//        
//        NSString *subtitleEn = @"Please check your Internet connection";
//        NSString *subtitlePl = @"Sprawdź swoje połączenie z Internetem";
//        
//        ALAlertBanner *banner = [ALAlertBanner alertBannerForView:self.view
//                                                            style:ALAlertBannerStyleFailure
//                                                         position:ALAlertBannerPositionTop
//                                                            title:([[LanguageSettings sharedSettings] currentLanguage] == LanguageEnglish) ? titleEn : titlePl
//                                                         subtitle:([[LanguageSettings sharedSettings] currentLanguage] == LanguageEnglish) ? subtitleEn : subtitlePl];
//        [banner show];
    }];
}

-(void)didEncounterConnectionProblems {
    UIImageView *connectionProblemsLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder_no-connect.jpg"]];
    connectionProblemsLogo.frame = CGRectMake((self.view.frame.size.width - 153)/2, ceilf(self.view.frame.size.height/2 - 153), 153, 153);
    connectionProblemsLogo.backgroundColor = [UIColor yellowColor];
    [self.view insertSubview:connectionProblemsLogo belowSubview:self.newsTableView];
    self.connectionProblemsLogo = connectionProblemsLogo;
    
    BilingualLabel *connectionProblemsText = [[BilingualLabel alloc] initWithTextEnglish:@"Encountered problems while connecting to the server. Please check your internet connection." polish:@"Napotkano problemy w połączeniu z serwerem. Sprawdź swoje połączenie z internetem."];
    connectionProblemsText.numberOfLines = 0;
    connectionProblemsText.lineBreakMode = NSLineBreakByWordWrapping;
    connectionProblemsText.textColor = [UIColor whiteColor];
    connectionProblemsText.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad ? 26 : 18];
    connectionProblemsText.textAlignment = NSTextAlignmentCenter;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        connectionProblemsText.frame = CGRectMake(floorf(self.view.frame.size.width * 0.125f), CGRectGetMaxY(connectionProblemsLogo.frame) + 2*[AppDelegate mediumSpace], ceilf(self.view.frame.size.width * 0.75f), self.view.frame.size.height - (CGRectGetMaxY(connectionProblemsLogo.frame) + [AppDelegate mediumSpace]) - [AppDelegate veryLargeSpace]);
        [connectionProblemsText sizeToFit];
        CGRect labelRect = connectionProblemsText.frame;
        labelRect.size.width = ceilf(self.view.frame.size.width * 0.75f);
        connectionProblemsText.frame = labelRect;
    }
    else {
        connectionProblemsText.frame = CGRectMake(0, 0, ceilf(self.view.frame.size.width * 0.6f), self.view.frame.size.height);
        [connectionProblemsText sizeToFit];
        connectionProblemsText.center = self.navigationController.view.center;
        connectionProblemsLogo.center = self.navigationController.view.center;
    }
    [self.view insertSubview:connectionProblemsText belowSubview:self.newsTableView];
    connectionProblemsText.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.connectionProblemsText = connectionProblemsText;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *currentNewsArray = [[LanguageSettings sharedSettings] currentLanguage] == LanguageEnglish ? self.newsArrayEN : self.newsArrayPL;
    if (!self.isTripleColumn) {
        return (currentNewsArray.count/2) * 2;  //only even numbers are valid
    }
    else {
        return (currentNewsArray.count/3) * 2;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return 120;
    }
    else {
        if (indexPath.row %2 == 0 || self.isTripleColumn == NO)
            return 235;
        else
            return 156;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row %2 == 0) {
        if (!self.isTripleColumn) {
            NewsTableViewDoubleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsCell"];
            
            NSMutableArray *currentNewsArray = [[LanguageSettings sharedSettings] currentLanguage] == LanguageEnglish ? self.newsArrayEN : self.newsArrayPL;
            RssNewsItem *leftFeedItem = [currentNewsArray objectAtIndex:indexPath.row];
            RssNewsItem *rightFeedItem =[currentNewsArray objectAtIndex:indexPath.row + 1];
            
            if (cell == nil) {
                cell = [[NewsTableViewDoubleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NewsCell" leftFeedItem:leftFeedItem rightFeedItem:rightFeedItem];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            else {
                cell.leftFeedItem = leftFeedItem;
                cell.rightFeedItem = rightFeedItem;
                [cell resetImages];
            }
            
            cell.leftSubCell.delegate = self;
            cell.rightSubCell.delegate = self;
            
            return cell;
        }
        else {
            NewsTableViewTripleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsCell"];
            
            NSMutableArray *currentNewsArray = [[LanguageSettings sharedSettings] currentLanguage] == LanguageEnglish ? self.newsArrayEN : self.newsArrayPL;
            RssNewsItem *leftFeedItem = [currentNewsArray objectAtIndex:(indexPath.row - indexPath.row/2)*3];
            RssNewsItem *middleFeedItem =[currentNewsArray objectAtIndex:(indexPath.row - indexPath.row/2)*3 + 1];
            RssNewsItem *rightFeedItem =[currentNewsArray objectAtIndex:(indexPath.row - indexPath.row/2)*3 + 2];
            
            if (cell == nil) {
                cell = [[NewsTableViewTripleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NewsCell" leftFeedItem:leftFeedItem middleFeedItem:middleFeedItem rightFeedItem:rightFeedItem];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            else {
                cell.leftFeedItem = leftFeedItem;
                cell.middleFeedItem = middleFeedItem;
                cell.rightFeedItem = rightFeedItem;
                [cell resetImages];
            }
            
            cell.leftSubCell.delegate = self;
            cell.middleSubCell.delegate = self;
            cell.rightSubCell.delegate = self;
            
            return cell;
        }
    }
    else {
        NewsTableViewTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
        
        if (cell == nil) {
            cell = [[NewsTableViewTweetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TweetCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (self.tweetsArray.count > indexPath.row/2) {
            cell.textLabel.text = [[self.tweetsArray objectAtIndex:indexPath.row/2] objectForKey:@"text"];
        }
        else {
            cell.textLabel.text = @"";
        }
        
        return cell;
    }
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
                                      if (![statuses isKindOfClass:[NSArray class]]) {
                                          return;
                                      }
                                      for (int i = 1; i < statuses.count; ++i) {
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
                                      NSMutableArray *currentNewsArray = [[LanguageSettings sharedSettings] currentLanguage] == LanguageEnglish ? self.newsArrayEN : self.newsArrayPL;
                                      if (currentNewsArray.count/2 > 0) {
                                          for (UITableViewCell *cell in self.newsTableView.visibleCells) {
                                              if (cell.class == [NewsTableViewTweetCell class]) {
                                                  NSIndexPath *indexPath = [self.newsTableView indexPathForCell:cell];
                                                  if (self.tweetsArray.count > indexPath.row/2) {
                                                      cell.textLabel.text = [[self.tweetsArray objectAtIndex:indexPath.row/2] objectForKey:@"text"];
                                                  }
                                                  else {
                                                      cell.textLabel.text = @"";
                                                  }
                                              }
                                          }
                                      }
                                      if (currentNewsArray.count/2 > self.tweetsArray.count) {
                                          [self loadMoreTweetsWithMaxId:maxId];
                                      }
                                  } errorBlock:^(NSError *error) {
                                      NSLog(@"failed to retrieve tweets");
                                  }];
    } errorBlock:^(NSError *error) {
        NSLog(@"failed to authenticate");
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row %2 == 0) {
        return;
    }
    
    NSString *tweetId = [[self.tweetsArray objectAtIndex:indexPath.row/2] objectForKey:@"id_str"];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitter://status?id=%@", tweetId]]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"twitter://status?id=%@", tweetId]]];
    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.twitter.com/USEmbassyWarsaw/status/%@", tweetId]]];
    }
}

- (NSString*)stringAddressFromGuidString:(NSString*)guid {
    if (guid != nil && guid.length > 0 && [guid characterAtIndex:0] == '/') {
        if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
            return [@"http://polish.poland.usembassy.gov" stringByAppendingString:guid];
        }
        else {
            return [@"http://poland.usembassy.gov" stringByAppendingString:guid];
        }
    }
    else {
        return guid;
    }
}

- (void)didSelectNewsSubcell:(NewsSubCell *)newsSubCell {
    if (self.embeddingViewController != nil) {
        [self.embeddingViewController openNewsArticleWithFeedItem:newsSubCell.feedItem topImage:newsSubCell.backgroundImageView.image];
    }
    else {
        NewsArticleViewController *articleViewController = [[NewsArticleViewController alloc] initWithFeedItem:newsSubCell.feedItem topImage:newsSubCell.backgroundImageView.image];
        [self.navigationController pushViewController:articleViewController animated:YES];
    }
}

- (void)didChangeLanguage:(NSNotification *)notification {
    [super didChangeLanguage:notification];
    
    [self.newsTableView reloadData];
    
}

@end
