//
//  ContentPageInfoDetailView.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/16/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageInfoView.h"

/** This class pops up when 'i' button is tapped inside the corresponding ContentPageInfoView instance. Unlike all other ContentPageViewBase subclasses, this one isn't added as a subview to the ContentPageViewController's scrollView, but rather to its ContentPageViewController's view directly */
@interface ContentPageInfoDetailView : ContentPageInfoView

@property (nonatomic, weak) UIView *shadowOverlay;

@end
