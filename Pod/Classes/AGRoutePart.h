//
//  AGRoutePart.h
//  LocationDispatch
//
//  Created by Vermillion on 11.02.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "AGLocation.h"

@interface AGRoutePart : NSObject<NSCoding>

- (void)addRoutePoint:(AGLocation *)point;

- (instancetype)initWithRoutePartPoints:(NSArray *)routePartPoints andSpeeds:(NSArray *)routePartSpeeds;

- (void)addSpeed:(int)speed;

//getters

- (NSMutableArray *)routePartPoints;

- (NSMutableArray *)routePartSpeeds;

- (NSDate *)startSessionDate;

- (NSDate *)stopSessionDate;

- (double)routePartDistance;

//setters

- (void)setStartSessionDate:(NSDate *)startSessionDate;

- (void)setStopSessionDate:(NSDate *)stopSessionDate;

@end
