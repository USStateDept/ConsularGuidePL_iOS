//
//  ContentPageMapView.h
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/9/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ContentPageMapView : MKMapView <MKMapViewDelegate, UIAlertViewDelegate>

- (id)initWithFrame:(CGRect)frame latitude:(NSNumber*)latitude longitude:(NSNumber*)longitude zoom:(NSNumber*)zoom locationName:(NSString*)locationName;

@end
