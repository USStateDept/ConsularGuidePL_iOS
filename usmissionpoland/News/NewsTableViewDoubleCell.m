//
//  NewsTableViewCell.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 11/19/13.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import "NewsTableViewDoubleCell.h"
#import "RandomNewsImageGenerator.h"

@implementation NewsTableViewDoubleCell

@dynamic leftFeedItem;
@dynamic rightFeedItem;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier leftFeedItem:(RssNewsItem *)leftFeedItem rightFeedItem:(RssNewsItem *)rightFeedItem
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NewsSubCell *leftSubCell = [[NewsSubCell alloc] initWithFeedItem:leftFeedItem];
        [self addSubview:leftSubCell];
        _leftSubCell = leftSubCell;
        
        NewsSubCell *rightSubCell = [[NewsSubCell alloc] initWithFeedItem:rightFeedItem];
        [self addSubview:rightSubCell];
        _rightSubCell = rightSubCell;
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.leftSubCell.frame = CGRectMake(0, 0, self.bounds.size.width/2.0f, self.bounds.size.height);
    self.rightSubCell.frame = CGRectMake(self.bounds.size.width/2.0f, 0, self.bounds.size.width/2.0f, self.bounds.size.height);
}

-(RssNewsItem *)leftFeedItem {
    return self.leftSubCell.feedItem;
}

-(void)setLeftFeedItem:(RssNewsItem *)leftFeedItem {
    self.leftSubCell.feedItem = leftFeedItem;
}

-(RssNewsItem *)rightFeedItem {
    return self.rightSubCell.feedItem;
}

-(void)setRightFeedItem:(RssNewsItem *)rightFeedItem {
    self.rightSubCell.feedItem = rightFeedItem;
}

-(void)resetImages {
    self.leftSubCell.backgroundImageView.image = [RandomNewsImageGenerator image];
    self.rightSubCell.backgroundImageView.image = [RandomNewsImageGenerator image];
}

@end
