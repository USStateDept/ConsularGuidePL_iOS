//
//  ContentPageImageView.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/2/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageImageView.h"

@implementation ContentPageImageView

- (id)initWithFrame:(CGRect)frame imageUrlString:(NSString*)imageUrlString
{
    self = [super initWithFrame:frame];
    if (self) {
        imageUrlString = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:imageUrlString];
        
        UIImage *image = [UIImage imageWithContentsOfFile:imageUrlString];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        if (image.size.width <= frame.size.width) {
            imageView.frame = CGRectMake((frame.size.width - image.size.width )/2.0f, 0, image.size.width, image.size.height);
        }
        else {
            imageView.frame = CGRectMake(0, 0, frame.size.width, image.size.height * (frame.size.width / image.size.width));
        }
        [self addSubview:imageView];
        frame.size.height = imageView.frame.size.height;
        self.frame = frame;
    }
    return self;
}

@end
