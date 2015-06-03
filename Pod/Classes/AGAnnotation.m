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
        case AGAnnotationType0Start:
            return @"Start point";
            break;
        case AGAnnotationType1Start:
            return @"Start point";
            break;
        case AGAnnotationType2Start:
            return @"Start point";
            break;
        case AGAnnotationType0Finish:
            return @"Finish point";
            break;
        case AGAnnotationType1Finish:
            return @"Finish point";
            break;
        case AGAnnotationType2Finish:
            return @"Finish point";
            break;
        default:
            return nil;
    }
}

- (NSString *)annotationImageName {
    switch (self.type) {
        case AGAnnotationType0Start:
            return @"start0.png";
        case AGAnnotationType0Finish:
            return @"finish0.png";
        case AGAnnotationType1Start:
            return @"start1.png";
        case AGAnnotationType1Finish:
            return @"finish1.png";
        case AGAnnotationType2Start:
            return @"start2.png";
        case AGAnnotationType2Finish:
            return @"finish2.png";
        default:
            return nil;
    }
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    self.annotationCoordinate = newCoordinate;
}

@end
