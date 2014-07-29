//
//  QAView.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/17/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdditionalContentViewController.h"

/** A single Question-Answer view on an FAQ page */
@interface QAView : UIButton

@property (nonatomic, unsafe_unretained) UILabel *questionLabel;
@property (nonatomic, unsafe_unretained) UIView *answerView;
@property (nonatomic, unsafe_unretained) UIImageView *arrowImageView;

- (id)initWithFrame:(CGRect)frame question:(NSString*)question answer:(NSString*)answer buttonDelegate:(id<ContentPageButtonDelegate>)buttonDelegate;

@end
