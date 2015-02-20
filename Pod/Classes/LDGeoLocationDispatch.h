//
//  LDGeoLocationDispatch.h
//  Pods
//
//  Created by Vermillion on 19.02.15.
//
//

#import "LDLocationService.h"

@interface LDGeoLocationDispatch : LDLocationService

- (instancetype)init;

- (void)requestGeocodeForLocation:(CLLocation *)location success:(GeoSuccesBlock)completionHandler andFail:(FailBlock)failHandler;
- (void)requestLocationForAddress:(NSString *)address success:(LocSuccesBlock)completionHandler andFail:(FailBlock)failHandler;

- (void)setGeocoderProvider:(LDGeocodeBaseProvider *)provider;
- (void)setGeocoderProvider:(LDGeocodeBaseProvider *)provider withApiKey:(NSString *)key andISOLanguageAndRegionCode:(NSString *)lanRegCode;

@end
