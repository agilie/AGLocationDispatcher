//
//  LDGeoLocationDispatch.h
//  Pods
//
//  Created by Vermillion on 19.02.15.
//
//

#import "LDLocationDispatch.h"
#import "LDDispatchHeaders.h"

typedef void (^GeoSuccesBlock)(id);

typedef void (^LocSuccesBlock)(id);

typedef void (^FailBlock)(NSError *);

@interface LDGeoLocationDispatch : NSObject

@property (strong, atomic) LDGeocodeBaseProvider *geocodeProvider;

- (instancetype)init;

- (instancetype)initWithGeocodeProvider:(LDGeocodeBaseProvider *)provider;

- (void)setGeocodeServiceApiKey:(NSString *)apiKey languageRegionIso:(NSString *)isoCode andRezultCount:(NSInteger)maxRezultCount andRegionNamePrefix:(NSString *)prefix;

- (void)requestGeocodeForLocation:(CLLocation *)location success:(GeoSuccesBlock)completionHandler andFail:(FailBlock)failHandler;

- (void)requestLocationForAddress:(NSString *)address success:(LocSuccesBlock)completionHandler andFail:(FailBlock)failHandler;

- (void)setGeocoderProvider:(LDGeocodeBaseProvider *)provider;

- (void)setGeocoderProvider:(LDGeocodeBaseProvider *)provider withApiKey:(NSString *)key;

- (void)setGeocoderProvider:(LDGeocodeBaseProvider *)provider withApiKey:(NSString *)key andISOLanguageAndRegionCode:(NSString *)lanRegCode;

@end
