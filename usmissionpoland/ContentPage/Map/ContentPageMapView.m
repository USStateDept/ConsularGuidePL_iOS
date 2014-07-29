//
//  ContentPageMapView.m
//  usmissionpoland
//
//  Created by Bartek Lupinski on 1/9/14.
//  Copyright (c) 2014 Agitive Sp. z o.o. All rights reserved.
//

#import "ContentPageMapView.h"
#import "MapAnnotation.h"

@interface ContentPageMapView ()

@property (nonatomic, retain) MKMapItem *mapItem;

@end

@implementation ContentPageMapView

-(id)initWithFrame:(CGRect)frame latitude:(NSNumber *)latitude longitude:(NSNumber *)longitude zoom:(NSNumber *)zoom locationName:(NSString*)locationName{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        
        CLLocationCoordinate2D zoomLocation;
        if (latitude != nil) {
            zoomLocation.latitude = [latitude doubleValue];
        }
        else {
            zoomLocation.latitude = 0;
        }
        if (longitude != nil) {
            zoomLocation.longitude= [longitude doubleValue];
        }
        else {
            zoomLocation.longitude = 0;
        }
        
        [self setCenterCoordinate:zoomLocation zoomLevel:[zoom unsignedIntegerValue] animated:NO];
        
        MapAnnotation *annotation = [[MapAnnotation alloc] init];
        annotation.coordinate = zoomLocation;
        [self addAnnotation:annotation];
        
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:zoomLocation addressDictionary:nil];
        self.mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        self.mapItem.name = locationName;
        
        UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        overlayButton.frame = self.bounds;
        overlayButton.backgroundColor = [UIColor clearColor];
        overlayButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [overlayButton addTarget:self action:@selector(openExternalMap) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:overlayButton];
        
    }
    return self;
}

- (void)didTapOverlayButton {
    if ([[LanguageSettings sharedSettings] currentLanguage] == LanguagePolish) {
        UIAlertView *mapOpenAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Czy chcesz przejść do aplikacji map aby zobaczyć szczegóły lokalizacji?" delegate:self cancelButtonTitle:@"NIE" otherButtonTitles:@"TAK", nil];
        [mapOpenAlert show];
    }
    else {
        UIAlertView *mapOpenAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Do you want to open maps to see this location's details?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [mapOpenAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self openExternalMap];
    }
}

- (void)openExternalMap {
    [self.mapItem openInMapsWithLaunchOptions:nil];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] init];
    annotationView.image = [UIImage imageNamed:@"annotation.png"];
    annotationView.frame = CGRectMake(0, 0, 23, 32);
    
    annotationView.centerOffset = CGPointMake(0, -16);
    
    return annotationView;
}


/* Code for location conversions from http://troybrant.net/ */
#define MERCATOR_OFFSET 268435456
#define MERCATOR_RADIUS 85445659.44705395


#pragma mark -
#pragma mark Map conversion methods

- (double)longitudeToPixelSpaceX:(double)longitude
{
    return round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * M_PI / 180.0);
}

- (double)latitudeToPixelSpaceY:(double)latitude
{
    return round(MERCATOR_OFFSET - MERCATOR_RADIUS * logf((1 + sinf(latitude * M_PI / 180.0)) / (1 - sinf(latitude * M_PI / 180.0))) / 2.0);
}

- (double)pixelSpaceXToLongitude:(double)pixelX
{
    return ((round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / M_PI;
}

- (double)pixelSpaceYToLatitude:(double)pixelY
{
    return (M_PI / 2.0 - 2.0 * atan(exp((round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS))) * 180.0 / M_PI;
}

#pragma mark -
#pragma mark Helper methods

- (MKCoordinateSpan)coordinateSpanWithMapView:(MKMapView *)mapView
                             centerCoordinate:(CLLocationCoordinate2D)centerCoordinate
                                 andZoomLevel:(NSUInteger)zoomLevel
{
    // convert center coordiate to pixel space
    double centerPixelX = [self longitudeToPixelSpaceX:centerCoordinate.longitude];
    double centerPixelY = [self latitudeToPixelSpaceY:centerCoordinate.latitude];
    
    // determine the scale value from the zoom level
    NSInteger zoomExponent = 20 - zoomLevel;
    double zoomScale = pow(2, zoomExponent);
    
    // scale the map’s size in pixel space
    CGSize mapSizeInPixels = mapView.bounds.size;
    double scaledMapWidth = mapSizeInPixels.width * zoomScale;
    double scaledMapHeight = mapSizeInPixels.height * zoomScale;
    
    // figure out the position of the top-left pixel
    double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
    double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
    
    // find delta between left and right longitudes
    CLLocationDegrees minLng = [self pixelSpaceXToLongitude:topLeftPixelX];
    CLLocationDegrees maxLng = [self pixelSpaceXToLongitude:topLeftPixelX + scaledMapWidth];
    CLLocationDegrees longitudeDelta = maxLng - minLng;
    
    // find delta between top and bottom latitudes
    CLLocationDegrees minLat = [self pixelSpaceYToLatitude:topLeftPixelY];
    CLLocationDegrees maxLat = [self pixelSpaceYToLatitude:topLeftPixelY + scaledMapHeight];
    CLLocationDegrees latitudeDelta = -1 * (maxLat - minLat);
    
    // create and return the lat/lng span
    MKCoordinateSpan span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta);
    return span;
}

#pragma mark -
#pragma mark Public methods

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated
{
    // clamp large numbers to 28
    zoomLevel = MAX(1,MIN(zoomLevel, 28));
    
    // use the zoom level to compute the region
    MKCoordinateSpan span = [self coordinateSpanWithMapView:self centerCoordinate:centerCoordinate andZoomLevel:zoomLevel];
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, span);
    
    // set the region like normal
    [self setRegion:region animated:animated];
}



@end
