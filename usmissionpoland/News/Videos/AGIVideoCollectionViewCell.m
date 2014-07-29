//
//  AGIVideoCollectionViewCell.m
//  usmissionpoland
//
//  Created by Paweł Nowosad on 13.02.2014.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "AGIVideoCollectionViewCell.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "NSDate+LocalizedFormatting.h"
#import "AppDelegate.h"
#import "NSArray+LayoutConstraints.h"

@interface AGIVideoCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImage;
@property (weak, nonatomic) IBOutlet UIImageView *playIcon;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thumbnailHeightConstraint;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *mediumSpaceConstraints;

@end

@implementation AGIVideoCollectionViewCell

+ (CGFloat)textFragmentHeight
{
    CGFloat titleLabelMaxHeight = 70.0f;
    CGFloat dateLabelHeight = 20.0f;
    return titleLabelMaxHeight + dateLabelHeight + 2 * [AppDelegate mediumSpace];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.playIcon setHidden:YES];
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    [self.mediumSpaceConstraints updateLayoutConstraintsWithConstant:[AppDelegate mediumSpace]];
    
    if (!self.thumbnailHeightConstraint)
    {
        self.thumbnailHeightConstraint = [NSLayoutConstraint constraintWithItem:self.thumbnailImage
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.thumbnailImage
                                                                      attribute:NSLayoutAttributeWidth
                                                                     multiplier:9.0f/16.0f
                                                                       constant:0.0f];
        [self.thumbnailImage addConstraint:self.thumbnailHeightConstraint];
    }
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    [self.titleLabel setPreferredMaxLayoutWidth:layoutAttributes.frame.size.width];
}

- (void)setModel:(AGIVideoModel *)model
{
    _model = model;
    
    if (!model)
        return;
    
    [self.titleLabel setText:[_model localizedTitle]];
    
    NSString *dateString = [[_model date] localizedStringWithDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
    [self.dateLabel setText:dateString];
    
    __weak AGIVideoCollectionViewCell *weakSelf = self;
    [self.thumbnailImage setImageWithURL:_model.thumbnail
                               completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
     {
         AGIVideoCollectionViewCell *blockSelf = weakSelf;
         [blockSelf.playIcon setHidden:NO];
     }
             usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
}

- (void)setTitleLabel:(UILabel *)titleLabel
{
    _titleLabel = titleLabel;
}

@end
