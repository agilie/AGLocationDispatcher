//
//  AGRoutePart.m
//  LocationDispatch
//
//  Created by Vermillion on 11.02.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "AGRoutePart.h"

@interface AGRoutePart ()

@property (strong, nonatomic) NSMutableArray *routePartPoints;
@property (strong, nonatomic) NSMutableArray *routePartSpeeds;
@property (strong, nonatomic) NSDate *startSessionDate;
@property (strong, nonatomic) NSDate *stopSessionDate;
@property (assign, nonatomic) double routePartDistance;

@end

@implementation AGRoutePart

@synthesize routePartPoints = _routePartPoints;
@synthesize routePartSpeeds = _routePartSpeeds;
@synthesize startSessionDate = _startSessionDate;
@synthesize stopSessionDate = _stopSessionDate;
@synthesize routePartDistance = _routePartDistance;

- (instancetype)initWithRoutePartPoints:(NSArray *)routePartPoints andSpeeds:(NSArray *)routePartSpeeds {
    self = [super init];
    if (!self) {

    }
    self.routePartPoints = [NSMutableArray arrayWithArray:routePartPoints];
    self.routePartSpeeds = [NSMutableArray arrayWithArray:routePartSpeeds];
    return self;
}

- (NSMutableArray *)routePartPoints {
    if (!_routePartPoints) {
        _routePartPoints = [NSMutableArray array];
    }
    return _routePartPoints;
}

- (void)addRoutePoint:(AGLocation *)point {
    [self.routePartPoints addObject:point];
}

- (NSMutableArray *)routePartSpeeds {
    if (!_routePartSpeeds) {
        _routePartSpeeds = [NSMutableArray array];
    }
    return _routePartSpeeds;
}

- (void)setStartSessionDate:(NSDate *)startSessionDate {
    _startSessionDate = startSessionDate;
}

- (NSDate *)startSessionDate {
    return _startSessionDate;
}

- (void)setStopSessionDate:(NSDate *)stopSessionDate {
    _stopSessionDate = stopSessionDate;
}

- (NSDate *)stopSessionDate {
    return _stopSessionDate;
}

- (double)routePartDistance {
    _routePartDistance = 0.f;
    __block AGLocation *prewPoint;
    [self.routePartPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (!prewPoint) {
            prewPoint = (AGLocation *)obj;
        } else {
            _routePartDistance += [(AGLocation *)obj distanceFromLocation:prewPoint];
        }
    }];
    return _routePartDistance;
}

- (void)addSpeed:(int)speed {
    [self.routePartSpeeds addObject:@(speed)];
}

#pragma mark NSCoding

#define kRoutePartPointsKey     @"RoutePartPoints"
#define kRoutePartSpeedsKey     @"RoutePartSpeeds"
#define kStartDateKey           @"startDate"
#define kStopDateKey            @"stopDate"

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.routePartPoints forKey:kRoutePartPointsKey];
    [encoder encodeObject:self.routePartSpeeds forKey:kRoutePartSpeedsKey];
    [encoder encodeObject:self.startSessionDate forKey:kStartDateKey];
    [encoder encodeObject:self.stopSessionDate forKey:kStopDateKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSArray *routePartPoints = (NSArray *)[decoder decodeObjectForKey:kRoutePartPointsKey];
    NSArray *routePartSpeeds = (NSArray *)[decoder decodeObjectForKey:kRoutePartSpeedsKey];
    AGRoutePart *routePart = [self initWithRoutePartPoints:routePartPoints andSpeeds:routePartSpeeds];
    [routePart setStartSessionDate:(NSDate *)[decoder decodeObjectForKey:kStartDateKey]];
    [routePart setStopSessionDate:(NSDate *)[decoder decodeObjectForKey:kStopDateKey]];
    return routePart;
}

@end
