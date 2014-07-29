//
//  AGIFileDownloader.m
//  Intiaro
//
//  Created by Paweł Nowosad on 7/23/13.
//  Copyright (c) 2013 Agitive. All rights reserved.
//

#import "AGIFileDownloader.h"
#import "AFURLConnectionOperation.h"

@implementation AGIFileDownloader

static AGIFileDownloader *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (id)sharedInstance {
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[AGIFileDownloader alloc] init];
    });
    
    return sharedInstance;
}

// We can still have a regular init method, that will get called the first time the Singleton is used.
- (id)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (void)downloadFileFromURL:(NSURL *)fileURL toPath:(NSString *)filePath success:(void (^)())success failure:(void (^)() )failure
{
    NSURLRequest *request = [NSURLRequest requestWithURL:fileURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:120];
    
    AFURLConnectionOperation *operation = [[AFURLConnectionOperation alloc] initWithRequest:request];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
    __weak AFURLConnectionOperation *weakOperation = operation;
    operation.completionBlock = ^()
    {
        AFURLConnectionOperation *operation = weakOperation;
        if (operation.error)
        {
            NSLog(@"Error occured during file downloading: %@", operation.error);
            if (failure)
                failure();
        }
        else
        {
            NSLog(@"File downloaded successfully to: %@", filePath);
            if (success)
                success();
        }
    };
    
    [operation start];
}

@end
