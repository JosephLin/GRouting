//
//  Leg.m
//  GRouting
//
//  Created by Joseph Lin on 8/27/12.
//  Copyright (c) 2012 Joseph Lin. All rights reserved.
//

#import "Leg.h"


@implementation Leg

@synthesize distance, duration;
@synthesize departureTime, arrivalTime, startAddress, endAddress, startCoordinate, endCoordinate;
@synthesize  steps;

+ (Leg*)legWithDictionary:(NSDictionary*)dict
{
    Leg* leg = [Leg new];
    
    NSDictionary* distance = [dict objectForKey:@"distance"];
    leg.distance = [[distance objectForKey:@"value"] doubleValue];
    
    NSDictionary* duration = [dict objectForKey:@"duration"];
    leg.duration = [[duration objectForKey:@"value"] doubleValue];
    
    NSDictionary* departure_time = [dict objectForKey:@"departure_time"];
    leg.departureTime = [NSDate dateWithTimeIntervalSinceReferenceDate:[[departure_time objectForKey:@"value"] doubleValue]];
    
    NSDictionary* arrival_time = [dict objectForKey:@"arrival_time"];
    leg.departureTime = [NSDate dateWithTimeIntervalSinceReferenceDate:[[arrival_time objectForKey:@"value"] doubleValue]];
    
    leg.startAddress = [dict objectForKey:@"start_address"];
    
    leg.endAddress = [dict objectForKey:@"end_address"];
    
    NSDictionary* start_location = [dict objectForKey:@"start_location"];
    leg.startCoordinate = CLLocationCoordinate2DMake([[start_location objectForKey:@"lat"] doubleValue], [[start_location objectForKey:@"lng"] doubleValue]);
    
    NSDictionary* end_location = [dict objectForKey:@"end_location"];
    leg.endCoordinate = CLLocationCoordinate2DMake([[end_location objectForKey:@"lat"] doubleValue], [[end_location objectForKey:@"lng"] doubleValue]);
    
    leg.steps = [Step stepsWithArray:[dict objectForKey:@"steps"]];
    
    return leg;
}

+ (NSArray*)legsWithArray:(NSArray*)array
{
    NSMutableArray* legs = [NSMutableArray arrayWithCapacity:[array count]];
    
    for ( NSDictionary* dict in array )
    {
        Leg* leg = [Leg legWithDictionary:dict];
        [legs addObject:leg];
    }
    
    return legs;
}

@end
