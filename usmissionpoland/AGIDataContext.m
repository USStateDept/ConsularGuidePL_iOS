//
//  AGIDataContext.m
//  Intiaro
//
//  Created by Paweł Nowosad on 7/23/13.
//  Copyright (c) 2013 Agitive. All rights reserved.
//

#import "AGIDataContext.h"
#import "AGIJSONInitializableModel.h"
#import "AFURLConnectionOperation.h"

NSString *const APIResultJSON = @"result";
NSString *const APIServerErrorInfo = @"error";

@interface AGIDataContext ()

@end

@implementation AGIDataContext

#pragma mark - Signleton pattern

+ (id)defaultContext
{
    return nil;
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone3
{
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    
    return self;
}

- (NSString *)apiDefaultMethodName
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(@selector(apiDefaultMethodName))];
    
    return nil;
}

- (NSString *)apiModelsArrayParamName
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(@selector(apiModelsArrayParamName))];
    
    return nil;
}

- (void)sendHttpRequestWithParameters:(NSString *)parameters withBlockOnComplete:(void (^)(NSDictionary *))parseJSONFeed
{
    [self sendHttpRequestUsingMethod:[self apiDefaultMethodName] withParameters:parameters withBlockOnComplete:parseJSONFeed];
}

- (void)sendHttpRequestUsingMethod:(NSString *)methodName withParameters:(NSString *)parameters withBlockOnComplete:(void (^)(NSDictionary *))parseJSONFeed
{
    // Create the request.
    NSString *requestParams = [NSString stringWithFormat:@"method=%@", methodName];
    if (parameters)
        requestParams = [NSString stringWithFormat:@"%@&%@", requestParams, parameters];
    NSLog(@"CONTEXT REQUEST PARAMS: %@", requestParams);

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[methodName isEqualToString:@"WatchVideo"]? API_MASTER_POST_DATA_URL : API_POST_DATA_URL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:120];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[requestParams dataUsingEncoding:NSUTF8StringEncoding]];
    
    AFURLConnectionOperation *operation = [[AFURLConnectionOperation alloc] initWithRequest:request];
    
    __weak AFURLConnectionOperation *weakOperation = operation;
    operation.completionBlock = ^()
    {
        AFURLConnectionOperation *operation = weakOperation;
        if (operation.error)
        {
            if (![methodName isEqualToString:@"WatchVideo"]) {
                if (![request.URL.absoluteString isEqualToString:API_POST_DATA_URL] || [[ServerPicker picker] switchServer]) {
                    [self sendHttpRequestUsingMethod:methodName withParameters:parameters withBlockOnComplete:parseJSONFeed];
                }
                else {
                    NSLog(@"Error occured during requesting: %@", operation.error);
                    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
                        UIAlertView *noInternetAlert = [[UIAlertView alloc] initWithTitle:@"Błąd połączenia z serwerem" message:@"Aplikacja napotkała błąd w trakcie łączenia z serwerem. Sprawdź swoje połączenie z internetem" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [noInternetAlert show];
                    }
                    else {
                        UIAlertView *noInternetAlert = [[UIAlertView alloc] initWithTitle:@"Server connection error" message:@"App encountered problems when connecting to server. Check your internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [noInternetAlert show];
                    }
                }
            }
        }
        else
        {
            NSLog(@"JSON request succeeded!");
            NSError *error;
            NSDictionary *serverResponseJSON = [NSJSONSerialization JSONObjectWithData:operation.responseData options:kNilOptions error:&error];
            if (error)
            {
                NSLog(@"ERROR occured during json parsing: %@", error);
                return;
            }

            NSString *serverErrorInfo = [serverResponseJSON objectForKey:APIServerErrorInfo];
            if ([serverErrorInfo isEqual:[NSNull null]])
            {
                NSDictionary *receivedJSON = [serverResponseJSON objectForKey:APIResultJSON];
                if (parseJSONFeed)
                    parseJSONFeed(receivedJSON);
            }
            else
            {
                NSLog(@"AGIDataContext SERVER ERROR MESSAGE: %@", serverResponseJSON);
            }
        }
    };
    
    [operation start];
}

- (void)getDataUsingBlock:(void (^)(NSArray *))setDataBlock
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(@selector(getDataUsingBlock:))];
}

@end
