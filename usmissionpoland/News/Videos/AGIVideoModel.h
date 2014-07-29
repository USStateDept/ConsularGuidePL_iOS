//
//  AGIVideoModel.h
//  usmissionpoland
//
//  Created by Paweł Nowosad on 12.02.2014.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGIJSONInitializableModel.h"
typedef enum
{
    AGILocalVideoType,
    AGIYTVideoType
} AGIVideoType;

@interface AGIVideoModel : NSObject <AGIJSONInitializableModel>

@property (nonatomic, strong, readonly) NSNumber *id;
@property (nonatomic, copy, readonly) NSString *titleEn;
@property (nonatomic, copy, readonly) NSString *titlePl;
@property (nonatomic, assign, readonly) AGIVideoType videoType;
@property (nonatomic, strong, readonly) NSURL *thumbnail;
@property (nonatomic, strong, readonly) NSDate *date;

+ (id)createVideoModelWithJsonFeed:(NSDictionary *)jsonFeed;

- (void)playVideoInViewController:(UIViewController *)viewController;

- (NSString *)localizedTitle;

@end
