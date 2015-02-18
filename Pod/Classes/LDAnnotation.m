//
//  LDAnnotation.m
//  LocationDispatch
//
//  Created by Vermillion on 12.02.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "LDAnnotation.h"
#import "LDLocation.h"

@interface LDAnnotation ()

@property (strong, nonatomic) NSString *annotationTitle;
@property (assign, nonatomic) CLLocationCoordinate2D annotationCoordinate;

@end

@implementation LDAnnotation

- (NSString *)title {
    return self.annotationTitle;
}

- (CLLocationCoordinate2D)coordinate {
    return self.annotationCoordinate;
}

- (id)initWithType:(LDAnnotationType)type location:(LDLocation *)location {
    self = [super init];
    if (self) {
        self.annotationTitle = [self titleForType:type];
        self.annotationCoordinate = location.coordinate;
        self.type = type;
    }
    return self;
}

- (NSString *)titleForType:(LDAnnotationType)type {
    switch (type) {
        case LDAnnotationTypeStart:
            return @"Start point";
        case LDAnnotationTypeFinish:
            return @"Finish point";
        default:
            return nil;
    }
}

- (NSString *)annotationImageName {
    switch (self.type) {
        case LDAnnotationTypeStart:
            return @"start.png";
        case LDAnnotationTypeFinish:
            return @"finish.png";
        default:
            return nil;
    }
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    self.annotationCoordinate = newCoordinate;
}

@end
