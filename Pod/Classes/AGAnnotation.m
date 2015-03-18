//
//  AGAnnotation.m
//  LocationDispatch
//
//  Created by Vermillion on 12.02.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "AGAnnotation.h"

@interface AGAnnotation ()

@property (strong, nonatomic) NSString *annotationTitle;
@property (assign, nonatomic) CLLocationCoordinate2D annotationCoordinate;

@end

@implementation AGAnnotation

- (NSString *)title {
    return self.annotationTitle;
}

- (CLLocationCoordinate2D)coordinate {
    return self.annotationCoordinate;
}

- (id)initWithType:(AGAnnotationType)type location:(AGLocation *)location {
    self = [super init];
    if (self) {
        self.annotationTitle = [self titleForType:type];
        self.annotationCoordinate = location.coordinate;
        self.type = type;
    }
    return self;
}

- (NSString *)titleForType:(AGAnnotationType)type {
    switch (type) {
        case AGAnnotationTypeStart:
            return @"Start point";
        case AGAnnotationTypeFinish:
            return @"Finish point";
        default:
            return nil;
    }
}

- (NSString *)annotationImageName {
    switch (self.type) {
        case AGAnnotationTypeStart:
            return @"start.png";
        case AGAnnotationTypeFinish:
            return @"finish.png";
        default:
            return nil;
    }
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    self.annotationCoordinate = newCoordinate;
}

@end
