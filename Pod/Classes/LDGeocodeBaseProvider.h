//
//  LDBaseGeocerProvider.h
//  LocationDispatch
//
//  Created by Ankudinov Alexander on 2/9/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AFNetworking.h"

typedef void (^requestBlock)(id, NSError *);

typedef void (^parserBlock)(id, NSError *);

@interface LDGeocodeBaseProvider : NSObject

@property NSInteger resultMaxCount;
@property (strong, atomic) NSString *resultIsoRegionAndLocalizationCode;
@property (strong, atomic) NSString *resultRegionPrefix;
@property (strong, atomic) NSString *apiKey;

- (void)requestLocationForAddress:(NSString *)address andReadyBlock:(requestBlock)requestBlock;

- (void)requestGeocodeForLocation:(CLLocation *)location andReadyBlock:(requestBlock)requestBlock;

- (void)makeRequest:(NSString *)urlString andParameters:(NSDictionary *)parameters andReadyBlock:(requestBlock)requestBlock;

@end
