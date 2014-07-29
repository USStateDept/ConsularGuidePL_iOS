//
//  NewsTableViewTripleCell.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 2/11/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "NewsTableViewTripleCell.h"
#import "RandomNewsImageGenerator.h"

@implementation NewsTableViewTripleCell

@dynamic leftFeedItem;
@dynamic rightFeedItem;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier leftFeedItem:(RssNewsItem *)leftFeedItem middleFeedItem:(RssNewsItem *)middleFeedItem rightFeedItem:(RssNewsItem *)rightFeedItem {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        NewsSubCell *leftSubCell = [[NewsSubCell alloc] initWithFeedItem:leftFeedItem];
        [self addSubview:leftSubCell];
        _leftSubCell = leftSubCell;
        
        NewsSubCell *middleSubCell = [[NewsSubCell alloc] initWithFeedItem:middleFeedItem];
        [self addSubview:middleSubCell];
        _middleSubCell = middleSubCell;
        
        NewsSubCell *rightSubCell = [[NewsSubCell alloc] initWithFeedItem:rightFeedItem];
        [self addSubview:rightSubCell];
        _rightSubCell = rightSubCell;
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.leftSubCell.frame = CGRectMake(0, 0, self.bounds.size.width/3.0f, self.bounds.size.height);
    self.middleSubCell.frame = CGRectMake(self.leftSubCell.frame.size.width, 0, self.leftSubCell.frame.size.width, self.bounds.size.height);
    self.rightSubCell.frame = CGRectMake(self.middleSubCell.frame.origin.x + self.middleSubCell.frame.size.width, 0, self.bounds.size.width - self.middleSubCell.frame.origin.x - self.middleSubCell.frame.size.width, self.bounds.size.height);
}

-(RssNewsItem *)leftFeedItem {
    return self.leftSubCell.feedItem;
}

-(void)setLeftFeedItem:(RssNewsItem *)middleFeedItem {
    self.leftSubCell.feedItem = middleFeedItem;
}

-(RssNewsItem *)middleFeedItem {
    return self.middleSubCell.feedItem;
}

-(void)setMiddleFeedItem:(RssNewsItem *)middleFeedItem {
    self.middleSubCell.feedItem = middleFeedItem;
}


-(RssNewsItem *)rightFeedItem {
    return self.rightSubCell.feedItem;
}

-(void)setRightFeedItem:(RssNewsItem *)rightFeedItem {
    self.rightSubCell.feedItem = rightFeedItem;
}

-(void)resetImages {
    self.leftSubCell.backgroundImageView.image = [RandomNewsImageGenerator image];
    self.middleSubCell.backgroundImageView.image = [RandomNewsImageGenerator image];
    self.rightSubCell.backgroundImageView.image = [RandomNewsImageGenerator image];
}

@end
