//
//  AppDelegate.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 10/17/13.
//  Copyright (c) 2013 Agitive Sp. z o.o. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking.h"
#import "APNSInfo.h"
#import "Page.h"
#import "MainMenuAlert.h"
#import "CustomNavigationController.h"
#import "ECSlidingViewController.h"
#import "HomePageViewController.h"
#import "MainMenuViewController.h"


typedef enum {
    ParserActionNone,
    ParserActionDownloadImage,
    ParserActionDeleteImage
} ParserAction;

@interface AppDelegate ()

@property (nonatomic, assign) ParserAction parserAction;

@end
    
    
@implementation AppDelegate

static CGFloat _smallSpace = 6.0f;
static CGFloat _mediumSpace = 11.0f;
static CGFloat _largeSpace = 17.0f;
static CGFloat _veryLargeSpace = 33.0f;
static CGFloat _marginSpace = 16.0;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (BOOL)isIPad
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

+ (CGFloat)smallSpace
{
    return _smallSpace;
}

+ (CGFloat)mediumSpace
{
    return _mediumSpace;
}

+ (CGFloat)largeSpace
{
    return _largeSpace;
}

+ (CGFloat)veryLargeSpace
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    return ([AppDelegate isIPad] && UIDeviceOrientationIsPortrait(orientation)) ? _veryLargeSpace : _largeSpace;
}

+ (CGFloat)marginSpace {
    return _marginSpace;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    if ([AppDelegate isIPad])
    {
        _smallSpace = ceilf(_smallSpace * 1.5f);
        _mediumSpace = ceilf(_mediumSpace * 1.5f);
        _largeSpace = ceilf(_largeSpace * 1.5f);
    }
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    self.fileManager = fileMgr;
    
    self.parserAction = ParserActionNone;
    
    
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dirName = [docDir stringByAppendingPathComponent:@"media/images"];
    
    BOOL isDir;
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:dirName isDirectory:&isDir])
    {
        if([fm createDirectoryAtPath:dirName withIntermediateDirectories:YES attributes:nil error:nil])
            NSLog(@"Directory Created");
        else
            NSLog(@"Directory Creation Failed");
    }
    else {
        NSLog(@"Directory Already Exist");
    }
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    HomePageViewController *homeVc= [[HomePageViewController alloc] init];
    
    self.navController=[[CustomNavigationController alloc]initWithRootViewController:homeVc];
    
    ECSlidingViewController *slidingViewController = [[ECSlidingViewController alloc] init];
    slidingViewController.topViewController = self.navController;
    [self.navController.navigationBar addGestureRecognizer:slidingViewController.panGesture];
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        slidingViewController.anchorRightPeekAmount = slidingViewController.view.frame.size.width/4;
    }
    else {
        slidingViewController.anchorRightPeekAmount = slidingViewController.view.bounds.size.height * 0.2f/0.3f;
    }
    slidingViewController.resetStrategy = ECPanning | ECTapping;
    slidingViewController.shouldAddPanGestureRecognizerToTopViewSnapshot = YES;
    slidingViewController.view.backgroundColor = CustomUSAppBlueColor;
    
    
    MainMenuViewController *leftVc = [[MainMenuViewController alloc] init];
    
    slidingViewController.underLeftViewController = leftVc;
    
    [self.window setRootViewController:slidingViewController];
    [self.window makeKeyAndVisible];
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    [self updateContentPages];
    [self getBanner];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"received notification, %@", userInfo);
    if ( application.applicationState == UIApplicationStateActive ) {
        // app was already in the foreground
        [self getBanner];
    }
    else {
        // app was just brought from background to foreground
        [self getBanner];
    }
    if ([(userInfo[@"extra"])[@"type"] intValue] == 2) {
        [self askForUpdate];
    }
    return;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    
    // initializing NSFetchRequest
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //Setting Entity to be Queried
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"APNSInfo"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError* error;
    
    // Query on managedObjectContext With Generated fetchRequest
    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSLog(@"fetched records for APNSInfo %@", fetchedRecords);
    if ([fetchedRecords count] == 0) {
        
        APNSInfo* newEntry = [NSEntityDescription insertNewObjectForEntityForName:@"APNSInfo"
                                                          inManagedObjectContext:self.managedObjectContext];
        
        newEntry.deviceToken = [token copy];
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Saving failed with error: %@", [error localizedDescription]);
        }
        
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *params = @{@"new_device_token": token,
                                 @"method": @"AddIosDevice"};
        [manager POST:API_MASTER_POST_DATA_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Add ios device response JSON: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
    }
    else if (![[[fetchedRecords objectAtIndex:0] deviceToken] isEqualToString:token]) {
        
        APNSInfo *oldEntry = [fetchedRecords objectAtIndex:0];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *params = @{@"method": @"ChangeIosDevice",
                                 @"new_device_token": token,
                                 @"old_device_token": oldEntry.deviceToken};
        [manager POST:API_MASTER_POST_DATA_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Change ios device response JSON: %@", responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
        oldEntry.deviceToken = token;
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Updating failed with error: %@", [error localizedDescription]);
        }
    }
    //else nothing happens, move along
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}


