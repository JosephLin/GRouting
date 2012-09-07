//
//  PinAnnotation.h
//  GRouting
//
//  Created by Joseph Lin on 7/25/12.
//  Copyright (c) 2012 Joseph Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum {
    PinAnnotationTypeStart = 0,
    PinAnnotationTypeRegular,
    PinAnnotationTypeEnd,
} PinAnnotationType;


@interface PinAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) PinAnnotationType type;

@end
