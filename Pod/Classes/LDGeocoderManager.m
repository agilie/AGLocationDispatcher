//
//  LDAdressGeocoderClass.m
//  LocationDispatch
//
//  Created by Ankudinov Alexander on 2/9/15.
//  Copyright (c) 2015 Agilie.com All rights reserved.
//

#import "LDGeocoderManager.h"
#import "LDGeocodeYandexProvider.h"
#import "LDGeocodeGoogleProvider.h"
#import "LDGeocodeAppleProvider.h"

@implementation LDGeocoderManager

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

@end