- (NSManagedObjectContext *) managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return _managedObjectContext;
}


- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"PhoneBook.sqlite"]];
    
    /* Here we put our preloaded database in place of the default one */
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeUrl path]]) {
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"InitialData" ofType:@"sqlite"]];
        NSError* err = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeUrl error:&err]) {
            NSLog(@"Oops, could copy preloaded data");
        }
        
        
        /* To complete setting up the initial app data, we copy images here (as they are not inside database, but need to be copied once just like the database) */
        
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"photos"
                                                               ofType:@"jpg"];
        
        NSString *docPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/media/images/photos.jpg"];
        NSError *error = nil;
        [[NSFileManager defaultManager] copyItemAtPath:bundlePath
                                                toPath:docPath
                                                 error:&error];
        if (error) {
            // handle copy error.
        }
    }
    
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = @{ NSSQLitePragmasOption : @{@"journal_mode" : @"DELETE"} };
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:storeUrl options:options error:&error]) {
        /*Error for store creation should be handled in here*/
    }
    
    return _persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)updateContentPages {
    NSEntityDescription *pageEntity = [NSEntityDescription entityForName:@"Page" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = pageEntity;
    NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    NSMutableDictionary *pagesDictionary = [NSMutableDictionary dictionary];
    
    for (Page *page in fetchedRecords) {
        [pagesDictionary setObject:[NSDictionary dictionaryWithObject:page.version forKey:@"version"] forKey:[NSString stringWithFormat:@"%d", page.pageId.intValue]];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSDictionary *params = @{@"method": @"UpdatePages",
                             @"pages": pagesDictionary};
    
    [self showUpdateInProgressIndicator];
    
    [manager POST:API_JSON_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Update pages response JSON: %@", responseObject);
        [self removePages:[[responseObject objectForKey:@"result"] objectForKey:@"removed"]];
        [self addPages:[[responseObject objectForKey:@"result"] objectForKey:@"new"]];
        [self updatePages:[[responseObject objectForKey:@"result"] objectForKey:@"updated"]];
        [self.managedObjectContext save:nil];
        
        self.lastUpdateDate = [NSDate date];
        [self setTimer];
        
        [self hideUpdateInProgressIndicator];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        if (![operation.request.URL.absoluteString isEqualToString:API_JSON_URL] || [[ServerPicker picker] switchServer]) {
            [self updateContentPages];
        }
        else {
            [self hideUpdateInProgressIndicator];
        }
    }];
    
    
}

- (void)showUpdateInProgressIndicator {
    [[NSNotificationCenter defaultCenter] postNotificationName:POST_NOTIFICATION_DID_START_DATABASE_UPDATE object:nil];
}

- (void)hideUpdateInProgressIndicator {
    [[NSNotificationCenter defaultCenter] postNotificationName:POST_NOTIFICATION_DID_END_DATABASE_UPDATE object:nil];
}

- (void)setTimer {
    NSDate *nextUpdateDate = [NSDate dateWithTimeInterval:86400 sinceDate:self.lastUpdateDate];
    NSTimeInterval timeToUpdate = [nextUpdateDate timeIntervalSinceNow];
    if (timeToUpdate > 0) {
        [self.updateTimer invalidate];
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:timeToUpdate target:self selector:nil userInfo:nil repeats:NO];
    }
}

