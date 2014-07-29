//
//  VideoViewController.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/23/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "BaseViewController.h"

/** View controller that handles display of Media page */
@interface VideoViewController : BaseViewController <UICollectionViewDataSource, UICollectionViewDelegate>

- (void)didRotateWithPresentedViewControllerVisible:(NSNotification*)notification;

@end
