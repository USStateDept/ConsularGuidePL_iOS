//
//  NewsTableViewTweetCell.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 12/30/13.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import "NewsTableViewTweetCell.h"

@interface NewsTableViewTweetCell ()

@property (nonatomic, unsafe_unretained)UIImageView *twitterLogoView;

@end

@implementation NewsTableViewTweetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.textLabel.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor colorWithRed:0.25f green:0.67f blue:0.94f alpha:1];
        
        UIImageView *twitterLogoView = [[UIImageView alloc] init];
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            twitterLogoView.image = [UIImage imageNamed:@"mobile_icon_twitter.png"];
        }
        else {
            twitterLogoView.image = [UIImage imageNamed:@"tablet_icon_twitter.png"];
        }
        [self addSubview:twitterLogoView];
        self.twitterLogoView = twitterLogoView;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.textLabel.frame = CGRectMake(15, 22, self.frame.size.width - 30, 55);
        self.twitterLogoView.frame = CGRectMake(20, self.frame.size.height - 61 - 4, 75, 61);
        self.textLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:14];
    }
    else {
        self.textLabel.frame = CGRectMake(15, 20, self.frame.size.width * 0.8f - 15, self.frame.size.height - 80);
        self.twitterLogoView.frame = CGRectMake(20, self.frame.size.height - 81 - 20, 100, 81);;
        self.textLabel.font = [UIFont fontWithName:DEFAULT_FONT_REGULAR size:20];
    }
}

@end
