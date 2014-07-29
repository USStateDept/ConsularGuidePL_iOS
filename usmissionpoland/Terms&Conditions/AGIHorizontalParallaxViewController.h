//
//  AGIHorizontalParallaxViewController.h
//  usmissionpoland
//
//  Created by Paweł Nowosad on 04.03.2014.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGIHorizontalParallaxViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, assign, readonly) CGSize contentBounds;

- (instancetype)initWithContentViews:(NSArray *)views;

- (void)loadContentViews:(NSArray *)contentViews;

@end
