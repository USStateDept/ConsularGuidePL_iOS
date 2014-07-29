//
//  RandomNewsImage.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/13/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "RandomNewsImageGenerator.h"

@implementation RandomNewsImageGenerator


+(UIImage*)image {
    static NSMutableArray *imagesArray;
    if (imagesArray == nil || imagesArray.count == 0) {
        imagesArray = [NSMutableArray arrayWithObjects:[UIImage imageNamed:@"Fotolia_41301781_Subscription_Monthly_M.jpg"], [UIImage imageNamed:@"Fotolia_43292397_Subscription_Monthly_M.jpg"], [UIImage imageNamed:@"Fotolia_44298859_Subscription_Monthly_M.jpg"], [UIImage imageNamed:@"Fotolia_45139367_Subscription_Monthly_M.jpg"], [UIImage imageNamed:@"Fotolia_48251624_Subscription_Monthly_M.jpg"], [UIImage imageNamed:@"Fotolia_48272681_Subscription_Monthly_M.jpg"], [UIImage imageNamed:@"Fotolia_48509617_Subscription_Monthly_M.jpg"], [UIImage imageNamed:@"Fotolia_50668438_Subscription_Monthly_M.jpg"], [UIImage imageNamed:@"Fotolia_54480717_Subscription_Monthly_M.jpg"], [UIImage imageNamed:@"Fotolia_54485302_Subscription_Monthly_M.jpg"], [UIImage imageNamed:@"Fotolia_59394340_Subscription_Monthly_M.jpg"], [UIImage imageNamed:@"Fotolia_34843570_Subscription_Monthly.jpg"], nil];
    }
    int randomIndex = arc4random() % imagesArray.count;
    
    UIImage *selectedImage = [imagesArray objectAtIndex:randomIndex];
    [imagesArray removeObjectAtIndex:randomIndex];
    
    return selectedImage;
}

@end
