//
//  MKPolyline+Decoding.h
//  GRouting
//
//  Created by Joseph Lin on 8/31/12.
//  Copyright (c) 2012 Joseph Lin. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKPolyline (Decoding)

+ (MKPolyline *)polylineWithEncodedString:(NSString *)encodedString;

@end
