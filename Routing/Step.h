//
//  Step.h
//  Routing
//
//  Created by Joseph Lin on 7/11/12.
//  Copyright (c) 2012 Joseph Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface Step : NSObject

@property (nonatomic) double distance;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) CLLocationCoordinate2D startCoordinate;
@property (nonatomic) CLLocationCoordinate2D endCoordinate;
@property (nonatomic, strong) NSString* HTMLInstructions;
@property (nonatomic, strong) NSString* travelMode;
@property (nonatomic, strong) NSArray* steps;

+ (Step*)stepWithDictionary:(NSDictionary*)dict;
+ (NSArray*)stepsWithArray:(NSArray*)array;

@end
