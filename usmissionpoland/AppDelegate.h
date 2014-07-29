//
//  AppDelegate.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 10/17/13.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, NSXMLParserDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic, retain) UINavigationController *navController;


@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator ;
@property (nonatomic, retain) NSFileManager *fileManager;
@property (nonatomic, retain) NSTimer *feedbackTimer;
@property (nonatomic, retain) NSTimer *updateTimer;
@property (nonatomic, retain) NSDate* lastUpdateDate;
@property (nonatomic, retain) BilingualLabel *updatingLabel;


+ (BOOL)isIPad;
+ (CGFloat)smallSpace;
+ (CGFloat)mediumSpace;
+ (CGFloat)largeSpace;
+ (CGFloat)veryLargeSpace;
+ (CGFloat)marginSpace;

- (void)updateContentPages;

- (void)checkForUpdate;

@end
