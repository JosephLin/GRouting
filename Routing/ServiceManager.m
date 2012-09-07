//
//  ServiceManager.m
//  GRouting
//
//  Created by Joseph Lin on 9/7/12.
//  Copyright (c) 2012 Joseph Lin. All rights reserved.
//

#import "ServiceManager.h"
#import "NSDictionary+Utilities.h"

static NSString* baseURL = @"http://maps.googleapis.com/maps/api/directions/json";



@interface ServiceManager () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) MKDirectionsRequest* currentRequest;
@property (nonatomic, strong) id JSONResponse;
@property (nonatomic, strong, readonly) NSString* archivePath;
@end



@implementation ServiceManager


#pragma mark - Object Lifecycle

+ (ServiceManager *)sharedInstance
{
    static ServiceManager* _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [ServiceManager new];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    return self;
}

- (NSString *)archivePath
{
    static NSString* _archivePath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        _archivePath = [documentsDir stringByAppendingPathComponent:@"lastRoute.archive"];
    });
    return _archivePath;
}


#pragma mark -

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
        [self findRouteFromLocation:self.currentRequest.source.placemark.location toLocation:self.currentRequest.destination.placemark.location];
    }
}

- (void)findRouteUsingCacheLocations
{
    NSDictionary* dict = [NSKeyedUnarchiver unarchiveObjectWithFile:self.archivePath];
    CLLocation* fromLocation = [dict objectForKey:@"fromLocation"];
    CLLocation* toLocation = [dict objectForKey:@"toLocation"];
    if ( fromLocation && toLocation )
    {
        [self findRouteFromLocation:fromLocation toLocation:toLocation];
    }
    else
    {
        NSLog(@"Can't find cached locations!");
    }
}

- (void)findRouteFromLocation:(CLLocation*)fromLocation toLocation:(CLLocation*)toLocation
{
    // Cache the locations to disk.
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          fromLocation, @"fromLocation",
                          toLocation, @"toLocation",
                          nil];
    [NSKeyedArchiver archiveRootObject:dict toFile:self.archivePath];

    
    // Start the query.
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
    
    NSString* URLString = [NSString stringWithFormat:@"%@?%@", baseURL, [params queryString]];
    NSURL* URL = [NSURL URLWithString:URLString];
    NSURLRequest* request = [NSURLRequest requestWithURL:URL];
    
    NSLog(@"Request URL: %@", URL);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if ( !error )
        {
            self.JSONResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            [self processJSONResponse:self.JSONResponse];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    }];
}

- (void)processJSONResponse:(NSDictionary*)response
{
    NSArray* routes = [response objectForKey:@"routes"];
    
    if ( [routes count] )
    {
        self.currentRoute = [Route routeWithDictionary:[routes objectAtIndex:0]];
        [self.delegate serviceManage:self didLoadRoute:self.currentRoute];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Direction Not Available"
                                    message:@"Directions could not be found between these locations."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}


#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self.locationManager stopMonitoringSignificantLocationChanges];
    
    if ( [self.currentRequest.source isCurrentLocation] )
    {
        [self findRouteFromLocation:self.locationManager.location toLocation:self.currentRequest.destination.placemark.location];
    }
}


@end
