//
//  Route.h
//  Routing
//
//  Created by Joseph Lin on 7/11/12.
//  Copyright (c) 2012 Joseph Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Step.h"


@interface Route : NSObject

@property (nonatomic) MKCoordinateRegion bounds;
@property (nonatomic) double distance;
@property (nonatomic) NSTimeInterval duration;

@property (nonatomic, strong) NSDate* departureTime;
@property (nonatomic, strong) NSDate* arrivalTime;
@property (nonatomic, strong) NSString* startAddress;
@property (nonatomic, strong) NSString* endAddress;
@property (nonatomic) CLLocationCoordinate2D startCoordinate;
@property (nonatomic) CLLocationCoordinate2D endCoordinate;

@property (nonatomic, strong) NSArray* steps;

+ (Route*)routeWithDictionary:(NSDictionary*)dict;

@end
