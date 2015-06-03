//
//  AGRegionDispatcher.m
//  Pods
//
//  Created by Vermillion on 19.02.15.
//
//

#import "AGRegionDispatcher.h"
#import "AGDispatcherDefines.h"

#define MAX_MONITORING_REGIONS 20

#define kDefaultRegionRadiusDistance  500

@interface AGRegionDispatcher ()

@property (strong, nonatomic) NSMutableArray *regionAuthorizationRequests;
@property (assign, nonatomic) CGFloat regionRadiusDistance;

// Region Blocks
@property (strong, nonatomic) NSMutableDictionary *regionBlocks;
@property (strong, nonatomic) NSMutableDictionary *failRegionBlocks;

@end

@implementation AGRegionDispatcher

- (instancetype)init {
    self = [super init];
    if (self) {
        self.regionRadiusDistance = kDefaultRegionRadiusDistance;
    }
    return self;
}

+ (BOOL)regionMonitoringAvailable:(Class)regionClass {
    return [CLLocationManager isMonitoringAvailableForClass:regionClass];
}

#pragma mark - Getter

- (NSMutableArray *)regionAuthorizationRequests {
    if (!_regionAuthorizationRequests) {
        _regionAuthorizationRequests = [NSMutableArray array];
    }
    return _regionAuthorizationRequests;
}

- (NSMutableDictionary *)regionBlocks {
    if (!_regionBlocks) {
        _regionBlocks = [NSMutableDictionary dictionary];
    }
    return _regionBlocks;
}

- (NSMutableDictionary *)failRegionBlocks {
    if (!_failRegionBlocks) {
        _failRegionBlocks = [NSMutableDictionary dictionary];
    }
    return _failRegionBlocks;
}

#pragma Region Location Delegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLCircularRegion *)region {
    if ([self.regionBlocks valueForKey:region.identifier]) {
        AGLocationServiceRegionUpdateBlock block = [self.regionBlocks valueForKey:region.identifier];
        block(manager, region, YES);
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLCircularRegion *)region {
    if ([self.regionBlocks valueForKey:region.identifier]) {
        AGLocationServiceRegionUpdateBlock block = [self.regionBlocks valueForKey:region.identifier];
        block(manager, region, NO);
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLCircularRegion *)region withError:(NSError *)error {
    if ([self.failRegionBlocks valueForKey:region.identifier]) {
        AGLocationServiceRegionUpdateFailBlock block = [self.failRegionBlocks valueForKey:region.identifier];
        block(manager, region, error);
    }
}

#pragma mark - Region Monitoring

- (void)addCoordinateForMonitoring:(CLLocationCoordinate2D)coordinate updateBlock:(AGLocationServiceRegionUpdateBlock)block failBlock:(AGLocationServiceRegionUpdateFailBlock)failBlock {
    AGLog(@"[%@] addCoordinateForMonitoring:", NSStringFromClass([self class]));
    [self addCoordinateForMonitoring:coordinate withRadius:self.regionRadiusDistance desiredAccuracy:[self horizontalAccuracyThreshold] updateBlock:block failBlock:failBlock];
}

- (void)addCoordinateForMonitoring:(CLLocationCoordinate2D)coordinate withRadius:(CLLocationDistance)radius updateBlock:(AGLocationServiceRegionUpdateBlock)block failBlock:(AGLocationServiceRegionUpdateFailBlock)failBlock {
    [self addCoordinateForMonitoring:coordinate withRadius:radius desiredAccuracy:[self horizontalAccuracyThreshold] updateBlock:block failBlock:failBlock];
}

- (void)addCoordinateForMonitoring:(CLLocationCoordinate2D)coordinate withRadius:(CLLocationDistance)radius desiredAccuracy:(CLLocationAccuracy)accuracy updateBlock:(AGLocationServiceRegionUpdateBlock)block failBlock:(AGLocationServiceRegionUpdateFailBlock)failBlock {
    AGLog(@"[%@] addCoordinateForMonitoring:withRadius:", NSStringFromClass([self class]));
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coordinate radius:radius identifier:[NSString stringWithFormat:@"Region with center (%f, %f) and radius (%f)", coordinate.latitude, coordinate.longitude, radius]];
    [self.regionBlocks addEntriesFromDictionary:@{region.identifier:[block copy]}];
    [self.failRegionBlocks addEntriesFromDictionary:@{region.identifier:[failBlock copy]}];
    [self addRegionForMonitoring:region desiredAccuracy:accuracy];
}

