//
//  Route.m
//  Routing
//
//  Created by Joseph Lin on 7/11/12.
//  Copyright (c) 2012 Joseph Lin. All rights reserved.
//

#import "Route.h"


@implementation Route

@synthesize bounds;



+ (Route*)routeWithDictionary:(NSDictionary*)dict
{
    Route* route = [Route new];
    
    NSDictionary* bounds = [dict objectForKey:@"bounds"];
    
    NSDictionary* northeast = [bounds objectForKey:@"northeast"];
    CLLocationCoordinate2D NECoordinate = CLLocationCoordinate2DMake([[northeast objectForKey:@"lat"] doubleValue], [[northeast objectForKey:@"lng"] doubleValue]);
    
    NSDictionary* southwest = [bounds objectForKey:@"southwest"];
    CLLocationCoordinate2D SWCoordinate = CLLocationCoordinate2DMake([[southwest objectForKey:@"lat"] doubleValue], [[southwest objectForKey:@"lng"] doubleValue]);

    route.bounds = [Route regionFromNECoordinate:NECoordinate SWCoordinate:SWCoordinate];
    

    route.legs = [Leg legsWithArray:[dict objectForKey:@"legs"]];
    
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
