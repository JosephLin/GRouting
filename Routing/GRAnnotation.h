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
    GRAnnotationTypeStart = 0,
    GRAnnotationTypeEnd,
    GRAnnotationTypeRegular,
    GRAnnotationTypeTouchPoint,
} GRAnnotationType;


@interface GRAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) GRAnnotationType type;
@property (nonatomic, strong) NSString *symbol;
@property (nonatomic, strong) NSString *symbolColorCode;

@end
