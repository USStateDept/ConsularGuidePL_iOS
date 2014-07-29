//
//  ContentPageListButton.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/17/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Page.h"

@interface ContentPageListButton : UIButton

@property (nonatomic, retain) Page *page;
@property (nonatomic, unsafe_unretained) UIImageView *arrowImageView;
@property (nonatomic, unsafe_unretained) UILabel *label;

- (id)initWithFrame:(CGRect)frame page:(Page*)page;

@end
