//
//  AGIPDFContext.m
//  usmissionpoland
//
//  Created by Paweł Nowosad on 10.12.2013.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import "AGIPDFContext.h"
#import "AppDelegate.h"
#import "AGIFileManager.h"

@interface AGIPDFContext ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation AGIPDFContext

static NSString *const APIResponseID = @"id";
static NSString *const managedPdfInfoEntityName = @"PdfInfo";

#pragma mark - Signleton pattern

static AGIPDFContext *defaultContext = nil;

// Get the shared instance and create it if necessary.
+ (id)defaultContext
{
    if (defaultContext)
        return defaultContext;
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        defaultContext = [[AGIPDFContext alloc] init];
    });
    
    return defaultContext;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.managedObjectContext = [appDelegate managedObjectContext];
    }
    
    return self;
}

+ (NSString *)downloadNotificationIdentifier
{
    static NSString *downloadNotificationIdentifier = @"pdf_download_notification";
    return downloadNotificationIdentifier;
}

- (NSString *)apiDefaultMethodName
{
    return @"GetPdfs";
}

- (NSString *)apiModelsArrayParamName
{
    return @"pdfs";
}

- (void)getDataUsingBlock:(void (^)(NSArray *))setDataBlock
{
    __weak AGIPDFContext *weakSelf = self;
    void (^jsonParser)(NSDictionary *) = ^(NSDictionary *parsedJSON)
     {
         AGIPDFContext *blockSelf = weakSelf;
         
         NSArray *newPdfsDataArray = [parsedJSON objectForKey:[blockSelf apiModelsArrayParamName]];
         NSMutableArray *updatedPdfs = [NSMutableArray array];
         NSDictionary *savedPdfsInfoDictionary = [blockSelf getLocallySavedPdfsDictionary];
         for (NSDictionary *pdfData in newPdfsDataArray)
         {
             NSNumber *pdfID = [pdfData objectForKey:APIResponseID];
             PdfInfo *pdfInfo = [savedPdfsInfoDictionary objectForKey:pdfID];
             if (pdfInfo)
             {
                 [pdfInfo updateDataUsingJSON:pdfData];
                 
                 [updatedPdfs addObject:pdfInfo];
             }
             else
             {
                 PdfInfo *newPdfInfo = [NSEntityDescription insertNewObjectForEntityForName:managedPdfInfoEntityName inManagedObjectContext:blockSelf.managedObjectContext];
                 [newPdfInfo loadDataFromJSON:pdfData];

                 [updatedPdfs addObject:newPdfInfo];
             }
         }
         
         NSArray *savedPdfsArray = [savedPdfsInfoDictionary allValues];
         NSMutableString *deletedPdfNames = [NSMutableString stringWithString:@""];
         for (PdfInfo *pdfInfo in savedPdfsArray)
         {
             if (![updatedPdfs containsObject:pdfInfo])
             {
                 if (pdfInfo.fileVersion)
                 {
                     [deletedPdfNames appendFormat:@"\n%@", [pdfInfo localizedName]];
                     
                     [self removePdf:pdfInfo];
                 }
                 
                 [blockSelf.managedObjectContext deleteObject:pdfInfo];
             }
         }
         
         [blockSelf saveChangesInManagedObjectContext];
         
         if ([deletedPdfNames length])
         {
             NSString *filesRemovedAlertTitleEn = @"Files Update";
             NSString *filesRemovedAlertTitlePl = @"Pliki zaktualizowane";
             NSString *localizedTitle = ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) ? filesRemovedAlertTitlePl : filesRemovedAlertTitleEn;
             
             NSString *filesRemovedAlertMsgEn = @"These documents have been removed from the application:";
             NSString *filesRemovedAlertMsgPl = @"Następujące dokumenty zostały usunięte z aplikacji:";
             NSString *localizedMsg = ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) ? filesRemovedAlertMsgPl : filesRemovedAlertMsgEn;
             localizedMsg = [localizedMsg stringByAppendingString:deletedPdfNames];
             
             UIAlertView *filesRemovedAlert = [[UIAlertView alloc] initWithTitle:localizedTitle
                                                                         message:localizedMsg
                                                                        delegate:nil
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil];
             [filesRemovedAlert show];
         }
         
         // Setting the Sort Descriptor
         NSString *sortingKey = ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) ? @"namePl" : @"nameEn";
         NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortingKey ascending:YES];
         NSArray *sortDescriptors = @[sortDescriptor];
         
         if (setDataBlock)
             setDataBlock([updatedPdfs sortedArrayUsingDescriptors:sortDescriptors]);
     };
    
    [self sendHttpRequestWithParameters:nil withBlockOnComplete:jsonParser];
}

- (NSArray *)getLocallySavedPdfs
{
    NSManagedObjectContext *moc = self.managedObjectContext;
    
    // Creating the Request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:managedPdfInfoEntityName inManagedObjectContext:moc];
    [request setEntity:entity];
    
    // Setting the Sort Descriptor
    NSString *sortingKey = ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) ? @"namePl" : @"nameEn";
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortingKey ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    NSArray *fetchResults = [moc executeFetchRequest:request error:&error];
    if (error)
    {
        NSLog(@"PRODUCTS CONTEXT SAVED PRODUCTS FETCH REQUEST ERROR: %@", error);
        
        return nil;
    }
    
    return fetchResults;
}

- (NSDictionary *)getLocallySavedPdfsDictionary
{
    NSArray *pdfsArray = [self getLocallySavedPdfs];
    NSMutableDictionary *pdfsInfoDictionary = [NSMutableDictionary dictionaryWithCapacity:[pdfsArray count]];
    for (PdfInfo *pdfInfo in pdfsArray)
    {
        [pdfsInfoDictionary setObject:pdfInfo forKey:pdfInfo.id];
    }
    
    return [NSDictionary dictionaryWithDictionary:pdfsInfoDictionary];
}

#pragma mark - Managed Object Context

- (void)saveChangesInManagedObjectContext
{
    if ([self.managedObjectContext hasChanges])
    {
        NSError *error = nil;
        [self.managedObjectContext save:&error];
        if (error)
            NSLog(@"ERROR occured during saving changes in managed object context: %@", error);
    }
}

#pragma mark - File managing

- (void)downloadPdf:(PdfInfo *)pdfInfo
{
    [pdfInfo setFileVersion:[pdfInfo version]];
    [self saveChangesInManagedObjectContext];
    [pdfInfo setDownloadInProgress:YES];
    
    __weak AGIPDFContext *weakSelf = self;
    [[AGIFileManager sharedInstance] downloadPdfFiles:pdfInfo complete:^(BOOL success)
     {
         AGIPDFContext *blockSelf = weakSelf;
         
         if (!success)
         {
             [pdfInfo setFileVersion:nil];
             [blockSelf saveChangesInManagedObjectContext];
         }
         [pdfInfo setDownloadInProgress:NO];
         NSNotification *finishedNotification = [NSNotification notificationWithName:[AGIPDFContext downloadNotificationIdentifier] object:pdfInfo];
         [[NSNotificationCenter defaultCenter] postNotification:finishedNotification];
     }];
}

- (void)removePdf:(PdfInfo *)pdfInfo
{
    [pdfInfo setFileVersion:nil];
    [self saveChangesInManagedObjectContext];
    
    [[AGIFileManager sharedInstance] removePdfFiles:pdfInfo];
}

@end
