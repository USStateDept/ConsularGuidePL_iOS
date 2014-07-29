//
//  NewsSubCell.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 12/2/13.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RssNewsItem.h"

@class NewsSubCell;

@protocol NewsSubCellDelegate <NSObject>

-(void)didSelectNewsSubcell:(NewsSubCell*)newsSubCell;

@end

/** View that represents a single article downloaded from RSS. */
@interface NewsSubCell : UIView

-(id)initWithFeedItem:(RssNewsItem*)feedItem;

@property (nonatomic, strong) RssNewsItem *feedItem;
@property (nonatomic, unsafe_unretained) UILabel *titleLabel;
@property (nonatomic, unsafe_unretained) UIButton *readMoreButton;
@property (nonatomic, unsafe_unretained) UIImageView *moreImageView;
@property (nonatomic, unsafe_unretained) UIImageView *backgroundImageView;
@property (nonatomic, unsafe_unretained) CAGradientLayer *shadowOverlay;

@property (nonatomic, weak) id<NewsSubCellDelegate>delegate;

@end
