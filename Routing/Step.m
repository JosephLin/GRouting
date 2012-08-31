//
//  Step.m
//  Routing
//
//  Created by Joseph Lin on 7/11/12.
//  Copyright (c) 2012 Joseph Lin. All rights reserved.
//

#import "Step.h"


@implementation Step

@synthesize distance, duration, startCoordinate, endCoordinate, HTMLInstructions, travelMode, steps;


+ (Step*)stepWithDictionary:(NSDictionary*)dict
{
    Step* step = [Step new];
    
    NSDictionary* distance = [dict objectForKey:@"distance"];
    step.distance = [[distance objectForKey:@"value"] doubleValue];

    NSDictionary* duration = [dict objectForKey:@"distance"];
    step.duration = [[duration objectForKey:@"value"] doubleValue];
    
    NSDictionary* start_location = [dict objectForKey:@"start_location"];
    step.startCoordinate = CLLocationCoordinate2DMake([[start_location objectForKey:@"lat"] doubleValue], [[start_location objectForKey:@"lng"] doubleValue]);

    NSDictionary* end_location = [dict objectForKey:@"end_location"];
    step.endCoordinate = CLLocationCoordinate2DMake([[end_location objectForKey:@"lat"] doubleValue], [[end_location objectForKey:@"lng"] doubleValue]);

    step.HTMLInstructions = [dict objectForKey:@"html_instructions"];
    
    step.travelMode = [dict objectForKey:@"travel_mode"];
    
    step.polylineString = [[dict objectForKey:@"polyline"] objectForKey:@"points"];
    
//    step.steps = [Step stepsWithArray:[dict objectForKey:@"steps"]];
    
    return step;
}

+ (NSArray*)stepsWithArray:(NSArray*)array
{
    NSMutableArray* steps = [NSMutableArray arrayWithCapacity:[array count]];
    
    for ( NSDictionary* dict in array )
    {
        Step* step = [Step stepWithDictionary:dict];
        [steps addObject:step];
    }
    
    return steps;
}


@end
