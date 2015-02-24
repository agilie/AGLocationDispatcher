//
//  LDGeoLocationDispatch.m
//  Pods
//
//  Created by Vermillion on 19.02.15.
//
//

#import "LDGeoLocationDispatch.h"
#import "LDLocationDefines.h"
#import "LDGeocodeYandexProvider.h"
#import "LDGeocodeGoogleProvider.h"
#import "LDGeocodeAppleProvider.h"

@implementation LDGeoLocationDispatch

- (id)init {
    self = [super init];
    self.geocodeProvider = [[LDGeocodeYandexProvider alloc] init];
    return self;
};

- (id)initWithGeocodeProvider:(LDGeocodeBaseProvider *)provider {
    self = [super init];
    self.geocodeProvider = provider;
    return self;
};

- (void)setGeocodeServiceApiKey:(NSString *)apiKey languageRegionIso:(NSString *)isoCode andRezultCount:(NSInteger)maxRezultCount andRegionNamePrefix:(NSString *)prefix {
    if (maxRezultCount > 0) {
        self.geocodeProvider.resultMaxCount = maxRezultCount;
    }
    if (apiKey) {
        self.geocodeProvider.apiKey = apiKey;
    }
    if (isoCode) {
        self.geocodeProvider.resultIsoRegionAndLocalizationCode = isoCode;
    }
    if (isoCode) {
        self.geocodeProvider.resultRegionPrefix = prefix;
    }
};

- (void)requestGeocodeForLocation:(CLLocation *)location success:(GeoSuccesBlock)completionHandler andFail:(FailBlock)failHandler {
    [self.geocodeProvider requestGeocodeForLocation: location andReadyBlock: ^(id data, NSError *err) {
        if (err) {
            failHandler(err);
        } else {
            completionHandler(data);
        }
    }];
};

- (void)requestLocationForAddress:(NSString *)address success:(LocSuccesBlock)completionHandler andFail:(FailBlock)failHandler {
    [self.geocodeProvider requestLocationForAddress: address andReadyBlock: ^(id data, NSError *err) {
        if (err) {
            failHandler(err);
        } else {
            completionHandler(data);
        }
        
    }];
    
};

#pragma mark - Setter

- (void)setGeocoderProvider:(LDGeocodeBaseProvider *)provider {
    [self setGeocoderProvider: provider withApiKey: nil andISOLanguageAndRegionCode:nil];
};

- (void)setGeocoderProvider:(LDGeocodeBaseProvider *)provider withApiKey:(NSString *)key andISOLanguageAndRegionCode:(NSString *)lanRegCode {
    
    self.geocodeProvider = provider;
    
    [self setGeocodeServiceApiKey:key languageRegionIso:lanRegCode andRezultCount:1 andRegionNamePrefix:@""];
};

@end
