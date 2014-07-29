//
//  MainMenuAlertView.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/21/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>

/** Used to display alert banners on home page */
@interface MainMenuAlertView : UIView

@property (nonatomic, unsafe_unretained) UIImageView *backgroundImageView;
@property (nonatomic, unsafe_unretained) BilingualLabel *backgroundLabel;
@property (nonatomic, unsafe_unretained) BilingualLabel *titleLabel;
@property (nonatomic, unsafe_unretained) BilingualLabel *descriptionLabel;
@property (nonatomic, unsafe_unretained) BilingualLabel *alertTypeLabel;
@property (nonatomic, unsafe_unretained) UIButton *closeButton;
@property (nonatomic, unsafe_unretained) UIImageView *closeImageView;

- (void)show;
- (void)hide;

@end
