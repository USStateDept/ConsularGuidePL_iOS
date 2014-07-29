//
//  AGIVideoContext.m
//  usmissionpoland
//
//  Created by Paweł Nowosad on 13.02.2014.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "AGIVideoContext.h"

@implementation AGIVideoContext

#pragma mark - Signleton pattern

static AGIVideoContext *defaultContext = nil;

static NSString *const APIMethodWatchVideo = @"WatchVideo";

static NSString *const APIRequestVideoID = @"video_id";

static NSString *const APIResponseMostViewed = @"most_viewed";

// Get the shared instance and create it if necessary.
+ (id)defaultContext
{
    if (defaultContext)
        return defaultContext;
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        defaultContext = [[AGIVideoContext alloc] init];
    });
    
    return defaultContext;
}

- (NSString *)apiDefaultMethodName
{
    return @"GetVideos";
}

- (NSString *)apiModelsArrayParamName
{
    return @"videos";
}

- (void)getDataUsingBlock:(void (^)(NSArray *))setDataBlock
{
    [self getAllVideosUsingBlock:^(AGIVideoModel *mostViewed, NSArray *recentVideos)
    {
        if (setDataBlock)
            setDataBlock(recentVideos);
    }];
}

- (void)getAllVideosUsingBlock:(void (^)(AGIVideoModel *mostViewed, NSArray *recentVideos))setDataBlock
{
    __weak AGIVideoContext *weakSelf = self;
    void (^jsonParser)(NSDictionary *) = ^(NSDictionary *parsedJSON)
    {
        AGIVideoContext *blockSelf = weakSelf;
        
        NSArray *videosDataArray = [parsedJSON objectForKey:[blockSelf apiModelsArrayParamName]];
        NSMutableArray *mParsedVideos = [NSMutableArray arrayWithCapacity:[videosDataArray count]];
        for (NSDictionary *videoData in videosDataArray)
        {
            [mParsedVideos addObject:[AGIVideoModel createVideoModelWithJsonFeed:videoData]];
        }
        
        AGIVideoModel *mostViewedVideo = [AGIVideoModel createVideoModelWithJsonFeed:[parsedJSON objectForKey:APIResponseMostViewed]];
        
        if (setDataBlock)
            setDataBlock(mostViewedVideo, [NSArray arrayWithArray:mParsedVideos]);
    };
    
    [self sendHttpRequestWithParameters:nil withBlockOnComplete:jsonParser];
}

- (void)reportWatchedVideo:(AGIVideoModel *)video
{
    NSString *params = [NSString stringWithFormat:@"%@=%@", APIRequestVideoID, [video id]];
    
    [self sendHttpRequestUsingMethod:APIMethodWatchVideo withParameters:params withBlockOnComplete:nil];
}

@end
