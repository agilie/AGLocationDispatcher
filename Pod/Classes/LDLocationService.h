//
//  LDLocationService.h
//  LocationDispatch
//
//  Created by Vladimir Zgonik on 09.02.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "LDGeocoderManager.h"

@class LDGeocodeBaseProvider;

@protocol LDLocationServiceDelegate <NSObject>

@optional

- (void)didUpdateUserLocation:(CLLocation *)newLocation;
- (void)didChangeUserAuthorizationStatus:(CLAuthorizationStatus)status;
- (void)didChangeRegionAuthorizationStatus:(CLAuthorizationStatus)status;
- (void)didFailWithError:(NSError *)error;
- (void)didEnterRegion:(CLRegion *)region;
- (void)didExitRegion:(CLRegion *)region;
- (void)monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error;

@end

typedef void(^SenderBlock)(id data);
typedef void(^LDLocationServiceAuthorizationStatusChangeBlock)(CLLocationManager *manager, CLAuthorizationStatus status);
typedef void(^LDLocationServiceLocationUpdateBlock)(CLLocationManager *manager, CLLocation *newLocation, CLLocation *oldLocation);
typedef void (^LDLocationServiceLocationUpdateFailBlock)(CLLocationManager *manager, NSError *error);
typedef void(^LDLocationServiceRegionUpdateBlock)(CLLocationManager *manager, CLRegion *region, BOOL enter);
typedef void(^LDLocationServiceRegionUpdateFailBlock)(CLLocationManager *manager, CLRegion *region, NSError *error);

@interface LDLocationService : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocation *location;
@property (assign, nonatomic) NSTimeInterval locationUpdateInterval;
@property (assign, nonatomic) BOOL locationServicesEnabled;
@property (assign, nonatomic) BOOL locationObtained;

+ (BOOL)locationServicesAvaliable;
+ (BOOL)locationServicesEnabled;
+ (BOOL)regionMonitoringAvailable:(Class)regionClass;
+ (BOOL)significantLocationChangeMonitoringAvailable;

- (instancetype)init;
- (instancetype)initWithUpdatingInterval:(NSTimeInterval)interval andDesiredAccuracy:(CLLocationAccuracy)horizontalAccuracy;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
- (void)updateUserLocation;
- (void)requestUserLocationWhenInUse;
- (void)requestUserLocationAlways;
- (void)requestUserLocationWhenInUseWithBlock:(LDLocationServiceAuthorizationStatusChangeBlock)block;
- (void)requestUserLocationAlways:(LDLocationServiceAuthorizationStatusChangeBlock)block;
- (void)requestUserLocationWhenInUseWithBlockOnce:(LDLocationServiceAuthorizationStatusChangeBlock)block;
- (void)requestUserLocationAlwaysOnce:(LDLocationServiceAuthorizationStatusChangeBlock)block;

- (void)requestGeocodeForLocation:(CLLocation *)location success:(GeoSuccesBlock)completionHandler andFail:(FailBlock)failHandler;
- (void)requestLocationForAddress:(NSString *)address success:(LocSuccesBlock)completionHandler andFail:(FailBlock)failHandler;

- (void)currentPosition:(LDLocationServiceLocationUpdateBlock)onSucess onError:(LDLocationServiceLocationUpdateFailBlock)onError;
- (void)startUpdatingLocationWithBlock:(LDLocationServiceLocationUpdateBlock)block errorBlock:(LDLocationServiceLocationUpdateFailBlock)errorBlock;
- (void)addDelegate:(id <LDLocationServiceDelegate>)delegate;
- (void)removeDelegate:(id <LDLocationServiceDelegate>)delegate;

- (void)setGeocoderProvider:(LDGeocodeBaseProvider *)provider;

- (void)setGeocoderProvider:(LDGeocodeBaseProvider *)provider withApiKey:(NSString *)key andISOLanguageAndRegionCode:(NSString *)lanRegCode;

@end
