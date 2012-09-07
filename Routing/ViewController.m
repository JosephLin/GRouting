//
//  ViewController.m
//  Routing
//
//  Created by Joseph Lin on 7/11/12.
//  Copyright (c) 2012 Joseph Lin. All rights reserved.
//

#import "ViewController.h"
#import "Route.h"
#import "GRAnnotation.h"
#import "GRAnnotationView.h"
#import "MKPolyline+Decoding.h"
#import "UIColor+Utilities.h"

#define kStartPointTitle    @"Start"
#define kOtherPointTitle    @"Transfer"
#define kEndPointTitle      @"End"

static NSString* baseURL = @"http://maps.googleapis.com/maps/api/directions/json";


@interface ViewController () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) MKDirectionsRequest* currentRequest;
@property (nonatomic, strong) NSMutableDictionary* lineColorDict;
@property (nonatomic, strong) id JSONResponse;
@end


@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)clearMap
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
}

- (IBAction)refreshButtonTapped:(id)sender
{
    [self processJSONResponse:self.JSONResponse];
}

- (void)showLastRoute
{
    NSDictionary* dict = [NSKeyedUnarchiver unarchiveObjectWithFile:[self archivePath]];
    CLLocation* fromLocation = [dict objectForKey:@"fromLocation"];
    CLLocation* toLocation = [dict objectForKey:@"toLocation"];
    if ( fromLocation && toLocation )
    {
        [self findRouteFromLocation:fromLocation toLocation:toLocation];
    }
}

- (void)processRequest:(MKDirectionsRequest*)request;
{
    self.currentRequest = request;

    if ( [request.source isCurrentLocation] )
    {
        if ( !self.locationManager.location )
        {
            [self.locationManager startMonitoringSignificantLocationChanges];
        }
        else
        {
            [self findRouteFromLocation:self.locationManager.location toLocation:self.currentRequest.destination.placemark.location];
        }
    }
    else
    {
        [self findRouteFromLocation:request.source.placemark.location toLocation:request.destination.placemark.location];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self.locationManager stopMonitoringSignificantLocationChanges];
    
    if ( [self.currentRequest.source isCurrentLocation] )
    {
        [self findRouteFromLocation:self.locationManager.location toLocation:self.currentRequest.destination.placemark.location];
    }
}

- (void)findRouteFromLocation:(CLLocation*)fromLocation toLocation:(CLLocation*)toLocation
{
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          fromLocation, @"fromLocation",
                          toLocation, @"toLocation",
                          nil];   
    [NSKeyedArchiver archiveRootObject:dict toFile:[self archivePath]];


    NSString* fromLatLon = [NSString stringWithFormat:@"%f,%f", fromLocation.coordinate.latitude, fromLocation.coordinate.longitude];
    NSString* toLatLon = [NSString stringWithFormat:@"%f,%f", toLocation.coordinate.latitude, toLocation.coordinate.longitude];
    NSString* departureTime = [NSString stringWithFormat:@"%1.0f", [[NSDate date] timeIntervalSince1970]];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            fromLatLon, @"origin",
                            toLatLon, @"destination",
                            @"false", @"sensor",
                            @"transit", @"mode",
                            departureTime, @"departure_time",
                            nil];
    
    NSString* query = [self queryFromDictionary:params];
    NSString* URLString = [NSString stringWithFormat:@"%@?%@", baseURL, query];
    NSURL* URL = [NSURL URLWithString:URLString];
    NSURLRequest* request = [NSURLRequest requestWithURL:URL];
    
    NSLog(@"Request URL: %@", URL);

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
//        NSLog(@"HTTP Response: %@", response);
        if ( !error )
        {
            self.JSONResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            [self processJSONResponse:self.JSONResponse];
        }
    }];
}

- (void)processJSONResponse:(NSDictionary*)response
{
//    NSLog(@"Response: %@", response);

    NSArray* routes = [response objectForKey:@"routes"];
    
    if ( [routes count] )
    {
        Route *route = [Route routeWithDictionary:[routes objectAtIndex:0]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self displayRoute:route];
        });
    }
}

