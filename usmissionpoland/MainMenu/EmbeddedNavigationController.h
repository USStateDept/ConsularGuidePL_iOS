//
//  EmbeddedNavigationController.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 3/11/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>

/** View of an instance of this class is added as subview to the HomePageViewController's mainContainerView in landscape mode, so that view controllers added to this navigation controller don't take whole screen and the right column is still visible */
@interface EmbeddedNavigationController : UINavigationController

@end
