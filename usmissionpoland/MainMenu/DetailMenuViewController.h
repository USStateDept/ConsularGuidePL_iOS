//
//  DetailMenuViewController.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 2/26/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Page.h"

/** This is a menu that shows in main area of the app (so fullscreen in landscape mode, or inside EmbeddedViewController in landscape mode) */
@interface DetailMenuViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>

- (id)initWithPage:(Page*)page;

@property (nonatomic, strong) NSMutableArray *menuPagesArray;
@property (nonatomic, strong) NSMutableArray *menuItemsPagesArrays;

@property (nonatomic, strong) NSMutableArray *tableViewsStack;

@end
