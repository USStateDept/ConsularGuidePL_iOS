//
//  AGIPDFContext.h
//  usmissionpoland
//
//  Created by Paweł Nowosad on 10.12.2013.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import "AGIDataContext.h"
#import "PdfInfo.h"

@interface AGIPDFContext : AGIDataContext

+ (NSString *)downloadNotificationIdentifier;

- (NSArray *)getLocallySavedPdfs;

- (void)downloadPdf:(PdfInfo *)pdfInfo;
- (void)removePdf:(PdfInfo *)pdfInfo;

@end
