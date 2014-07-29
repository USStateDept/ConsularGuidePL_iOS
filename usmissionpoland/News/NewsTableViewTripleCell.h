//
//  NewsTableViewTripleCell.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 2/11/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsSubCell.h"

/** Cell containing 3 news downloaded from RSS. */
@interface NewsTableViewTripleCell : UITableViewCell

@property (nonatomic, unsafe_unretained) NewsSubCell *leftSubCell;
@property (nonatomic, unsafe_unretained) NewsSubCell *middleSubCell;
@property (nonatomic, unsafe_unretained) NewsSubCell *rightSubCell;

@property (nonatomic, retain) RssNewsItem *leftFeedItem;
@property (nonatomic, retain) RssNewsItem *middleFeedItem;
@property (nonatomic, retain) RssNewsItem *rightFeedItem;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier leftFeedItem:(RssNewsItem*)leftFeedItem middleFeedItem:(RssNewsItem*)middleFeedItem rightFeedItem:(RssNewsItem*)rightFeedItem;
-(void)resetImages;

@end
