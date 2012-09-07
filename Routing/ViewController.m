//
//  ViewController.m
//  Routing
//
//  Created by Joseph Lin on 7/11/12.
//  Copyright (c) 2012 Joseph Lin. All rights reserved.
//

#import "ViewController.h"
#import "GRAnnotation.h"
#import "GRAnnotationView.h"
#import "MKPolyline+Decoding.h"
#import "UIColor+Utilities.h"
#import "ServiceManager.h"



@interface ViewController () <ServiceManagerDelegate>
@property (nonatomic, strong) NSMutableDictionary* lineColorDict;
@end



@implementation ViewController


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [ServiceManager sharedInstance].delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (IBAction)refreshButtonTapped:(id)sender
{
    [[ServiceManager sharedInstance] findRouteUsingCacheLocations];
}


#pragma mark - Map

- (void)clearMap
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
}

- (void)displayRoute:(Route*)route
{
    [self clearMap];

    self.mapView.region = route.bounds;

    NSArray* allSteps = [route valueForKeyPath:@"legs.@unionOfArrays.steps"];
    self.lineColorDict = [NSMutableDictionary dictionaryWithCapacity:[allSteps count]];

    for ( int i = 0; i < [allSteps count]; i++ )
    {
        Step* step = [allSteps objectAtIndex:i];

        GRAnnotation* annotation = [GRAnnotation new];
        annotation.coordinate = step.startCoordinate;
        annotation.type = (i == 0) ? GRAnnotationTypeStart : GRAnnotationTypeRegular;

        MKPolyline *polyline = [MKPolyline polylineWithEncodedString:step.polylineString];
        
        if ([step.travelMode isEqualToString:@"WALKING"])
        {
            annotation.title = step.HTMLInstructions;
            annotation.subtitle = step.distanceString;
            annotation.symbol = @"🚶";
        }
        else if ([step.travelMode isEqualToString:@"TRANSIT"])
        {
            NSString* colorCode = [[step.transitDetails objectForKey:@"line"] objectForKey:@"color"];
            NSString* shortName = [[step.transitDetails objectForKey:@"line"] objectForKey:@"short_name"];
            NSString* name = [[step.transitDetails objectForKey:@"line"] objectForKey:@"name"];
            NSString* fromStop = [[step.transitDetails objectForKey:@"departure_stop"] objectForKey:@"name"];
            NSString* toStop = [[step.transitDetails objectForKey:@"arrival_stop"] objectForKey:@"name"];
            NSString* vehicleType = [[[step.transitDetails objectForKey:@"line"] objectForKey:@"vehicle"] objectForKey:@"type"];
            
            if (name && shortName)
            {
                annotation.title = [NSString stringWithFormat:@"%@ - %@", shortName, name];
            }
            else if (name)
            {
                annotation.title = [NSString stringWithFormat:@"%@", name];
            }
            else if (shortName)
            {
                annotation.title = [NSString stringWithFormat:@"%@", shortName];
            }
            else
            {
                annotation.title = step.HTMLInstructions;
            }

            annotation.subtitle = [NSString stringWithFormat:@"%@ to %@", fromStop, toStop];
            
            if ([vehicleType isEqualToString:@"BUS"])
            {
                annotation.symbol = @"🚌";
            }
            else if ([vehicleType isEqualToString:@"HEAVY_RAIL"])
            {
                annotation.symbol = @"🚉";
            }
            else
            {
                annotation.symbol = shortName;
                annotation.symbolColorCode = colorCode;
            }

            polyline.title = colorCode;
        }
        else
        {
            annotation.title = step.HTMLInstructions;
            annotation.subtitle = step.travelMode;
        }
        
        [self.mapView addAnnotation:annotation];
        [self.mapView addOverlay:polyline];

        
        if (i == [allSteps count] - 1)
        {
            GRAnnotation* annotation = [GRAnnotation new];
            annotation.coordinate = step.endCoordinate;
            annotation.type = GRAnnotationTypeEnd;
            [self.mapView addAnnotation:annotation];
        }
    }
    
    NSLog(@"Annotations: %@", self.mapView.annotations);
}


#pragma mark - Map View Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    static NSString* pinReuseIdentifier = @"pinReuseIdentifier";

    switch ([(GRAnnotation*)annotation type])
    {
        case GRAnnotationTypeStart:
        {
            MKPinAnnotationView* annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinReuseIdentifier];
            annotationView.canShowCallout = YES;
            annotationView.pinColor = MKPinAnnotationColorGreen;
            return annotationView;
        }
            
        case GRAnnotationTypeEnd:
        {
            MKPinAnnotationView* annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinReuseIdentifier];
            annotationView.canShowCallout = YES;
            annotationView.pinColor = MKPinAnnotationColorRed;
            return annotationView;
        }
            
        default:
        {
            static NSString* grReuseIdentifier = @"grReuseIdentifier";
            GRAnnotationView* annotationView = [[GRAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:grReuseIdentifier];
            annotationView.image = [UIImage imageNamed:@"annotation"];
            annotationView.centerOffset = CGPointMake(0, -10);
            annotationView.canShowCallout = YES;
            return annotationView;
        }
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = (overlay.title) ? [UIColor colorFromHexString:overlay.title] : [UIColor lightPurpleColor];
    polylineView.lineWidth = 10.0;
    return polylineView;
}


#pragma mark - Service Manager Delegate

- (void)serviceManage:(ServiceManager*)manager didLoadRoute:(Route*)route
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self displayRoute:route];
    });
}


@end


