//
//  AGIFileManager.m
//  Intiaro
//
//  Created by Paweł Nowosad on 8/8/13.
//  Copyright (c) 2013 Agitive. All rights reserved.
//

#import "AGIFileManager.h"
#import "AGIFileDownloader.h"

@implementation AGIFileManager

static AGIFileManager *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (id)sharedInstance {
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[AGIFileManager alloc] init];
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

#pragma mark - Managing pdf files

- (void)downloadPdfFiles:(PdfInfo *)pdfInfo complete:(void (^)(BOOL))complete
{
    __weak AGIFileManager *weakSelf = self;
    void (^downloadPolishFile)() = ^
    {
        AGIFileManager *blockSelf = weakSelf;
        
        if ([pdfInfo sourceURLPl])
        {
            [[AGIFileDownloader sharedInstance] downloadFileFromURL:[NSURL URLWithString:[pdfInfo sourceURLPl]]
                                                             toPath:[blockSelf filePathForPdf:pdfInfo forLanguage:LanguagePolish]
                                                            success:^
             {
                 if (complete)
                     complete(YES);
             }
                                                            failure:^
             {
                 if (complete)
                     complete(NO);
             }];
        }
        else if (complete)
        {
            complete(YES);
        }
    };
    
    if ([pdfInfo sourceURLEn])
    {
        [[AGIFileDownloader sharedInstance] downloadFileFromURL:[NSURL URLWithString:[pdfInfo sourceURLEn]]
                                                         toPath:[self filePathForPdf:pdfInfo forLanguage:LanguageEnglish]
                                                        success:^
         {
             downloadPolishFile();
         }
                                                        failure:^
         {
             if (complete)
                 complete(NO);
         }];
    }
    else
    {
        downloadPolishFile();
    }
}

- (BOOL)arePdfsDownloaded:(PdfInfo *)pdfInfo
{
    return [pdfInfo sourceURLEn] && [[NSFileManager defaultManager] fileExistsAtPath:[self filePathForPdf:pdfInfo forLanguage:LanguageEnglish]]
        && [pdfInfo sourceURLPl] && [[NSFileManager defaultManager] fileExistsAtPath:[self filePathForPdf:pdfInfo forLanguage:LanguagePolish]];
}

- (NSString *)filePathForPdf:(PdfInfo *)pdfInfo forLanguage:(Language)language
{
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error)
            NSLog(@"ERROR occured during creation of Application Support Directory: %@", error);
    }
    return [NSString stringWithFormat:@"%@/%@_%@.pdf", path, pdfInfo.id, (language == LanguagePolish) ? @"pl" : @"en"];
}

- (void)removePdfFiles:(PdfInfo *)pdfInfo
{
    NSError *error = nil;
    if ([pdfInfo sourceURLEn])
    {
        if (![[NSFileManager defaultManager] removeItemAtPath:[self filePathForPdf:pdfInfo forLanguage:LanguageEnglish] error:&error])
        {
            NSLog(@"Error occured during removing file: %@", error);
        }
    }
    
    error = nil;
    if ([pdfInfo sourceURLPl])
    {
        if (![[NSFileManager defaultManager] removeItemAtPath:[self filePathForPdf:pdfInfo forLanguage:LanguagePolish] error:&error])
        {
            NSLog(@"Error occured during removing file: %@", error);
        }
    }
}

@end
