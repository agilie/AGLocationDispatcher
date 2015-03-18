//
//  AGGeoDispatcher.m
//  Pods
//
//  Created by Vermillion on 19.02.15.
//
//

#import "AGGeoDispatcher.h"
#import "AGDispatcherDefines.h"
#import "AGGeocodeYandexProvider.h"
#import "AGGeocodeGoogleProvider.h"
#import "AGGeocodeAppleProvider.h"

@implementation AGGeoDispatcher

- (id)init {
    self = [super init];
    if (self) {
        self.geocodeProvider = [[AGGeocodeYandexProvider alloc] init];
    }
    return self;
};

- (id)initWithGeocodeProvider:(AGGeocodeBaseProvider *)provider {
    self = [super init];
    self.geocodeProvider = provider;
    return self;
};

- (void)setGeocodeServiceApiKey:(NSString *)apiKey languageRegionIso:(NSString *)isoCode andResultCount:(NSInteger)maxResultCount andRegionNamePrefix:(NSString *)prefix {
    if (maxResultCount > 0) {
        self.geocodeProvider.resultMaxCount = maxResultCount;
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
    [self.geocodeProvider requestGeocodeForLocation:location andReadyBlock:^(id data, NSError *err) {
        if (err) {
            failHandler(err);
        } else {
            completionHandler(data);
        }
    }];
};

- (void)requestLocationForAddress:(NSString *)address success:(LocSuccesBlock)completionHandler andFail:(FailBlock)failHandler {
    [self.geocodeProvider requestLocationForAddress:address andReadyBlock:^(id data, NSError *err) {
        if (err) {
            failHandler(err);
        } else {
            completionHandler(data);
        }

    }];

};

#pragma mark - Setter

- (void)setGeocoderProvider:(AGGeocodeBaseProvider *)provider {
    [self setGeocoderProvider:provider withApiKey:nil andISOLanguageAndRegionCode:nil];
};

- (void)setGeocoderProvider:(LDGeocodeBaseProvider *)provider withApiKey:(NSString *)key {
    [self setGeocoderProvider:provider withApiKey:key andISOLanguageAndRegionCode:nil];
}

- (void)setGeocoderProvider:(LDGeocodeBaseProvider *)provider withApiKey:(NSString *)key andISOLanguageAndRegionCode:(NSString *)lanRegCode {

    self.geocodeProvider = provider;

    [self setGeocodeServiceApiKey:key languageRegionIso:lanRegCode andResultCount:1 andRegionNamePrefix:@""];
};

@end
