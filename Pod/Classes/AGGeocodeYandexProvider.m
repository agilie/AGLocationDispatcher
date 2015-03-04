//
//  AGGeocodeYandexProvider.m
//  LocationDispatch
//
//  Created by Ankudinov Alexander on 2/9/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "AGGeocodeYandexProvider.h"

@implementation AGGeocodeYandexProvider

- (id)init {
    self = [super init];
    return self;
}

- (void)requestLocationForAddress:(NSString *)address andReadyBlock:(requestBlock)requestBlock {

    [self makeRequest:kAPIYandexService
        andParameters:[self createRequestParametersToYandexGeocodingFor:address]
        andReadyBlock:^(id data, NSError *err) {

            if (!err && data) {
                data = [self parseYandexServiceResponse:data withPath:@"response.GeoObjectCollection.featureMember"
                                             andSubPath:@"GeoObject.Point.pos" isLocation:YES];

                if (!data) err = [NSError errorWithDomain:@"com.agilie.pod.locationDispatch" code:1 userInfo:@{ @"ParsingWrong" : @"Yandex" }];
            }
            requestBlock(data, err);
        }];

};

- (void)requestGeocodeForLocation:(CLLocation *)location andReadyBlock:(requestBlock)requestBlock {

    NSString *stringedLocation = [NSString stringWithFormat:@"%f, %f", location.coordinate.longitude, location.coordinate.latitude];

    [self makeRequest:kAPIYandexService
        andParameters:[self createRequestParametersToYandexGeocodingFor:stringedLocation]
        andReadyBlock:^(id data, NSError *err) {

            if (!err && data) {
                data = [self parseYandexServiceResponse:data withPath:@"response.GeoObjectCollection.featureMember"
                                             andSubPath:@"GeoObject.metaDataProperty.GeocoderMetaData.AddressDetails.Country.AddressLine" isLocation:NO];

                if (!data) err = [NSError errorWithDomain:@"com.agilie.pod.locationDispatch" code:1 userInfo:@{ @"ParsingWrong" : @"Yandex" }];
            }

            requestBlock(data, err);
        }];
};

- (NSDictionary *)createRequestParametersToYandexGeocodingFor:(id)location {
    return @{ @"format" : @"json",
            @"geocode" : [NSString stringWithFormat:@"%@ %@", self.resultRegionPrefix, location],
            @"lang" : self.resultIsoRegionAndLocalizationCode,
            @"results" : [NSString stringWithFormat:@"%li", (long)self.resultMaxCount],
            @"key" : self.apiKey
    };
}

- (NSArray *)parseYandexServiceResponse:(id)responce withPath:(NSString *)path andSubPath:(NSString *)subPath isLocation:(BOOL)isLocation {

    NSMutableArray *locationArray = nil;

    id mainResponceBlock = [responce valueForKeyPath:path];

    if ([mainResponceBlock isKindOfClass:[NSArray class]]) {

        locationArray = [NSMutableArray array];

        for (id locationSubObject in mainResponceBlock) {

            if (![locationSubObject valueForKeyPath:subPath]) {
                locationArray = nil;                            //Parsing error!
                break;
            }

            id temporaryPoint = [locationSubObject valueForKeyPath:subPath];

            if (isLocation) {
                NSArray *componentLocation = [temporaryPoint componentsSeparatedByString:@" "];
                if ([componentLocation isKindOfClass:[NSArray class]] && [componentLocation count] == 2) {
                    temporaryPoint = [[CLLocation alloc]
                            initWithLatitude:[[componentLocation objectAtIndex:1] floatValue]
                                   longitude:[[componentLocation objectAtIndex:0] floatValue]];
                } else {
                    locationArray = nil; //Parsing error!
                    break;
                }

            }

            [locationArray addObject:temporaryPoint];
        }
    } else {
        locationArray = nil;                                    //Parsing error!
    }

    return locationArray;
}


@end
