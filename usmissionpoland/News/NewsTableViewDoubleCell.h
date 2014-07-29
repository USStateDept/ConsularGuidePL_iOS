//
//  NewsTableViewCell.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 11/19/13.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsSubCell.h"
#import "RssNewsItem.h"

/** Cell containing 2 news downloaded from RSS. */
@interface NewsTableViewDoubleCell : UITableViewCell

@property (nonatomic, unsafe_unretained) NewsSubCell *leftSubCell;
@property (nonatomic, unsafe_unretained) NewsSubCell *rightSubCell;

@property (nonatomic, retain) RssNewsItem *leftFeedItem;
@property (nonatomic, retain) RssNewsItem *rightFeedItem;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier leftFeedItem:(RssNewsItem*)leftFeedItem rightFeedItem:(RssNewsItem*)rightFeedItem;
-(void)resetImages;

@end
