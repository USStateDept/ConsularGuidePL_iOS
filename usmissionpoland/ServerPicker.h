//
//  ServerPicker.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 4/8/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Handles the load balancing between two servers by serving either slave or master server url at random. Picks one server with arc4random_uniform() and if it responds, remembers that choice for 1 hour. Then it picks again. If first one doesn't respond, it tries the second one. If neither respond, returns master server's url. */
@interface ServerPicker : NSObject

+(ServerPicker*)picker;
- (NSString*)serverBaseUrl;
- (NSString*)serverPostDataUrl;
- (NSString*)serverJsonUrl;

/* Switches to the other server if the last switch caused by request failure was more than a minute ago, otherwise sets server to none. Returns YES if current server at the end of this function is not set to none, NO otherwise  */
- (BOOL)switchServer;

@property (nonatomic, strong) NSTimer *serverValidityTimer;

@end
