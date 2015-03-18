//
//  AGRegionDispatcher.h
//  Pods
//
//  Created by Vermillion on 19.02.15.
//
//

#import "AGLocationDispatcher.h"

typedef void(^AGLocationServiceRegionUpdateBlock)(CLLocationManager *manager, CLCircularRegion *region, BOOL enter);

typedef void(^AGLocationServiceRegionUpdateFailBlock)(CLLocationManager *manager, CLCircularRegion *region, NSError *error);

@interface AGRegionDispatcher : AGLocationDispatcher

+ (BOOL)regionMonitoringAvailable:(Class)regionClass;

- (instancetype)init;

- (void)addCoordinateForMonitoring:(CLLocationCoordinate2D)coordinate updateBlock:(AGLocationServiceRegionUpdateBlock)block failBlock:(AGLocationServiceRegionUpdateFailBlock)failBlock;

- (void)addCoordinateForMonitoring:(CLLocationCoordinate2D)coordinate withRadius:(CLLocationDistance)radius desiredAccuracy:(CLLocationAccuracy)accuracy updateBlock:(AGLocationServiceRegionUpdateBlock)block failBlock:(AGLocationServiceRegionUpdateFailBlock)failBlock;

- (void)addRegionForMonitoring:(CLRegion *)region desiredAccuracy:(CLLocationAccuracy)accuracy updateBlock:(AGLocationServiceRegionUpdateBlock)block failBlock:(AGLocationServiceRegionUpdateFailBlock)failBlock;

- (void)stopMonitoringForRegion:(CLRegion *)region;

- (void)stopMonitoringAllRegions;

@end
