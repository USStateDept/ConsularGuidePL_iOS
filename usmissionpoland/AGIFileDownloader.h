//
//  AGIFileDownloader.h
//  Intiaro
//
//  Created by Paweł Nowosad on 7/23/13.
//  Copyright (c) 2013 Agitive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGIFileDownloader : NSObject

+ (id)sharedInstance;

- (void)downloadFileFromURL:(NSURL *)fileURL toPath:(NSString *)filePath success:(void (^)())success failure:(void (^)() )failure;

@end
