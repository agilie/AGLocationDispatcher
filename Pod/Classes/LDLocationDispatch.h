//
//  LDLocationDispatch.h
//  LocationDispatch
//
//  Created by Vladimir Zgonik on 09.02.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "LDGeoLocationDispatch.h"
#import "LDLocation.h"

@class LDGeocodeBaseProvider;

@protocol LDLocationServiceDelegate<NSObject>

@optional

- (void)didUpdateUserLocation:(CLLocation *)newLocation;

- (void)didUpdateUserLocation:(CLLocation *)newLocation speed:(NSNumber *)speed;

- (void)didChangeUserAuthorizationStatus:(CLAuthorizationStatus)status;

- (void)didFailWithError:(NSError *)error;

@end

typedef void(^SenderBlock)(id data);

typedef void(^LDLocationServiceAuthorizationStatusChangeBlock)(CLLocationManager *manager, CLAuthorizationStatus status);

typedef void(^LDLocationServiceLocationUpdateBlock)(CLLocationManager *manager, LDLocation *newLocation, LDLocation *oldLocation);

typedef void(^LDLocationServiceLocationAndSpeedUpdateBlock)(CLLocationManager *manager, LDLocation *newLocation, LDLocation *oldLocation, NSNumber *speed);

typedef void(^LDLocationServiceLocationUpdateFailBlock)(CLLocationManager *manager, NSError *error);

@interface LDLocationDispatch : NSObject<CLLocationManagerDelegate>

@property (strong, nonatomic) LDLocation *location;
@property (assign, nonatomic) NSTimeInterval locationUpdateInterval;
@property (assign, nonatomic) BOOL locationServicesEnabled;
@property (assign, nonatomic) BOOL locationObtained;

+ (BOOL)locationServicesEnabled;

+ (BOOL)significantLocationChangeMonitoringAvailable;

- (instancetype)init;

- (instancetype)initWithUpdatingInterval:(NSTimeInterval)interval andDesiredAccuracy:(CLLocationAccuracy)horizontalAccuracy;

- (void)startUpdatingLocation;

- (void)stopUpdatingLocation;

- (void)requestUserLocationWhenInUse;

- (void)requestUserLocationAlways;

- (void)requestUserLocationWhenInUseWithBlock:(LDLocationServiceAuthorizationStatusChangeBlock)block;

- (void)requestUserLocationAlways:(LDLocationServiceAuthorizationStatusChangeBlock)block;

- (void)requestUserLocationWhenInUseWithBlockOnce:(LDLocationServiceAuthorizationStatusChangeBlock)block;

- (void)requestUserLocationAlwaysOnce:(LDLocationServiceAuthorizationStatusChangeBlock)block;

- (void)currentPosition:(LDLocationServiceLocationUpdateBlock)onSucess onError:(LDLocationServiceLocationUpdateFailBlock)onError;

- (void)startUpdatingLocationWithBlock:(LDLocationServiceLocationUpdateBlock)block errorBlock:(LDLocationServiceLocationUpdateFailBlock)errorBlock;

- (void)startUpdatingLocationAndSpeedWithBlock:(LDLocationServiceLocationAndSpeedUpdateBlock)block errorBlock:(LDLocationServiceLocationUpdateFailBlock)errorBlock;

- (void)addDelegate:(id<LDLocationServiceDelegate>)delegate;

- (void)removeDelegate:(id<LDLocationServiceDelegate>)delegate;

@end
