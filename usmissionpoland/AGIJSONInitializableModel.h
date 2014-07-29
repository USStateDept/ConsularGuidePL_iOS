//
//  AGIJSONInitializableModel.h
//  Intiaro
//
//  Created by Paweł Nowosad on 7/23/13.
//  Copyright (c) 2013 Agitive. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AGIJSONInitializableModel <NSObject>

- (instancetype)initWithJSON:(NSDictionary *)jsonFeed;

@optional

- (void)loadDataFromJSON:(NSDictionary *)jsonFeed;

@end
