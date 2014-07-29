//
//  Page.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 12/18/13.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Page : NSManagedObject

@property (nonatomic, retain) NSString * contentEN;
@property (nonatomic, retain) NSString * contentPL;
@property (nonatomic, retain) NSString * additionalEN;
@property (nonatomic, retain) NSString * additionalPL;
@property (nonatomic, retain) NSNumber * pageId;
@property (nonatomic, retain) NSString * titleEN;
@property (nonatomic, retain) NSNumber * parentId;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSString * titlePL;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * mapZoom;

- (NSString*)localizedContent;
- (NSString*)localizedTitle;
- (NSString*)localizedAdditionalContent;

- (NSArray*)childrenPagesArray;

@end
