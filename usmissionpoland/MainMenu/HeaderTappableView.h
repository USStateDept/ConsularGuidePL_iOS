//
//  HeaderTappableView.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 2/28/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HeaderTapDelegate <NSObject>

- (void)didTapHeaderInSection:(NSInteger)section;

@end

/** Header view inside MainMenuViewController's tableView */
@interface HeaderTappableView : UIView

@property (nonatomic, assign) NSInteger section;
@property (nonatomic, retain) UITapGestureRecognizer *headerTapRecognizer;

@property (nonatomic, weak) id <HeaderTapDelegate> delegate;

@end
