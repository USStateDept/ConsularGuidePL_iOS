//
//  AGIFileManager.h
//  Intiaro
//
//  Created by Paweł Nowosad on 8/8/13.
//  Copyright (c) 2013 Agitive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PdfInfo.h"

@interface AGIFileManager : NSObject

+ (id)sharedInstance;

- (void)downloadPdfFiles:(PdfInfo *)pdfInfo complete:(void (^)(BOOL success))complete;
- (BOOL)arePdfsDownloaded:(PdfInfo *)pdfInfo;
- (NSString *)filePathForPdf:(PdfInfo *)pdfInfo forLanguage:(Language)language;
- (void)removePdfFiles:(PdfInfo *)pdfInfo;

@end
