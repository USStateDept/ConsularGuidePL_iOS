//
//  AGILocalVideoModel.m
//  usmissionpoland
//
//  Created by Paweł Nowosad on 12.02.2014.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "AGILocalVideoModel.h"
#import <MediaPlayer/MediaPlayer.h>

@interface AGILocalVideoModel ()

@property (nonatomic, strong, readwrite) NSString *variantURLPostfix;
@property (nonatomic, strong, readwrite) NSArray *sourceURLs;

@end

@implementation AGILocalVideoModel

static NSString *const APIResponseVariantURL = @"ios_variant";
static NSString *const APIResponseSourceURLs = @"ios_urls";

- (instancetype)initWithJSON:(NSDictionary *)jsonFeed
{
    self = [super initWithJSON:jsonFeed];
    if (self)
    {
        self.variantURLPostfix = [jsonFeed objectForKey:APIResponseVariantURL];
        
        NSArray *sourcePaths = [jsonFeed objectForKey:APIResponseSourceURLs];
        NSMutableArray *mSourceURLs = [NSMutableArray array];
        for (NSString *sourcePath in sourcePaths)
        {
            [mSourceURLs addObject:[NSURL URLWithString:[API_BASE_URL stringByAppendingString:sourcePath]]];
        }
        self.sourceURLs = [NSArray arrayWithArray:mSourceURLs];
    }
    
    return self;
}

- (void)playVideoInViewController:(UIViewController *)viewController
{
    MPMoviePlayerViewController *movieController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[API_BASE_URL stringByAppendingString:self.variantURLPostfix]]];
    movieController.moviePlayer.shouldAutoplay = YES;
    [viewController presentMoviePlayerViewControllerAnimated:movieController];
}

@end
