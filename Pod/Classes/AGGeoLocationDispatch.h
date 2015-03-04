//
//  AGGeoLocationDispatch.h
//  Pods
//
//  Created by Vermillion on 19.02.15.
//
//

#import "AGLocationDispatcher.h"
#import "AGGeocodeBaseProvider.h"

typedef void (^GeoSuccesBlock)(id);

typedef void (^LocSuccesBlock)(id);

typedef void (^FailBlock)(NSError *);

@interface AGGeoLocationDispatch : AGLocationDispatcher

@property (strong, atomic) AGGeocodeBaseProvider *geocodeProvider;

- (instancetype)init;

- (instancetype)initWithGeocodeProvider:(AGGeocodeBaseProvider *)provider;

- (void)setGeocodeServiceApiKey:(NSString *)apiKey languageRegionIso:(NSString *)isoCode andResultCount:(NSInteger)maxResultCount andRegionNamePrefix:(NSString *)prefix;

- (void)requestGeocodeForLocation:(CLLocation *)location success:(GeoSuccesBlock)completionHandler andFail:(FailBlock)failHandler;

- (void)requestLocationForAddress:(NSString *)address success:(LocSuccesBlock)completionHandler andFail:(FailBlock)failHandler;

- (void)setGeocoderProvider:(AGGeocodeBaseProvider *)provider;

- (void)setGeocoderProvider:(AGGeocodeBaseProvider *)provider withApiKey:(NSString *)key andISOLanguageAndRegionCode:(NSString *)lanRegCode;

@end
