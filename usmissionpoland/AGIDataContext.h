//
//  AGIDataContext.h
//  Intiaro
//
//  Created by Paweł Nowosad on 7/23/13.
//  Copyright (c) 2013 Agitive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGIDataContext : NSObject
{
//    @protected
//    NSURL *serverBaseURL;
}

+ (id)defaultContext;

- (NSString *)apiDefaultMethodName;
- (NSString *)apiModelsArrayParamName;

- (void)getDataUsingBlock:(void (^)(NSArray *))setDataBlock;

- (void)sendHttpRequestWithParameters:(NSString *)parameters withBlockOnComplete:(void (^)(NSDictionary *))parseJSONFeed;
- (void)sendHttpRequestUsingMethod:(NSString *)methodName withParameters:(NSString *)parameters withBlockOnComplete:(void (^)(NSDictionary *))parseJSONFeed;

@end
