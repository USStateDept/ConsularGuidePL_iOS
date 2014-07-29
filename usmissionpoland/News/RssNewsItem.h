//
//  RssNewsItem.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 2/5/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Represents a single article from RSS feed. */
@interface RssNewsItem : NSObject

@property (nonatomic, assign) Language language;
@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, copy) NSString *dateString;
@property (nonatomic, copy) NSString *contentString;

@end
