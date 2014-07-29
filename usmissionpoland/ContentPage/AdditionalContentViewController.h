//
//  AdditionalContentView.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 3/14/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Page.h"
#import "ContentPageViewController.h"
#import "ContentPageButtonView.h"

/** Some pages have extra content that should be displayed in a separate view in a column on right side. This class creates that view from XML string of that additional content. */
@interface AdditionalContentViewController : ContentPageViewController

- (id)initWithFrame:(CGRect)frame contentEN:(NSString*)contentEN contentPL:(NSString*)contentPL buttonDelegate:(id<ContentPageButtonDelegate>)buttonDelegate;

@property (nonatomic, retain) NSString *contentEN;
@property (nonatomic, retain) NSString *contentPL;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, unsafe_unretained) UIView *separatorLine;


@end
