//
//  ContentPageInfoView.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/16/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageViewBase.h"

@class ContentPageInfoDetailView;

/** This view is a box containing a ContentPageInfoContentView instance inside it and an 'i' in a circle icon that, when tapped, makes a detail info view pop up. */
@interface ContentPageInfoView : ContentPageViewBase

@property (nonatomic, retain) ContentPageInfoDetailView *infoDetailView;
@property (nonatomic, unsafe_unretained) UIButton *button;

@end