- (void)checkForUpdate {
    if (![self.updateTimer isValid]) {
        self.updateTimer = nil;
        [self updateContentPages];
    }
}

- (void)askForUpdate {
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
        UIAlertView *updateAlertView = [[UIAlertView alloc] initWithTitle:@"Aktualizacje są dostępne do pobrania" message:@"Możesz pobrać je teraz i przejść do ekranu głównego lub zaktualizować zawartość gdy aplikacja zostanie uruchomiona następnym razem." delegate:self cancelButtonTitle:@"Aktualizuj później" otherButtonTitles:@"Aktualizuj teraz" , nil];
        [updateAlertView show];
    }
    else {
        UIAlertView *updateAlertView = [[UIAlertView alloc] initWithTitle:@"Updates are available for download" message:@"You can download them now and go to the main screen or update the content when the application will be started next time." delegate:self cancelButtonTitle:@"Update later" otherButtonTitles:@"Update now" , nil];
        [updateAlertView show];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self updateContentPages];
    }
}

- (void)removePages:(NSArray*)pagesToRemove {
    NSEntityDescription *pageEntity = [NSEntityDescription entityForName:@"Page" inManagedObjectContext:self.managedObjectContext];
    for (NSNumber* pageId in pagesToRemove) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        fetchRequest.entity = pageEntity;
        if ([pageId intValue] != 0) {
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"pageId = %d", [pageId intValue]];
            NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
            for (Page *page in fetchedRecords) {
                [self deleteImagesForPage:page];
                [self.managedObjectContext deleteObject:page];
            }
        }
    }
}

- (void)updatePages:(NSArray*)pagesToUpdate {
    NSEntityDescription *pageEntity = [NSEntityDescription entityForName:@"Page" inManagedObjectContext:self.managedObjectContext];
    for (NSDictionary* pageDictionary in pagesToUpdate) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        fetchRequest.entity = pageEntity;
        int pageId = [[pageDictionary objectForKey:@"id"] intValue];
        if (pageId != 0) {
            Page *page;
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"pageId = %d", pageId];
            NSArray *fetchedRecords = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
            if (fetchedRecords.count == 0) {
                page = [NSEntityDescription insertNewObjectForEntityForName:@"Page" inManagedObjectContext:self.managedObjectContext];
            }
            else {
                if (fetchedRecords.count > 1) {
                    for (int i = 1; i < fetchedRecords.count; ++i) {
                        [self deleteImagesForPage:[fetchedRecords objectAtIndex:i]];
                        [self.managedObjectContext deleteObject:[fetchedRecords objectAtIndex:i]];
                    }
                }
                page = [fetchedRecords firstObject];
                [self deleteImagesForPage:page];
            }
            
            page.pageId = pageDictionary[@"id"];
            page.parentId = pageDictionary[@"parent_id"];
            page.version = pageDictionary[@"version"];
            page.titleEN = pageDictionary[@"title_en"];
            page.contentEN = pageDictionary[@"content_en"];
            if (pageDictionary[@"faq_en"]) {
                page.contentEN = pageDictionary[@"faq_en"];
            }
            page.titlePL = pageDictionary[@"title_pl"];
            page.contentPL = pageDictionary[@"content_pl"];
            if (pageDictionary[@"faq_pl"]) {
                page.contentPL = pageDictionary[@"faq_pl"];
            }
            page.index = pageDictionary[@"index"];
            page.type = pageDictionary[@"type"];
            if (pageDictionary[@"latitude"] != [NSNull null]) {
                page.latitude = pageDictionary[@"latitude"];
            }
            else {
                page.latitude = [NSNumber numberWithFloat:0.0f];
            }
            if (pageDictionary[@"latitude"] != [NSNull null]) {
                page.longitude = pageDictionary[@"longitude"];
            }
            else {
                page.longitude = [NSNumber numberWithFloat:0.0f];
            }
            if (pageDictionary[@"zoom"] != [NSNull null]) {
                page.mapZoom = pageDictionary[@"zoom"];
            }
            else {
                page.mapZoom = [NSNumber numberWithFloat:13.0f];
            }
            if (pageDictionary[@"additional_en"]) {
                page.additionalEN = pageDictionary[@"additional_en"];
            }
            if (pageDictionary[@"additional_pl"]) {
                page.additionalPL = pageDictionary[@"additional_pl"];
            }
            
            [self downloadImagesForPage:page];
        }
    }
}

