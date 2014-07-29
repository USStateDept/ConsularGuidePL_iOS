//
//  ContentPageViewBase.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/2/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Pages that are opened with ContentPageViewController need multiple different view types. They are instances of different classes and most of non-label ones are subclasses of this class. */
@interface ContentPageViewBase : UIView

@property (nonatomic, assign) CGFloat leftSubviewOffset;

@end
