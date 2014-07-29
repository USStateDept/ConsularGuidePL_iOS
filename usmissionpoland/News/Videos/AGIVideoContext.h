//
//  AGIVideoContext.h
//  usmissionpoland
//
//  Created by Paweł Nowosad on 13.02.2014.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "AGIDataContext.h"
#import "AGIVideoModel.h"

@interface AGIVideoContext : AGIDataContext

- (void)getAllVideosUsingBlock:(void (^)(AGIVideoModel *mostViewed, NSArray *recentVideos))setDataBlock;

- (void)reportWatchedVideo:(AGIVideoModel *)video;

@end
