//
//  ViewController.m
//  Routing
//
//  Created by Joseph Lin on 7/11/12.
//  Copyright (c) 2012 Joseph Lin. All rights reserved.
//

#import "ViewController.h"
#import "Route.h"
#import "PinAnnotation.h"

static NSString* baseURL = @"http://maps.googleapis.com/maps/api/directions/json";


@interface ViewController () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) MKDirectionsRequest* currentRequest;
@end


@implementation ViewController
@synthesize mapView;
@synthesize locationManager, currentRequest;


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
    NSString* fromLatLon = [NSString stringWithFormat:@"%f,%f", fromLocation.coordinate.latitude, fromLocation.coordinate.longitude];
    NSString* toLatLon = [NSString stringWithFormat:@"%f,%f", toLocation.coordinate.latitude, toLocation.coordinate.longitude];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            fromLatLon, @"origin",
                            toLatLon, @"destination",
                            @"false", @"sensor",
                            @"transit", @"mode",
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
            id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            [self processJSONResponse:object];
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
    self.mapView.region = route.bounds;

    PinAnnotation* annotation = [PinAnnotation new];
    annotation.coordinate = route.startCoordinate;
    
	[self.mapView addAnnotation:annotation];
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
    MKPinAnnotationView* pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinReuseIdentifier];
    pinAnnotationView.pinColor = MKPinAnnotationColorGreen;
    return pinAnnotationView;
}




@end


