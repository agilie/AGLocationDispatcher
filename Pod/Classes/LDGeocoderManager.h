//
//  LDAdressGeocoderClass.h
//  LocationDispatch
//
//  Created by Ankudinov Alexander on 2/9/15.
//  Copyright (c) 2015 Agilie.com All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDGeocodeBaseProvider.h"

typedef void (^GeoSuccesBlock) (id);
typedef void (^LocSuccesBlock) (id);
typedef void (^FailBlock) (NSError *);

@interface LDGeocoderManager : NSObject

@property (strong,atomic) LDGeocodeBaseProvider * geocodeProvider;

- (id)init;
- (id)initWithGeocodeProvider:(LDGeocodeBaseProvider *)provider;

- (void)setGeocodeServiceApiKey:(NSString *)apiKey languageRegionIso:(NSString *)isoCode andRezultCount:(NSInteger)maxRezultCount andRegionNamePrefix:(NSString *)prefix;

- (void)requestGeocodeForLocation:(CLLocation *)location success:(GeoSuccesBlock)completionHandler andFail:(FailBlock)failHandler;
- (void)requestLocationForAddress:(NSString *)address success:(LocSuccesBlock)completionHandler andFail:(FailBlock)failHandler;


@end
