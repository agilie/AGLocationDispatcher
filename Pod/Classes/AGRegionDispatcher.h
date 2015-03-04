//
//  AGRegionMonitorDispatch.h
//  Pods
//
//  Created by Vermillion on 19.02.15.
//
//

#import "AGLocationDispatcher.h"

typedef void(^AGLocationServiceRegionUpdateBlock)(CLLocationManager *manager, CLRegion *region, BOOL enter);

typedef void(^AGLocationServiceRegionUpdateFailBlock)(CLLocationManager *manager, CLRegion *region, NSError *error);

@protocol AGLocationRegionServiceDelegate <AGLocationServiceDelegate>

@optional

- (void)didEnterRegion:(CLRegion *)region;

- (void)didExitRegion:(CLRegion *)region;

- (void)monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error;

@end

@interface AGRegionDispatcher : AGLocationDispatcher <AGLocationRegionServiceDelegate>

- (instancetype)init;

+ (BOOL)regionMonitoringAvailable:(Class)regionClass;

- (void)addCoordinateForMonitoring:(CLLocationCoordinate2D)coordinate withRadius:(CLLocationDistance)radius desiredAccuracy:(CLLocationAccuracy)accuracy;

- (void)addRegionForMonitoring:(CLRegion *)region desiredAccuracy:(CLLocationAccuracy)accuracy updateBlock:(AGLocationServiceRegionUpdateBlock)block errorBlock:(AGLocationServiceRegionUpdateFailBlock)errorBlock;

- (void)stopMonitoringForRegion:(CLRegion *)region;

- (void)stopMonitoringAllRegions;

- (void)addDelegate:(id<AGLocationRegionServiceDelegate>)delegate;

- (void)removeDelegate:(id<AGLocationRegionServiceDelegate>)delegate;

@end
