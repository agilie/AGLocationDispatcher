//
//  AGGeoDispatcher.h
//  Pods
//
//  Created by Vermillion on 19.02.15.
//
//

#import "LDGeocodeBaseProvider.h"
#import "LDLocationDispatch.h"

typedef void (^GeoSuccesBlock)(id);

typedef void (^LocSuccesBlock)(id);

typedef void (^FailBlock)(NSError *);

@interface LDGeoLocationDispatch : LDLocationDispatch

@property (strong, nonatomic) LDGeocodeBaseProvider *geocodeProvider;

- (instancetype)init;

- (instancetype)initWithGeocodeProvider:(AGGeocodeBaseProvider *)provider;

- (void)setGeocodeServiceApiKey:(NSString *)apiKey languageRegionIso:(NSString *)isoCode andResultCount:(NSInteger)maxResultCount andRegionNamePrefix:(NSString *)prefix;

- (void)requestGeocodeForLocation:(CLLocation *)location success:(GeoSuccesBlock)completionHandler andFail:(FailBlock)failHandler;

- (void)requestLocationForAddress:(NSString *)address success:(LocSuccesBlock)completionHandler andFail:(FailBlock)failHandler;

- (void)setGeocoderProvider:(AGGeocodeBaseProvider *)provider;

- (void)setGeocoderProvider:(LDGeocodeBaseProvider *)provider withApiKey:(NSString *)key;

- (void)setGeocoderProvider:(LDGeocodeBaseProvider *)provider withApiKey:(NSString *)key andISOLanguageAndRegionCode:(NSString *)lanRegCode;

@end
