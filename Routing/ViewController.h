//
//  ViewController.h
//  Routing
//
//  Created by Joseph Lin on 7/11/12.
//  Copyright (c) 2012 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

- (void)processRequest:(MKDirectionsRequest*)request;

@end
