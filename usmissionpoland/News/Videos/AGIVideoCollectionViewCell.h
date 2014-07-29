//
//  AGIVideoCollectionViewCell.h
//  usmissionpoland
//
//  Created by Paweł Nowosad on 13.02.2014.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGIVideoModel.h"

@interface AGIVideoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) AGIVideoModel *model;

+ (CGFloat)textFragmentHeight;

@end
