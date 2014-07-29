//
//  PdfInfo.m
//  usmissionpoland
//
//  Created by Paweł Nowosad on 10.12.2013.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import "PdfInfo.h"
#import "NSString+DateConverter.h"
#import "LanguageSettings.h"
#import "AppDelegate.h"

@implementation PdfInfo

@dynamic id;
@dynamic nameEn;
@dynamic namePl;
@dynamic size;
@dynamic sourceURLEn;
@dynamic sourceURLPl;
@dynamic updated;
@dynamic fileVersion;
@dynamic version;

@synthesize downloadInProgress;

static NSString *const APIResponseID = @"id";
static NSString *const APIResponseNameEn = @"name_en";
static NSString *const APIResponseNamePl = @"name_pl";
static NSString *const APIResponseUpdated = @"updated";
static NSString *const APIResponseVersion = @"version";
static NSString *const APIResponseSize = @"size";
static NSString *const APIResponseSourceURLEn = @"url_en";
static NSString *const APIResponseSourceURLPl = @"url_pl";

- (instancetype)initWithJSON:(NSDictionary *)jsonFeed
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"PdfInfo" inManagedObjectContext:[appDelegate managedObjectContext]];
    self = [super initWithEntity:entityDescription insertIntoManagedObjectContext:[appDelegate managedObjectContext]];
    if (self)
    {
        [self loadDataFromJSON:jsonFeed];
    }
    
    return self;
}

- (BOOL)isUpdateAvailable
{
    return self.fileVersion && ![self.fileVersion isEqualToNumber:self.version];
}

- (NSString *)getStringOrNilUsingKey:(NSString *)key fromDictionary:(NSDictionary *)dictionary
{
    NSString *str = [dictionary objectForKey:key];
    if ([str isEqual:[NSNull null]])
        return nil;
    else
        return str;
}

- (void)loadDataFromJSON:(NSDictionary *)jsonFeed
{
    self.id = [jsonFeed objectForKey:APIResponseID];
    self.nameEn = [self getStringOrNilUsingKey:APIResponseNameEn fromDictionary:jsonFeed];
    self.namePl = [self getStringOrNilUsingKey:APIResponseNamePl fromDictionary:jsonFeed];
    self.size = [jsonFeed objectForKey:APIResponseSize];
    self.sourceURLEn = [API_BASE_URL stringByAppendingString:[self getStringOrNilUsingKey:APIResponseSourceURLEn fromDictionary:jsonFeed]];
    self.sourceURLPl = [API_BASE_URL stringByAppendingString:[self getStringOrNilUsingKey:APIResponseSourceURLPl fromDictionary:jsonFeed]];
    self.version = [jsonFeed objectForKey:APIResponseVersion];
    self.updated = [[jsonFeed objectForKey:APIResponseUpdated] dateFromStringWithFormat:@"yyyy-MM-dd"];
}

- (BOOL)updateDataUsingJSON:(NSDictionary *)jsonFeed
{
    NSNumber *serverVersion = [jsonFeed objectForKey:APIResponseVersion];
    if ([serverVersion compare:self.version] == NSOrderedDescending)
    {
        [self loadDataFromJSON:jsonFeed];
        
        return YES;
    }
    
    return NO;
}

- (NSString *)localizedName
{
    switch ([[LanguageSettings sharedSettings] currentLanguage]) {
        case LanguagePolish:
            if (self.namePl)
                return self.namePl;
            else
                return self.nameEn;
            break;
            
        default:
            if (self.nameEn)
                return self.nameEn;
            else
                return self.namePl;
            break;
    }
}

@end
