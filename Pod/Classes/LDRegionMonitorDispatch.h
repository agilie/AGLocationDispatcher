//
//  LDRegionMonitorDispatch.h
//  Pods
//
//  Created by Vermillion on 19.02.15.
//
//

#import "LDLocationService.h"

@protocol LDLocationRegionServiceDelegate <NSObject>

@optional

- (void)didChangeRegionAuthorizationStatus:(CLAuthorizationStatus)status;
- (void)didEnterRegion:(CLRegion *)region;
- (void)didExitRegion:(CLRegion *)region;
- (void)monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error;

@end

@interface LDRegionMonitorDispatch : LDLocationService <LDLocationServiceDelegate>

- (instancetype)init;

+ (BOOL)regionMonitoringAvailable:(Class)regionClass;

- (void)addDelegate:(id <LDLocationRegionServiceDelegate>)delegate;
- (void)removeDelegate:(id <LDLocationRegionServiceDelegate>)delegate;

@end
