//
//  PdfInfo.h
//  usmissionpoland
//
//  Created by Paweł Nowosad on 10.12.2013.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AGIJSONInitializableModel.h"


@interface PdfInfo : NSManagedObject <AGIJSONInitializableModel>

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * nameEn;
@property (nonatomic, retain) NSString * namePl;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSString * sourceURLEn;
@property (nonatomic, retain) NSString * sourceURLPl;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSNumber * fileVersion;
@property (nonatomic, retain) NSNumber * version;

/*
 *  Properties which aren't stored in context.
 */
@property (nonatomic, assign) BOOL downloadInProgress;
@property (nonatomic, assign, readonly) BOOL isUpdateAvailable;

- (BOOL)updateDataUsingJSON:(NSDictionary *)jsonFeed;

- (NSString *)localizedName;

@end