- (void)addPages:(NSArray*)pagesToAdd {
    [self updatePages:pagesToAdd];
}

- (void)deleteImagesForPage:(Page*)page {
    self.parserAction = ParserActionDeleteImage;
    
    NSXMLParser *contentParserEN = [[NSXMLParser alloc] initWithData:[[page contentEN] dataUsingEncoding:NSUTF8StringEncoding]];
    contentParserEN.delegate = self;
    
    [contentParserEN parse];
    
    NSXMLParser *contentParserPL = [[NSXMLParser alloc] initWithData:[[page contentPL] dataUsingEncoding:NSUTF8StringEncoding]];
    contentParserPL.delegate = self;
    
    [contentParserPL parse];
    
    self.parserAction = ParserActionNone;
}

- (void)downloadImagesForPage:(Page*)page {
    self.parserAction = ParserActionDownloadImage;
    
    NSXMLParser *contentParserEN = [[NSXMLParser alloc] initWithData:[[page contentEN] dataUsingEncoding:NSUTF8StringEncoding]];
    contentParserEN.delegate = self;
    
    [contentParserEN parse];
    
    NSXMLParser *contentParserPL = [[NSXMLParser alloc] initWithData:[[page contentPL] dataUsingEncoding:NSUTF8StringEncoding]];
    contentParserPL.delegate = self;
    
    NSLog(@"starting parse of page %@", page.titleEN);
    [contentParserPL parse];
    self.parserAction = ParserActionNone;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"img"]) {
        if ([attributeDict objectForKey:@"src"] != nil) {
            if (self.parserAction == ParserActionDeleteImage) {
                [self.fileManager removeItemAtPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[attributeDict objectForKey:@"src"]] error:nil];
            }
            else if (self.parserAction == ParserActionDownloadImage) {
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[API_BASE_URL stringByAppendingString:[attributeDict objectForKey:@"src"]]]];
                [NSURLConnection sendAsynchronousRequest:request
                                                   queue:[NSOperationQueue mainQueue]
                                       completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                           if ( !error )
                                           {
                                               if (data != nil) {
                                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                                   NSData *jpegData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];
                                                   NSError *error;
                                                   if ([jpegData writeToFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:[attributeDict objectForKey:@"src"]] options:NSDataWritingAtomic error:&error]) {
                                                       NSLog(@"success");
                                                   }
                                                   else {
                                                       NSLog(@"failed %@", error);
                                                   }
                                               }
                                               
                                           } else{
                                               if (![request.URL.absoluteString isEqualToString:[API_BASE_URL stringByAppendingString:[attributeDict objectForKey:@"src"]]] || [[ServerPicker picker] switchServer]) {
                                                   [self parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
                                               }
                                           }
                }];
            }
            
        }
        
    }
}

- (void)getBanner {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *params = @{@"method": @"GetBanner"};
    
    [manager POST:API_POST_DATA_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Banner JSON: %@", responseObject);
        NSDictionary *result = [responseObject objectForKey:@"result"];
        if ([[result objectForKey:@"enabled"] boolValue]) {
            [MainMenuAlert showAlertTitleEn:[result objectForKey:@"title_en"] descriptionEn:[result objectForKey:@"description_en"] titlePl:[result objectForKey:@"title_pl"] descriptionPl:[result objectForKey:@"description_pl"] type:[result objectForKey:@"type"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Baner Error: %@", [error localizedDescription]);
        if (![operation.request.URL.absoluteString isEqualToString:API_POST_DATA_URL] || [[ServerPicker picker] switchServer]) {
            [self getBanner];
        }
    }];
    
    
}

- (void)nop {
    
}

@end
