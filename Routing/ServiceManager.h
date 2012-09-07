//
//  ServiceManager.h
//  GRouting
//
//  Created by Joseph Lin on 9/7/12.
//  Copyright (c) 2012 Joseph Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Route.h"

@protocol ServiceManagerDelegate;


@interface ServiceManager : NSObject

@property (nonatomic, strong) Route* currentRoute;
@property (nonatomic, weak) id <ServiceManagerDelegate> delegate;

+ (ServiceManager *)sharedInstance;
- (void)processRequest:(MKDirectionsRequest*)request;
- (void)findRouteUsingCacheLocations;

@end


@protocol ServiceManagerDelegate <NSObject>
- (void)serviceManage:(ServiceManager*)manager didLoadRoute:(Route*)route;
@end
