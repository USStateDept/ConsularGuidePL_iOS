//
//  MainMenuViewController.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 2/25/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Page.h"
#import "HeaderTappableView.h"

/** This class manages the app's side menu. */
@interface MainMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, HeaderTapDelegate>

@property (nonatomic, unsafe_unretained) UITableView *tableView;


@property (nonatomic, retain) NSArray *generalInfoPages;
@property (nonatomic, retain) NSArray *visasPages;
@property (nonatomic, retain) NSArray *acsPages;
@property (nonatomic, retain) NSArray *newsPages;
@property (nonatomic, retain) NSArray *visaStatusPages;

@property (nonatomic, retain) NSArray *allPages;

@property (nonatomic, retain) NSMutableArray *isSectionOpenArray;


@property (nonatomic, unsafe_unretained) UIView *languageBar;

@property (nonatomic, weak) UIButton *languageEnglishButton;
@property (nonatomic, weak) UIButton *languagePolishButton;
@property (nonatomic, unsafe_unretained) UIView *languageButtonsSeparator;

@end
