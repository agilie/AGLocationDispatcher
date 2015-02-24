//
//  LDAnnotation.h
//  LocationDispatch
//
//  Created by Vermillion on 12.02.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "LDLocation.h"

typedef enum {
    LDAnnotationTypeStart,
    LDAnnotationTypeFinish
} LDAnnotationType;

@interface LDAnnotation : NSObject<MKAnnotation>

@property (assign, nonatomic) LDAnnotationType type;

- (id)initWithType:(LDAnnotationType)type location:(LDLocation *)location;

- (NSString *)annotationImageName;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
