//
//  APNSInfo.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 11/13/13.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface APNSInfo : NSManagedObject

@property (nonatomic, retain) NSString * deviceToken;

@end