- (void)displayRoute:(Route*)route
{
    [self clearMap];

    self.mapView.region = route.bounds;

    NSArray* allSteps = [route valueForKeyPath:@"legs.@unionOfArrays.steps"];
    self.lineColorDict = [NSMutableDictionary dictionaryWithCapacity:[allSteps count]];

    for ( int i = 0; i < [allSteps count]; i++ )
    {
        Step* step = [allSteps objectAtIndex:i];

        GRAnnotation* annotation = [GRAnnotation new];
        annotation.coordinate = step.startCoordinate;
        annotation.type = (i == 0) ? GRAnnotationTypeStart : GRAnnotationTypeRegular;

        MKPolyline *polyline = [MKPolyline polylineWithEncodedString:step.polylineString];
        
        if ([step.travelMode isEqualToString:@"WALKING"])
        {
            annotation.title = step.HTMLInstructions;
            annotation.subtitle = step.distanceString;
            annotation.symbol = @"🚶";
        }
        else if ([step.travelMode isEqualToString:@"TRANSIT"])
        {
            NSString* colorCode = [[step.transitDetails objectForKey:@"line"] objectForKey:@"color"];
            NSString* shortName = [[step.transitDetails objectForKey:@"line"] objectForKey:@"short_name"];
            NSString* name = [[step.transitDetails objectForKey:@"line"] objectForKey:@"name"];
            NSString* fromStop = [[step.transitDetails objectForKey:@"departure_stop"] objectForKey:@"name"];
            NSString* toStop = [[step.transitDetails objectForKey:@"arrival_stop"] objectForKey:@"name"];
            NSString* vehicleType = [[[step.transitDetails objectForKey:@"line"] objectForKey:@"vehicle"] objectForKey:@"type"];
            
            if (name && shortName)
            {
                annotation.title = [NSString stringWithFormat:@"%@ - %@", shortName, name];
            }
            else if (name)
            {
                annotation.title = [NSString stringWithFormat:@"%@", name];
            }
            else if (shortName)
            {
                annotation.title = [NSString stringWithFormat:@"%@", shortName];
            }
            else
            {
                annotation.title = step.HTMLInstructions;
            }

            annotation.subtitle = [NSString stringWithFormat:@"%@ to %@", fromStop, toStop];
            
            if ([vehicleType isEqualToString:@"BUS"])
            {
                annotation.symbol = @"🚌";
            }
            else if ([vehicleType isEqualToString:@"HEAVY_RAIL"])
            {
                annotation.symbol = @"🚉";
            }
            else
            {
                annotation.symbol = shortName;
                annotation.symbolColorCode = colorCode;
            }

            polyline.title = colorCode;
        }
        else
        {
            annotation.title = step.HTMLInstructions;
            annotation.subtitle = step.travelMode;
        }
        
        [self.mapView addAnnotation:annotation];
        [self.mapView addOverlay:polyline];

        
        if (i == [allSteps count] - 1)
        {
            GRAnnotation* annotation = [GRAnnotation new];
            annotation.coordinate = step.endCoordinate;
            annotation.type = GRAnnotationTypeEnd;
            [self.mapView addAnnotation:annotation];
        }
    }
    
    NSLog(@"Annotations: %@", self.mapView.annotations);
}



- (NSString*)queryFromDictionary:(NSDictionary*)dict
{
    NSMutableArray* pairs = [NSMutableArray arrayWithCapacity:[dict count]];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString* pair = [NSString stringWithFormat:@"%@=%@", key, obj];
        [pairs addObject:pair];
    }];
    
    NSString* query = [pairs componentsJoinedByString:@"&"];
    return query;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    static NSString* pinReuseIdentifier = @"pinReuseIdentifier";

    switch ([(GRAnnotation*)annotation type])
    {
        case GRAnnotationTypeStart:
        {
            MKPinAnnotationView* annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinReuseIdentifier];
            annotationView.canShowCallout = YES;
            annotationView.pinColor = MKPinAnnotationColorGreen;
            return annotationView;
        }
            
        case GRAnnotationTypeEnd:
        {
            MKPinAnnotationView* annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinReuseIdentifier];
            annotationView.canShowCallout = YES;
            annotationView.pinColor = MKPinAnnotationColorRed;
            return annotationView;
        }
            
        default:
        {
            static NSString* reuseIdentifier = @"reuseIdentifier";
            GRAnnotationView* annotationView = [[GRAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
            annotationView.image = [UIImage imageNamed:@"annotation"];
            annotationView.centerOffset = CGPointMake(0, -10);
            annotationView.canShowCallout = YES;
            return annotationView;
        }
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = (overlay.title) ? [UIColor colorFromHexString:overlay.title] : [UIColor lightPurpleColor];
    polylineView.lineWidth = 10.0;
    
    return polylineView;
}

- (NSString *)archivePath
{
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *archivePath = [documentsDir stringByAppendingPathComponent:@"lastRoute.archive"];
    return archivePath;
}



@end


