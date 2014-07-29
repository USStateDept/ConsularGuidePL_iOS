//
//  NewsSubCell.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 12/2/13.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import "NewsSubCell.h"
#import "RandomNewsImageGenerator.h"

@implementation NewsSubCell

- (id)initWithFeedItem:(RssNewsItem *)feedItem
{
    self = [super init];
    if (self) {
        // Initialization code
        _feedItem = feedItem;
        
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[RandomNewsImageGenerator image]];
        backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        backgroundImageView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1];
        backgroundImageView.layer.masksToBounds = YES;
        [self addSubview:backgroundImageView];
        self.backgroundImageView = backgroundImageView;
        
        CAGradientLayer *shadowOverlay = [CAGradientLayer layer];
        shadowOverlay.colors = [[NSArray alloc] initWithObjects:(id)[UIColor colorWithWhite:0 alpha:0.75f].CGColor, (id)[UIColor colorWithWhite:0 alpha:0].CGColor, nil];
        shadowOverlay.startPoint = CGPointMake(0, 0.5f);
        shadowOverlay.endPoint = CGPointMake(1.0f, 0.5f);
        [backgroundImageView.layer addSublayer:shadowOverlay];
        self.shadowOverlay = shadowOverlay;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = feedItem.titleString;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.numberOfLines = 4;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;

        
        UIImageView *moreImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mobile_icon_more.png"]];
        moreImageView.frame = CGRectMake(0, 0, 18, 18);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            moreImageView.image = [UIImage imageNamed:@"tablet_icon_alert_more.png"];
            moreImageView.frame = CGRectMake(0, 0, 24, 24);
        }
        moreImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:moreImageView];
        self.moreImageView = moreImageView;
        
        UIButton *readMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        readMoreButton.backgroundColor = [UIColor clearColor];
        [readMoreButton addTarget:self action:@selector(didSelectSubCell) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:readMoreButton];
        self.readMoreButton = readMoreButton;
    }
    return self;
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.backgroundImageView.frame = self.bounds;
    self.shadowOverlay.frame = self.backgroundImageView.bounds;
    self.readMoreButton.frame = self.bounds;
    self.moreImageView.frame = CGRectMake(ceilf(self.frame.size.width - self.moreImageView.frame.size.width * 1.5f), ceilf(self.frame.size.height - self.moreImageView.frame.size.height * 1.5f), self.moreImageView.frame.size.width, self.moreImageView.frame.size.height);
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.titleLabel.frame = CGRectMake(frame.size.width / 20.0f, frame.size.height / 10.0f, frame.size.width * 0.9f, frame.size.height/2.0f);
        self.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:12];
    }
    else {
        self.titleLabel.frame = CGRectMake(15, 20, frame.size.width * 0.8f - 15, frame.size.height - 40);
        self.titleLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:20];
    }
    
}

-(void)setFeedItem:(RssNewsItem *)feedItem{
    _feedItem = feedItem;
    self.titleLabel.text = feedItem.titleString;
}

-(void)didSelectSubCell {
    [self.delegate didSelectNewsSubcell:self];
}

@end
