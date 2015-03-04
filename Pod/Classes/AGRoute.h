//
//  AGRoute.h
//  LocationDispatch
//
//  Created by Vermillion on 11.02.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "AGRoutePart.h"
#import "AGLocation.h"

@interface AGRoute : NSObject<NSCoding>

- (instancetype)initWithRouteParts:(NSArray *)routeParts;

- (void)addRoutePoint:(AGLocation *)point;

- (void)addSpeed:(int)speed;

- (void)finishRoute;

//getters

- (NSMutableArray *)routePoints;

- (NSMutableArray *)routeParts;

- (NSString *)sessionId;

- (int)moveType;

- (float)refreshTimeout;

- (NSDate *)startSessionDate;

- (NSDate *)stopSessionDate;

- (AGRoutePart *)currentRoutePart;

- (float)averageSpeed;

- (float)maxSpeed;

- (double)routeDistance;

// setters

- (void)setSessionId:(NSString *)sessionId;

- (void)setMoveType:(int)moveType;

- (void)setRefreshTimeout:(float)refreshTimeout;

- (void)setStartSessionDate:(NSDate *)startSessionDate;

- (void)setStopSessionDate:(NSDate *)stopSessionDate;

@end
