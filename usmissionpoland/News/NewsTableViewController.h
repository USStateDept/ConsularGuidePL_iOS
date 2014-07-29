//
//  NewsTableViewController.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 11/19/13.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "NewsTableViewDoubleCell.h"
#import "NewsTableViewTripleCell.h"
#import "NewsTableViewTweetCell.h"
#import "NewsArticleViewController.h"

/** View controller containing news - even rows contain one tweet, uneven contain 2 news from RSS feed (3 if in landscape mode). */
@interface NewsTableViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate, NewsSubCellDelegate>

@property (nonatomic, strong) UITableView *newsTableView;
@property (nonatomic, retain) NSMutableArray *newsArrayEN;
@property (nonatomic, retain) NSMutableArray *newsArrayPL;
@property (nonatomic, retain) NSMutableArray *tweetsArray;

@property (nonatomic, assign) BOOL isTripleColumn;

@property (nonatomic, weak) UIImageView *connectionProblemsLogo;
@property (nonatomic, weak) BilingualLabel *connectionProblemsText;

@end
