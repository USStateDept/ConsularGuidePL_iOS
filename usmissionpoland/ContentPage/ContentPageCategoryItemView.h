//
//  ContentPageCategoryItemView.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/7/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageViewBase.h"
#import "ContentPageButtonView.h"

@interface ContentPageCategoryItemView : ContentPageViewBase

@property (nonatomic, copy) NSString *pageToOpenString;
@property (nonatomic, weak) id<ContentPageButtonDelegate> delegate;

- (id)initWithFrame:(CGRect)frame delegate:(id<ContentPageButtonDelegate>)delegate;

@end
