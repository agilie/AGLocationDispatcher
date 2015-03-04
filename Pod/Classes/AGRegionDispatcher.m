//
//  AGRegionMonitorDispatch.m
//  Pods
//
//  Created by Vermillion on 19.02.15.
//
//

#import "AGRegionDispatcher.h"
#import "AGDispatcherDefines.h"

@interface AGRegionDispatcher ()

@property (copy) AGLocationServiceAuthorizationStatusChangeBlock regionAuthorizationStatusChangeBlock;
@property (strong, nonatomic) NSMutableArray *regionAuthorizationRequests;
@property (strong, nonatomic) NSMutableArray *delegates;

// Region Blocks
@property (copy) AGLocationServiceRegionUpdateBlock regionBlock;
@property (copy) AGLocationServiceRegionUpdateFailBlock errorRegionBlock;

- (BOOL)isMonitoringThisRegion:(CLRegion *)region;

@end

@implementation AGRegionDispatcher

- (instancetype)init {
    self = [super init];
    if (self) {
        //default location init
    }
    return self;
}

+ (BOOL)regionMonitoringAvailable:(Class)regionClass {
    return [CLLocationManager isMonitoringAvailableForClass:regionClass];
}

#pragma mark - Getter

- (NSMutableArray *)delegates {
    if (!_delegates) {
        _delegates = [NSMutableArray array];
    }
    return _delegates;
}

- (NSMutableArray *)regionAuthorizationRequests {
    if (!_regionAuthorizationRequests) {
        _regionAuthorizationRequests = [NSMutableArray array];
    }
    return _regionAuthorizationRequests;
}

#pragma Region Location Delegate


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if (self.regionBlock != nil) {
        self.regionBlock(manager, region, YES);
    }
    for (id<AGLocationRegionServiceDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(didEnterRegion:)]) {
            [delegate didEnterRegion:region];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if (self.regionBlock != nil) {
        self.regionBlock(manager, region, NO);
    }
    for (id<AGLocationRegionServiceDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(didExitRegion:)]) {
            [delegate didExitRegion:region];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    if (self.errorRegionBlock != nil) {
        self.errorRegionBlock(manager, region, error);
    }
    for (id<AGLocationRegionServiceDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(monitoringDidFailForRegion:withError:)]) {
            [delegate monitoringDidFailForRegion:nil withError:error];
        }
    }
}

#pragma mark - Region Monitoring

- (void)addRegionForMonitoring:(CLRegion *)region desiredAccuracy:(CLLocationAccuracy)accuracy updateBlock:(AGLocationServiceRegionUpdateBlock)block errorBlock:(AGLocationServiceRegionUpdateFailBlock)errorBlock {
    self.regionBlock = block;
    self.errorRegionBlock = errorBlock;
    [self addRegionForMonitoring:region desiredAccuracy:accuracy];
}

- (void)requestRegionLocationWhenInUseWithBlock:(AGLocationServiceAuthorizationStatusChangeBlock)block {
    self.regionAuthorizationStatusChangeBlock = block;
    [self requestUserLocationWhenInUse];
}

- (void)requestRegionLocationAlwaysWithBlock:(AGLocationServiceAuthorizationStatusChangeBlock)block {
    self.regionAuthorizationStatusChangeBlock = block;
    [self requestUserLocationAlways];
}

- (void)requestRegionLocationWhenInUseWithBlockOnce:(AGLocationServiceAuthorizationStatusChangeBlock)block {
    [_regionAuthorizationRequests addObject:[block copy]];
    [self requestUserLocationWhenInUse];
}

- (void)requestRegionLocationAlwaysWithBlockOnce:(AGLocationServiceAuthorizationStatusChangeBlock)block {
    [_regionAuthorizationRequests addObject:[block copy]];
    [self requestUserLocationAlways];
}

#pragma mark - Manage Delegates

- (void)addDelegate:(id<AGLocationRegionServiceDelegate>)delegate {
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}

- (void)removeDelegate:(id<AGLocationRegionServiceDelegate>)delegate {
    if ([self.delegates containsObject:delegate]) {
        [self.delegates removeObject:delegate];
    }
}

#pragma mark - Helpers

- (BOOL)isMonitoringThisRegion:(CLRegion *)region {
    NSLog(@"[%@] isMonitoringThisRegion:", NSStringFromClass([self class]));
    NSSet *regions = self.regionLocationManager.monitoredRegions;
    for (CLRegion *reg in regions) {
        if ([self region:region inRegion:reg]) {
            return YES;
        }
    }
    return NO;
}

@end
