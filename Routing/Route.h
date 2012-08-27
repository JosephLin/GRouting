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
#import "Leg.h"


@interface Route : NSObject

@property (nonatomic) MKCoordinateRegion bounds;
@property (nonatomic, strong) NSArray* legs;

+ (Route*)routeWithDictionary:(NSDictionary*)dict;

@end
