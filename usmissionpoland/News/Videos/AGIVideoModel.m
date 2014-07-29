//
//  AGIVideoModel.m
//  usmissionpoland
//
//  Created by Paweł Nowosad on 12.02.2014.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "AGIVideoModel.h"
#import "NSString+DateConverter.h"
#import "AGILocalVideoModel.h"
#import "AGIYTVideoModel.h"

@interface AGIVideoModel ()

@property (nonatomic, strong, readwrite) NSNumber *id;
@property (nonatomic, copy, readwrite) NSString *titleEn;
@property (nonatomic, copy, readwrite) NSString *titlePl;
@property (nonatomic, assign, readwrite) AGIVideoType videoType;
@property (nonatomic, strong, readwrite) NSURL *thumbnailIPad;
@property (nonatomic, strong, readwrite) NSURL *thumbnailIPhone;
@property (nonatomic, strong, readwrite) NSDate *date;

@end

@implementation AGIVideoModel

static NSString *const APIResponseID = @"id";
static NSString *const APIResponseTitleEn = @"title_en";
static NSString *const APIResponseTitlePl = @"title_pl";
static NSString *const APIResponseType = @"type";
static NSString *const APIResponseDate = @"date";
static NSString *const APIResponsePoster = @"poster";
static NSString *const APIResponsePosterIPhone = @"poster_640";
static NSString *const APIResponsePosterIPad = @"poster_1536";

static NSString *const APIResponseTypeLocal = @"LC";
static NSString *const APIResponseTypeYT = @"YT";

+ (id)createVideoModelWithJsonFeed:(NSDictionary *)jsonFeed
{
    NSString *videoType = [jsonFeed objectForKey:APIResponseType];
    AGIVideoModel *videoModel;
    if ([videoType isEqualToString:APIResponseTypeLocal])
        videoModel = [AGILocalVideoModel alloc];
    else
        videoModel = [AGIYTVideoModel alloc];
    
    videoModel = [videoModel initWithJSON:jsonFeed];
    
    return videoModel;
}

- (instancetype)initWithJSON:(NSDictionary *)jsonFeed
{
    self = [super init];
    if (self)
    {
        self.id = [jsonFeed objectForKey:APIResponseID];
        self.titleEn = [jsonFeed objectForKey:APIResponseTitleEn];
        self.titlePl = [jsonFeed objectForKey:APIResponseTitlePl];
        self.date = [[jsonFeed objectForKey:APIResponseDate] dateFromStringWithFormat:@"yyyy-MM-dd"];
        
        NSDictionary *postersDictionary = [jsonFeed objectForKey:APIResponsePoster];
        self.thumbnailIPad = [NSURL URLWithString:[API_BASE_URL stringByAppendingString:[postersDictionary objectForKey:APIResponsePosterIPad]]];
        self.thumbnailIPhone = [NSURL URLWithString:[API_BASE_URL stringByAppendingString:[postersDictionary objectForKey:APIResponsePosterIPhone]]];
        
        NSString *typeString = [jsonFeed objectForKey:APIResponseType];
        if ([typeString isEqualToString:APIResponseTypeLocal])
            self.videoType =AGILocalVideoType;
        else
            self.videoType = AGIYTVideoType;
    }
    
    return self;
}

- (NSURL *)thumbnail
{
    return self.thumbnailIPad;
}

- (void)playVideoInViewController:(UIViewController *)viewController
{
    
}

- (NSString *)localizedTitle
{
    switch ([[LanguageSettings sharedSettings] currentLanguage]) {
        case LanguagePolish:
            if (self.titlePl)
                return self.titlePl;
            else
                return self.titleEn;
            break;
            
        default:
            if (self.titleEn)
                return self.titleEn;
            else
                return self.titlePl;
            break;
    }
}

@end
