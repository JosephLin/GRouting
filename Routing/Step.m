//
//  Step.m
//  Routing
//
//  Created by Joseph Lin on 7/11/12.
//  Copyright (c) 2012 Joseph Lin. All rights reserved.
//

#import "Step.h"


@implementation Step


+ (Step*)stepWithDictionary:(NSDictionary*)dict
{
    Step* step = [Step new];
    
    NSDictionary* distance = [dict objectForKey:@"distance"];
    step.distance = [[distance objectForKey:@"value"] doubleValue];
    step.distanceString = [distance objectForKey:@"text"];

    NSDictionary* duration = [dict objectForKey:@"distance"];
    step.duration = [[duration objectForKey:@"value"] doubleValue];
    
    NSDictionary* start_location = [dict objectForKey:@"start_location"];
    step.startCoordinate = CLLocationCoordinate2DMake([[start_location objectForKey:@"lat"] doubleValue], [[start_location objectForKey:@"lng"] doubleValue]);

    NSDictionary* end_location = [dict objectForKey:@"end_location"];
    step.endCoordinate = CLLocationCoordinate2DMake([[end_location objectForKey:@"lat"] doubleValue], [[end_location objectForKey:@"lng"] doubleValue]);

    step.HTMLInstructions = [dict objectForKey:@"html_instructions"];
    
    step.travelMode = [dict objectForKey:@"travel_mode"];
    
    step.polylineString = [[dict objectForKey:@"polyline"] objectForKey:@"points"];

    step.transitDetails = [dict objectForKey:@"transit_details"];
    step.vehicleType = [step.transitDetails valueForKeyPath:@"line.vehicle.type"];

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


- (NSString*)vehicleSymbol
{
    // Annotation Symbol
    if ([self.vehicleType isEqualToString:@"RAIL"])
    {
        // Rail.
        return @"🚉";
    }
    else if ([self.vehicleType isEqualToString:@"METRO_RAIL"])
    {
        // Light rail transit.
        return @"🚃";
    }
    else if ([self.vehicleType isEqualToString:@"SUBWAY"])
    {
        // Underground light rail.
        return nil; // Line number will be used as the symbol in Map.
    }
    else if ([self.vehicleType isEqualToString:@"TRAM"])
    {
        // Above ground light rail.
        return @"🚃";
    }
    else if ([self.vehicleType isEqualToString:@"MONORAIL"])
    {
        // Monorail.
        return @"🚃";
    }
    else if ([self.vehicleType isEqualToString:@"HEAVY_RAIL"])
    {
        // Heavy rail.
        return @"🚉";
    }
    else if ([self.vehicleType isEqualToString:@"COMMUTER_TRAIN"])
    {
        // Commuter rail.
        return @"🚉";
    }
    else if ([self.vehicleType isEqualToString:@"HIGH_SPEED_TRAIN"])
    {
        // High speed train.
        return @"🚄";
    }
    else if ([self.vehicleType isEqualToString:@"BUS"])
    {
        // Bus.
        return @"🚌";
    }
    else if ([self.vehicleType isEqualToString:@"INTERCITY_BUS"])
    {
        // Intercity bus.
        return @"🚌";
    }
    else if ([self.vehicleType isEqualToString:@"TROLLEYBUS"])
    {
        // Trolleybus.
        return @"🚌";
    }
    else if ([self.vehicleType isEqualToString:@"SHARE_TAXI"])
    {
        // Share taxi is a kind of bus with the ability to drop off and pick up passengers anywhere on its route.
        return @"🚕";
    }
    else if ([self.vehicleType isEqualToString:@"FERRY"])
    {
        // Ferry.
        return @"🚢";
    }
    else if ([self.vehicleType isEqualToString:@"CABLE_CAR"])
    {
        // A vehicle that operates on a cable, usually on the ground. Aerial cable cars may be of the type GONDOLA_LIFT.
        return @"🚃";
    }
    else if ([self.vehicleType isEqualToString:@"GONDOLA_LIFT"])
    {
        // An aerial cable car.
        return @"🌄";
    }
    else if ([self.vehicleType isEqualToString:@"FUNICULAR"])
    {
        // A vehicle that is pulled up a steep incline by a cable. A Funicular typically consists of two cars, with each car acting as a counterweight for the other.
        return @"🌄";
    }
    else
    {
        return nil;
    }
}


@end