- (void)_addRegionForMonitoring:(CLCircularRegion *)region desiredAccuracy:(CLLocationAccuracy)accuracy {
    NSSet *regions = [self locationManager].monitoredRegions;
    if (regions) NSLog(@"%lu ", (unsigned long)regions.count);
    AGLog(@"[%@] _addRegionForMonitoring:desiredAccuracy: [regions count]: %lu", NSStringFromClass([self class]), (unsigned long)[regions count]);
    NSAssert([CLLocationManager isMonitoringAvailableForClass:[region class]] || [CLLocationManager isMonitoringAvailableForClass:[region class]], @"RegionMonitoring not available!");
    NSAssert([regions count] < MAX_MONITORING_REGIONS, @"Only support %d regions!", MAX_MONITORING_REGIONS);
    NSAssert(accuracy < [self locationManager].maximumRegionMonitoringDistance, @"Accuracy is too long!");
    [[self locationManager] startMonitoringForRegion:region];
}

- (void)addRegionForMonitoring:(CLCircularRegion *)region desiredAccuracy:(CLLocationAccuracy)accuracy {
    AGLog(@"[%@] addRegionForMonitoring:", NSStringFromClass([self class]));
    if (![self isMonitoringThisRegion:region]) {
        [self _addRegionForMonitoring:region desiredAccuracy:accuracy];
    }
}

- (void)addRegionForMonitoring:(CLCircularRegion *)region desiredAccuracy:(CLLocationAccuracy)accuracy updateBlock:(AGLocationServiceRegionUpdateBlock)block failBlock:(AGLocationServiceRegionUpdateFailBlock)failBlock {
    [self.regionBlocks addEntriesFromDictionary:@{region.identifier:[block copy]}];
    [self.failRegionBlocks addEntriesFromDictionary:@{region.identifier:[failBlock copy]}];
    [self addRegionForMonitoring:region desiredAccuracy:accuracy];
}

- (void)stopMonitoringForRegion:(CLCircularRegion *)region {
    AGLog(@"[%@] stopMonitoringForRegion:", NSStringFromClass([self class]));
    [[self locationManager] stopMonitoringForRegion:region];
    [self.regionBlocks removeObjectForKey:region.identifier];
    [self.failRegionBlocks removeObjectForKey:region.identifier];
}

- (void)stopMonitoringAllRegions {
    NSSet *regions = [self locationManager].monitoredRegions;
    AGLog(@"[%@] stopMonitoringAllRegion: [regions count]: %lu", NSStringFromClass([self class]), (unsigned long)[regions count]);
    for (CLCircularRegion *reg in regions) {
        [[self locationManager] stopMonitoringForRegion:reg];
    }
    [self.regionBlocks removeAllObjects];
    [self.failRegionBlocks removeAllObjects];
}

#pragma mark - Helpers

- (BOOL)isMonitoringThisRegion:(CLCircularRegion *)region {
    AGLog(@"[%@] isMonitoringThisRegion:", NSStringFromClass([self class]));
    NSSet *regions = [self locationManager].monitoredRegions;
    for (CLCircularRegion *reg in regions) {
        if ([self region:region inRegion:reg]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)region:(CLCircularRegion *)region inRegion:(CLCircularRegion *)otherRegion {
    AGLog(@"[%@] region:containsRegion:", NSStringFromClass([self class]));
    CLLocation *location = [[CLLocation alloc] initWithLatitude:region.center.latitude longitude:region.center.longitude];
    CLLocation *otherLocation = [[CLLocation alloc] initWithLatitude:otherRegion.center.latitude longitude:otherRegion.center.longitude];
    if ([otherRegion containsCoordinate:region.center]) {
        if ([location distanceFromLocation:otherLocation] + region.radius <= otherRegion.radius ) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isMonitoringThisCoordinate:(CLLocationCoordinate2D)coordinate {
    AGLog(@"[%@] isMonitoringThisCoordinate:", NSStringFromClass([self class]));
    NSSet *regions = [self locationManager].monitoredRegions;
    for (CLCircularRegion *reg in regions) {
        if ([reg containsCoordinate:coordinate]) {
            return YES;
        }
    }
    return NO;
}

@end
