//
//  Leg.h
//  GRouting
//
//  Created by Joseph Lin on 8/27/12.
//  Copyright (c) 2012 Joseph Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Step.h"


@interface Leg : NSObject

@property (nonatomic) double distance;
@property (nonatomic) NSTimeInterval duration;

@property (nonatomic, strong) NSDate* departureTime;
@property (nonatomic, strong) NSDate* arrivalTime;
@property (nonatomic, strong) NSString* startAddress;
@property (nonatomic, strong) NSString* endAddress;
@property (nonatomic) CLLocationCoordinate2D startCoordinate;
@property (nonatomic) CLLocationCoordinate2D endCoordinate;

@property (nonatomic, strong) NSArray* steps;

+ (Leg*)legWithDictionary:(NSDictionary*)dict;
+ (NSArray*)legsWithArray:(NSArray*)array;

@end
