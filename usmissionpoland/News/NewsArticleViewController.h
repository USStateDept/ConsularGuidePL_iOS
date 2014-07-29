//
//  NewsArticleViewController.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 11/20/13.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "RssNewsItem.h"

/** View controller that displays a single article content. */
@interface NewsArticleViewController : BaseViewController <NSXMLParserDelegate>

@property (nonatomic, retain) RssNewsItem *feedItem;
@property (nonatomic, strong) UIImage *topImage;
@property (nonatomic, unsafe_unretained) UIImageView *topImageView;
@property (nonatomic, unsafe_unretained) UIScrollView *articleScrollView;
@property (nonatomic, unsafe_unretained) UILabel *articleTitleLabel;
@property (nonatomic, unsafe_unretained) UIImageView *calendarIcon;
@property (nonatomic, unsafe_unretained) UILabel *articleDateLabel;
@property (nonatomic, unsafe_unretained) UILabel *articleTextLabel;

-(id)initWithFeedItem:(RssNewsItem*)feedItem topImage:(UIImage*)topImage;

@end
