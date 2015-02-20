//
//  LDRegionMonitorDispatch.m
//  Pods
//
//  Created by Vermillion on 19.02.15.
//
//

#import "LDRegionMonitorDispatch.h"
#import "LDLocationDefines.h"

typedef void(^LDLocationServiceRegionUpdateBlock)(CLLocationManager *manager, CLRegion *region, BOOL enter);
typedef void(^LDLocationServiceRegionUpdateFailBlock)(CLLocationManager *manager, CLRegion *region, NSError *error);

@interface LDRegionMonitorDispatch ()

@property (copy) LDLocationServiceAuthorizationStatusChangeBlock regionAuthorizationStatusChangeBlock;
@property (strong, nonatomic) NSMutableArray *regionAuthorizationRequests;
@property (strong, nonatomic) NSMutableArray *delegates;

// Region Blocks
@property (copy) LDLocationServiceRegionUpdateBlock regionBlock;
@property (copy) LDLocationServiceRegionUpdateFailBlock errorRegionBlock;

@end

@implementation LDRegionMonitorDispatch

- (instancetype)init {
    //default location init
    self = [super init];
    if (self) {
        [super addDelegate:self];
    }
    return self;
}

+ (BOOL)regionMonitoringAvailable:(Class)regionClass {
    return [CLLocationManager isMonitoringAvailableForClass:regionClass];
}

- (void)requestRegionLocationWhenInUseWithBlock:(LDLocationServiceAuthorizationStatusChangeBlock)block {
    self.regionAuthorizationStatusChangeBlock = block;
    [self requestUserLocationWhenInUse];
}

- (void)requestRegionLocationAlwaysWithBlock:(LDLocationServiceAuthorizationStatusChangeBlock)block {
    self.regionAuthorizationStatusChangeBlock = block;
    [self requestUserLocationAlways];
}

- (void)requestRegionLocationWhenInUseWithBlockOnce:(LDLocationServiceAuthorizationStatusChangeBlock)block {
    [_regionAuthorizationRequests addObject:[block copy]];
    [self requestUserLocationWhenInUse];
}

- (void)requestRegionLocationAlwaysWithBlockOnce:(LDLocationServiceAuthorizationStatusChangeBlock)block {
    [_regionAuthorizationRequests addObject:[block copy]];
    [self requestUserLocationAlways];
}

- (void)didChangeUserAuthorizationStatus:(CLAuthorizationStatus)status {
    for (id <LDLocationRegionServiceDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(didChangeRegionAuthorizationStatus:)]) {
            [delegate didChangeRegionAuthorizationStatus:status];
        }
    }
}

- (void)didUpdateUserLocation:(CLLocation *)newLocation {
    //check region
    for (id <LDLocationRegionServiceDelegate> delegate in self.delegates) {
        //        if ([delegate respondsToSelector:@selector(didEnterRegion:)]) {
        //            [delegate didEnterRegion:[CLRegion new]];
        //        }
        //        if ([delegate respondsToSelector:@selector(didExitRegion:)]) {
        //            [delegate didExitRegion:[CLRegion new]];
        //        }
        //        if ([delegate respondsToSelector:@selector(monitoringDidFailForRegion:withError:)]) {
        //            [delegate monitoringDidFailForRegion:[CLRegion new] withError:[NSError new]];
        //        }
    }
}

- (NSMutableArray *)regionAuthorizationRequests {
    if (!_regionAuthorizationRequests) {
        _regionAuthorizationRequests = [NSMutableArray array];
    }
    return _regionAuthorizationRequests;
}

- (NSMutableArray *)delegates {
    if (!_delegates) {
        _delegates = [NSMutableArray array];
    }
    return _delegates;
}

- (void)addDelegate:(id<LDLocationRegionServiceDelegate>)delegate {
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}

- (void)removeDelegate:(id<LDLocationRegionServiceDelegate>)delegate {
    if ([self.delegates containsObject:delegate]) {
        [self.delegates removeObject:delegate];
    }
}

@end
