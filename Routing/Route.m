//
//  Route.m
//  Routing
//
//  Created by Joseph Lin on 7/11/12.
//  Copyright (c) 2012 Joseph Lin. All rights reserved.
//

#import "Route.h"


@implementation Route

@synthesize bounds, distance, duration;
@synthesize departureTime, arrivalTime, startAddress, endAddress, startCoordinate, endCoordinate;
@synthesize  steps;



+ (Route*)routeWithDictionary:(NSDictionary*)dict
{
    Route* route = [Route new];
    
    NSDictionary* bounds = [dict objectForKey:@"bounds"];
    
    NSDictionary* northeast = [bounds objectForKey:@"northeast"];
    CLLocationCoordinate2D NECoordinate = CLLocationCoordinate2DMake([[northeast objectForKey:@"lat"] doubleValue], [[northeast objectForKey:@"lng"] doubleValue]);
    
    NSDictionary* southwest = [bounds objectForKey:@"southwest"];
    CLLocationCoordinate2D SWCoordinate = CLLocationCoordinate2DMake([[southwest objectForKey:@"lat"] doubleValue], [[southwest objectForKey:@"lng"] doubleValue]);

    route.bounds = [Route regionFromNECoordinate:NECoordinate SWCoordinate:SWCoordinate];
    
    
    NSDictionary* distance = [dict objectForKey:@"distance"];
    route.distance = [[distance objectForKey:@"value"] doubleValue];
    
    NSDictionary* duration = [dict objectForKey:@"duration"];
    route.duration = [[duration objectForKey:@"value"] doubleValue];
    
    NSDictionary* departure_time = [dict objectForKey:@"departure_time"];
    route.departureTime = [NSDate dateWithTimeIntervalSinceReferenceDate:[[departure_time objectForKey:@"value"] doubleValue]];
    
    NSDictionary* arrival_time = [dict objectForKey:@"arrival_time"];
    route.departureTime = [NSDate dateWithTimeIntervalSinceReferenceDate:[[arrival_time objectForKey:@"value"] doubleValue]];
    
    route.startAddress = [dict objectForKey:@"start_address"];
    
    route.endAddress = [dict objectForKey:@"end_address"];

    NSDictionary* start_location = [dict objectForKey:@"start_location"];
    route.startCoordinate = CLLocationCoordinate2DMake([[start_location objectForKey:@"lat"] doubleValue], [[start_location objectForKey:@"lng"] doubleValue]);
    
    NSDictionary* end_location = [dict objectForKey:@"end_location"];
    route.endCoordinate = CLLocationCoordinate2DMake([[end_location objectForKey:@"lat"] doubleValue], [[end_location objectForKey:@"lng"] doubleValue]);

    route.steps = [Step stepsWithArray:[dict objectForKey:@"steps"]];
    
    return route;
}



+ (MKCoordinateRegion)regionFromNECoordinate:(CLLocationCoordinate2D)NECoordinate SWCoordinate:(CLLocationCoordinate2D)SWCoordinate
{
    MKMapPoint NEPoint = MKMapPointForCoordinate(NECoordinate);
    MKMapPoint SWPoint = MKMapPointForCoordinate(SWCoordinate);
        
    MKMapRect mapRect = MKMapRectMake(SWPoint.x, NEPoint.y, NEPoint.x - SWPoint.x, SWPoint.y - NEPoint.y);
    
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);

    return region;
}

@end
