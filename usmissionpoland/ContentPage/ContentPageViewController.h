//
//  ContentPageViewController.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/2/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Page.h"
#import "ContentPageButtonView.h"


typedef enum {
    TextParsingStateNormal,
    TextParsingStateStrong
} TextParsingState;

/** Class that manages most of the content pages types */
@interface ContentPageViewController : BaseViewController <NSXMLParserDelegate, ContentPageButtonDelegate>

/** Scroll view that contains all the content of this page */
@property (nonatomic, weak) UIScrollView *scrollView;

/** This string is an xml of the page that this view controller is showing */
@property (nonatomic, readonly) NSString* contentString;

-(void)prepareLayoutFromXml;

-(CGPoint)scrollViewOrigin; // for subclassing

@property (nonatomic, weak) id<ContentPageButtonDelegate>buttonDelegate;

@end
