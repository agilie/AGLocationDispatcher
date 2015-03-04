//
//  AGRoute.m
//  LocationDispatch
//
//  Created by Vermillion on 11.02.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "AGRoute.h"
#import "AGRoutePart.h"
#import <MapKit/MapKit.h>

@interface AGRoute ()

@property (strong, nonatomic) NSMutableArray *routeParts;
@property (strong, nonatomic) AGRoutePart *currentRoutePart;
@property (strong, nonatomic) NSString *sessionId;
@property (assign, nonatomic) float averageSpeed;
@property (assign, nonatomic) float maxSpeed;
@property (assign, nonatomic) int moveType;
@property (assign, nonatomic) float refreshTimeout;
@property (strong, nonatomic) NSDate *startSessionDate;
@property (strong, nonatomic) NSDate *stopSessionDate;
@property (strong, nonatomic) AGLocation *currentPoint;
@property (assign, nonatomic) double routeDistance;

@end

@implementation AGRoute

@synthesize routeParts = _routeParts;
@synthesize currentRoutePart = _currentRoutePart;
@synthesize sessionId = _sessionId;
@synthesize moveType = _moveType;
@synthesize refreshTimeout = _refreshTimeout;
@synthesize startSessionDate = _startSessionDate;
@synthesize stopSessionDate = _stopSessionDate;
@synthesize averageSpeed = _averageSpeed;
@synthesize maxSpeed = _maxSpeed;
@synthesize routeDistance = _routeDistance;

- (instancetype)initWithRouteParts:(NSArray *)routeParts {
    self = [super init];
    if (!self) {

    }
    self.routeParts = [NSMutableArray arrayWithArray:routeParts];
    self.currentRoutePart = [self.routeParts lastObject];
    return self;
}

- (void)addRoutePoint:(AGLocation *)point {
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    float batteryLevel = [[UIDevice currentDevice] batteryLevel];
    batteryLevel *= 100;
    [point setBattery:@(batteryLevel)];
    [self setCurrentPoint:point];
    if (!self.startSessionDate) {
        [self setStartSessionDate:[NSDate new]];
    }
    if (!self.routeParts.count) {
        self.currentRoutePart = [AGRoutePart new];
        [self.routeParts addObject:self.currentRoutePart];
    }
    if (!self.currentRoutePart) {
        self.currentRoutePart = [AGRoutePart new];
        if (![self.routeParts containsObject:self.currentRoutePart]) {
            [self.routeParts addObject:self.currentRoutePart];
        }
    }
    [self.currentRoutePart addRoutePoint:point];
    if (self.currentRoutePart.routePartPoints.count == 1) {
        [self.currentRoutePart setStartSessionDate:[NSDate new]];
    }
}

- (NSMutableArray *)routePoints {
    __block NSMutableArray *allPoints = [NSMutableArray array];
    [self.routeParts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[AGRoutePart class]]) {
            AGRoutePart *route = (AGRoutePart *)obj;
            [route.routePartPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [allPoints addObject:(AGLocation *)obj];
            }];
        }
    }];
    return allPoints;
}

- (NSMutableArray *)routeParts {
    if (!_routeParts) {
        _routeParts = [NSMutableArray array];
    }
    return _routeParts;
}

- (void)setSessionId:(NSString *)sessionId {
    _sessionId = sessionId;
}

- (NSString *)sessionId {
    return _sessionId;
}

- (void)setMoveType:(int)moveType {
    _moveType = moveType;
}

- (int)moveType {
    return _moveType;
}

- (void)setRefreshTimeout:(float)refreshTimeout {
    _refreshTimeout = refreshTimeout;
}

- (float)refreshTimeout {
    return _refreshTimeout;
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

- (AGRoutePart *)currentRoutePart {
    if (!_currentRoutePart) {
        _currentRoutePart = [AGRoutePart new];
    }
    return _currentRoutePart;
}

- (float)averageSpeed {
    __block int speedSum = 0;
    __block int count = 0;
    [self.routeParts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[AGRoutePart class]]) {
            AGRoutePart *route = (AGRoutePart *)obj;
            [route.routePartSpeeds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                speedSum += [(NSNumber *)obj intValue];
                count++;
            }];
        }
    }];
    if (count > 0) {
        _averageSpeed = (float)(speedSum / count);
    }
    return _averageSpeed;
}

- (float)maxSpeed {
    __block float maxSpeed = 0;
    [self.routeParts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[AGRoutePart class]]) {
            AGRoutePart *route = (AGRoutePart *)obj;
            [route.routePartSpeeds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([(NSNumber *)obj floatValue] > maxSpeed) {
                    maxSpeed = [(NSNumber *)obj floatValue];
                }
            }];
        }
    }];
    _maxSpeed = maxSpeed;
    return _maxSpeed;
}

- (double)routeDistance {
    __block double distance = 0.0;
    [self.routeParts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[AGRoutePart class]]) {
            AGRoutePart *part = (AGRoutePart *)obj;
            distance += [part routePartDistance];
        }
    }];
    _routeDistance = distance;
    return _routeDistance;
}

- (void)finishRoute {
    [self.currentRoutePart setStopSessionDate:[NSDate new]];
    self.currentRoutePart = [AGRoutePart new];
    [self.routeParts addObject:_currentRoutePart];
    [self setStopSessionDate:[NSDate new]];
}

- (void)addSpeed:(int)speed {
    [self.currentRoutePart addSpeed:speed];
}

#pragma mark NSCoding

#define kRouteParts     @"RouteParts"
#define kDataKey        @"Data"
#define kDataFile       @"data.plist"
#define kSesIDkey       @"sesID"
#define kMoveTypeKey    @"moveType"
#define kRefTimeoutKey  @"refTimeout"
#define kStartDateKey   @"startDate"
#define kStopDateKey    @"stopDate"

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.routeParts forKey:kRouteParts];
    [encoder encodeObject:self.sessionId forKey:kSesIDkey];
    [encoder encodeInt:self.moveType forKey:kMoveTypeKey];
    [encoder encodeFloat:self.refreshTimeout forKey:kRefTimeoutKey];
    [encoder encodeObject:self.startSessionDate forKey:kStartDateKey];
    [encoder encodeObject:self.stopSessionDate forKey:kStopDateKey];
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSArray *routeParts = (NSArray *)[decoder decodeObjectForKey:kRouteParts];
    AGRoute *route = [self initWithRouteParts:routeParts];
    [route setSessionId:(NSString *)[decoder decodeObjectForKey:kSesIDkey]];
    [route setMoveType:[decoder decodeIntForKey:kMoveTypeKey]];
    [route setRefreshTimeout:[decoder decodeFloatForKey:kRefTimeoutKey]];
    [route setStartSessionDate:(NSDate *)[decoder decodeObjectForKey:kStartDateKey]];
    [route setStopSessionDate:(NSDate *)[decoder decodeObjectForKey:kStopDateKey]];
    return route;
}

@end
