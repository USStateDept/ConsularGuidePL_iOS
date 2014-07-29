//
//  FaqViewController.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/17/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "BaseViewController.h"

/** This class handles FAQ-type pages */
@interface FaqViewController : BaseViewController

@property (nonatomic, unsafe_unretained) UIScrollView *scrollView;

@property (nonatomic, retain) NSMutableArray *qAViewsArray;

@end
