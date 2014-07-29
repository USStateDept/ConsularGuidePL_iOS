//
//  ServerPicker.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 4/8/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ServerPicker.h"
#import "Reachability.h"

#define SERVER_VALIDITY_TIME 3600

typedef enum {
    ServerNone,
    ServerMaster,
    ServerSlave
} ServerType;

@interface ServerPicker ()

@property (nonatomic, assign) ServerType currentServer;
@property (nonatomic, strong) NSDate *lastSwitchDate;

@end

@implementation ServerPicker


+ (ServerPicker*)picker
{
    static ServerPicker *sharedServerPicker = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedServerPicker = [[super allocWithZone:nil] init];
        sharedServerPicker.currentServer = ServerNone;
    });
    return sharedServerPicker;
    
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self picker];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (BOOL)isMasterReachable {
    struct sockaddr_in tAddr;
    tAddr.sin_len = 16;
    tAddr.sin_port = htons(80);
    struct in_addr  address;
    address.s_addr = htons(0x5b799b63);
    tAddr.sin_family = AF_INET;
    
    Reachability* reachability = [Reachability reachabilityWithAddress:&tAddr];
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    return netStatus != NotReachable;
}

- (BOOL)isSlaveReachable {
    struct sockaddr_in tAddr;
    tAddr.sin_len = 16;
    tAddr.sin_port = htons(80);
    struct in_addr  address;
    address.s_addr = htons(0x25bb5d0d);
    tAddr.sin_family = AF_INET;
    
    Reachability* reachability = [Reachability reachabilityWithAddress:&tAddr];
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    return netStatus != NotReachable;
}

- (void)setServerToMaster {
    [self.serverValidityTimer invalidate];
    self.serverValidityTimer = nil;
    
    self.serverValidityTimer = [NSTimer scheduledTimerWithTimeInterval:SERVER_VALIDITY_TIME target:self selector:@selector(invalidateServer) userInfo:nil repeats:NO];
    self.currentServer = ServerMaster;
}

- (void)setServerToSlave {
    [self.serverValidityTimer invalidate];
    self.serverValidityTimer = nil;
    
    self.serverValidityTimer = [NSTimer scheduledTimerWithTimeInterval:SERVER_VALIDITY_TIME target:self selector:@selector(invalidateServer) userInfo:nil repeats:NO];
    self.currentServer = ServerSlave;
}

- (void)invalidateServer {
    [self.serverValidityTimer invalidate];
    self.serverValidityTimer = nil;
    
    self.currentServer = ServerNone;
}

- (void)setServer {
    if (self.currentServer == ServerNone || !self.serverValidityTimer.isValid) {
        if (arc4random_uniform(2) == 0) {
            if ([self isMasterReachable]) {
                [self setServerToMaster];
            }
            else {
                if ([self isSlaveReachable]) {
                    [self setServerToSlave];
                }
                else {
                    self.currentServer = ServerNone;
                    
                    [self.serverValidityTimer invalidate];
                    self.serverValidityTimer = nil;
                }
            }
        }
        else {
            if ([self isSlaveReachable]) {
                [self setServerToSlave];
            }
            else {
                if ([self isMasterReachable]) {
                    [self setServerToMaster];
                }
                else {
                    self.currentServer = ServerNone;
                    
                    [self.serverValidityTimer invalidate];
                    self.serverValidityTimer = nil;
                }
            }
        }
        
        
    }
}

- (BOOL)switchServer {
    if ([[NSDate date] timeIntervalSinceDate:self.lastSwitchDate] < 60) {
        [self.serverValidityTimer invalidate];
        self.serverValidityTimer = nil;
        self.currentServer = ServerNone;
        return NO;
    }
    
    if (self.currentServer == ServerMaster) {
        self.lastSwitchDate = [NSDate date];
        [self setServerToSlave];
        return YES;
    }
    else if (self.currentServer == ServerSlave) {
        self.lastSwitchDate = [NSDate date];
        [self setServerToMaster];
        return YES;
    }
    
    return NO;
}

- (NSString*)serverBaseUrl {
    [self setServer];
    if (self.currentServer == ServerMaster) {
        return API_MASTER_BASE_URL;
    }
    else if (self.currentServer == ServerSlave) {
        return API_SLAVE_BASE_URL;
    }
    
    return API_MASTER_BASE_URL;
}

- (NSString*)serverPostDataUrl {
    [self setServer];
    if (self.currentServer == ServerMaster) {
        return API_MASTER_POST_DATA_URL;
    }
    else if (self.currentServer == ServerSlave) {
        return API_SLAVE_POST_DATA_URL;
    }
    
    return API_MASTER_POST_DATA_URL;
}

- (NSString*)serverJsonUrl {
    [self setServer];
    if (self.currentServer == ServerMaster) {
        return API_MASTER_JSON_URL;
    }
    else if (self.currentServer == ServerSlave) {
        return API_SLAVE_JSON_URL;
    }
    
    return API_MASTER_JSON_URL;
}



@end
