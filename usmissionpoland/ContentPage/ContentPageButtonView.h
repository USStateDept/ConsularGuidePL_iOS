//
//  ContentPageButtonView.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/17/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageViewBase.h"

@protocol ContentPageButtonDelegate <NSObject>

- (void)openPageWithString:(NSString*)pageString;

@end

@interface ContentPageButtonView : ContentPageViewBase

@property (nonatomic, unsafe_unretained) UIButton *button;
@property (nonatomic, unsafe_unretained) UILabel *label;
@property (nonatomic, retain) NSURL *urlToOpen;
@property (nonatomic, copy) NSString *pageToOpenString;

@property (nonatomic, unsafe_unretained) id<ContentPageButtonDelegate>delegate;

- (id)initWithFrame:(CGRect)frame urlString:(NSString*)urlString;
- (id)initWithFrame:(CGRect)frame pageString:(NSString*)pageString delegate:(id)delegate;

@end
