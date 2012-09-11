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
@property (nonatomic, strong) GRAnnotation* startAnnotation;
@property (nonatomic, strong) GRAnnotation* endAnnotation;
@end



@implementation ViewController


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView.showsUserLocation = YES;
    
    [ServiceManager sharedInstance].delegate = self;
}

- (IBAction)refreshButtonTapped:(id)sender
{
    [[ServiceManager sharedInstance] findRouteUsingCacheLocations];
}

- (IBAction)locateButtonTapped:(id)sender
{
    if (self.mapView.userLocation.location)
    {
        [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
        
        
        // Set the start annotation to user's current location.
        if (self.startAnnotation)
        {
            [self.mapView removeAnnotation:self.startAnnotation];
        }
        
        self.startAnnotation = [GRAnnotation new];
        self.startAnnotation.coordinate = self.mapView.userLocation.coordinate;
        self.startAnnotation.type = GRAnnotationTypeStart;
        self.startAnnotation.title = @"Direction From Here";
        [self.mapView addAnnotation:self.startAnnotation];
    }
}

- (IBAction)handleLongPress:(UILongPressGestureRecognizer*)sender
{
    if ( sender.state == UIGestureRecognizerStateBegan )
    {
        CGPoint touchPoint = [sender locationInView:self.mapView];
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        
        
        // Set the end annotation to user's tap point.
        if (self.endAnnotation)
        {
            [self.mapView removeAnnotation:self.endAnnotation];
        }
        
        self.endAnnotation = [GRAnnotation new];
        self.endAnnotation.coordinate = coordinate;
        self.endAnnotation.type = GRAnnotationTypeEnd;
        self.endAnnotation.title = @"Direction To Here";
        self.endAnnotation.isFromLongPress = YES;
        [self.mapView addAnnotation:self.endAnnotation];
    }
}

- (void)findRouteCalloutButtonTapped:(id)sender
{
    if (!self.startAnnotation)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Please specific a start point."
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        
        return;
    }
    
    CLLocation* fromLocation = [[CLLocation alloc] initWithLatitude:self.startAnnotation.coordinate.latitude longitude:self.startAnnotation.coordinate.longitude];
    CLLocation* toLocation = [[CLLocation alloc] initWithLatitude:self.endAnnotation.coordinate.latitude longitude:self.endAnnotation.coordinate.longitude];
    [[ServiceManager sharedInstance] findRouteFromLocation:fromLocation toLocation:toLocation];
}

- (void)switchStartAndEndAnnotation:(id)sender
{
    CLLocationCoordinate2D startCoordinate = self.startAnnotation.coordinate;
    CLLocationCoordinate2D endCoordinate = self.endAnnotation.coordinate;
    
    self.startAnnotation.coordinate = endCoordinate;
    self.endAnnotation.coordinate = startCoordinate;
    
    // Reset the title/subtitle.
    self.startAnnotation.title = @"Start";
    self.startAnnotation.subtitle = nil;
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

    // Set Bounds.
    
    self.mapView.region = route.bounds;

    
    // Iterate through all steps.
    
    NSArray* allSteps = [route valueForKeyPath:@"legs.@unionOfArrays.steps"];
    self.lineColorDict = [NSMutableDictionary dictionaryWithCapacity:[allSteps count]];

    for ( int i = 0; i < [allSteps count]; i++ )
    {
        Step* step = [allSteps objectAtIndex:i];

        GRAnnotation* annotation = [GRAnnotation new];
        annotation.coordinate = step.startCoordinate;
        if (i == 0)
        {
            annotation.type = GRAnnotationTypeStart;
            self.startAnnotation = annotation;
        }
        else
        {
            annotation.type = GRAnnotationTypeRegular;
        }

        MKPolyline *polyline = [MKPolyline polylineWithEncodedString:step.polylineString];
        
        if ([step.travelMode isEqualToString:@"WALKING"])
        {
            annotation.title = step.HTMLInstructions;
            annotation.subtitle = step.distanceString;
            annotation.symbol = @"🚶";
        }
        
        else if ([step.travelMode isEqualToString:@"TRANSIT"])
        {
            NSString* colorCode = [step.transitDetails valueForKeyPath:@"line.color"];
            NSString* shortName = [step.transitDetails valueForKeyPath:@"line.short_name"];
            NSString* name = [step.transitDetails valueForKeyPath:@"line.name"];
            NSString* fromStop = [step.transitDetails valueForKeyPath:@"departure_stop.name"];
            NSString* toStop = [step.transitDetails valueForKeyPath:@"arrival_stop.name"];
            
            
            // Annotation Title
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

            
            // Annotation Subtitle
            annotation.subtitle = [NSString stringWithFormat:@"%@ to %@", fromStop, toStop];
            
            
            // Annotation Symbol
            if (step.vehicleSymbol)
            {
                annotation.symbol = step.vehicleSymbol;                
            }
            else
            {
                annotation.symbol = shortName;
                annotation.symbolColorCode = colorCode;
            }

            
            // Line Color
            polyline.title = colorCode;
        }
        
        else
        {
            annotation.title = step.HTMLInstructions;
            annotation.subtitle = step.travelMode;
        }
        
        
        [self.mapView addAnnotation:annotation];
        [self.mapView addOverlay:polyline];

        
        // Add an additional pin at the destination.
        if (i == [allSteps count] - 1)
        {
            self.endAnnotation = [GRAnnotation new];
            self.endAnnotation.coordinate = step.endCoordinate;
            self.endAnnotation.type = GRAnnotationTypeEnd;
            self.endAnnotation.title = @"Destination";
            [self.mapView addAnnotation:self.endAnnotation];
        }
    }
}


#pragma mark - Map View Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    
    static NSString* pinReuseIdentifier = @"pinReuseIdentifier";
    GRAnnotation* theAnnotation = annotation;
    
    switch (theAnnotation.type)
    {
        case GRAnnotationTypeStart:
        case GRAnnotationTypeEnd:
        {
            MKPinAnnotationView* annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinReuseIdentifier];
            annotationView.canShowCallout = YES;
            annotationView.animatesDrop = theAnnotation.isFromLongPress;
            annotationView.pinColor = (theAnnotation.type == GRAnnotationTypeStart) ? MKPinAnnotationColorGreen : MKPinAnnotationColorRed;
            
            if (theAnnotation.isFromLongPress)
            {
                UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                [rightButton addTarget:self action:@selector(findRouteCalloutButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                annotationView.rightCalloutAccessoryView = rightButton;

                UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
                UIImage* switchImage = [UIImage imageNamed:@"switch"];
                leftButton.bounds = CGRectMake(0, 0, switchImage.size.width, switchImage.size.height);
                [leftButton setImage:switchImage forState:UIControlStateNormal];
                [leftButton addTarget:self action:@selector(switchStartAndEndAnnotation:) forControlEvents:UIControlEventTouchUpInside];
                annotationView.leftCalloutAccessoryView = leftButton;    
            }
            else
            {
                annotationView.leftCalloutAccessoryView = nil;
                annotationView.restorationIdentifier = nil;
            }
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

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
}


#pragma mark - Service Manager Delegate

- (void)serviceManage:(ServiceManager*)manager didLoadRoute:(Route*)route
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self displayRoute:route];
    });
}


@end


