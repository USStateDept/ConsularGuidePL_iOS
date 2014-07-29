//
//  AGILocalVideoModel.h
//  usmissionpoland
//
//  Created by Paweł Nowosad on 12.02.2014.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "AGIVideoModel.h"

@interface AGILocalVideoModel : AGIVideoModel

@property (nonatomic, strong, readonly) NSString *variantURLPostfix;
@property (nonatomic, strong, readonly) NSArray *sourceURLs;

@end
