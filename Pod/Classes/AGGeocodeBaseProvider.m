//
//  AGBaseGeocerProvider.m
//  LocationDispatch
//
//  Created by Ankudinov Alexander on 2/9/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "AGGeocodeBaseProvider.h"

@implementation AGGeocodeBaseProvider

- (id)init {
    self = [super init];
    self.resultMaxCount = 1;
    self.resultIsoRegionAndLocalizationCode = @"";
    self.resultRegionPrefix = @"";
    self.apiKey = @"";

    return self;
}

- (void)requestLocationForAddress:(NSString *)address andReadyBlock:(requestBlock)requestBlock {
    requestBlock(nil, [NSError errorWithDomain:@"com.agilie.pod.locationDispatch" code:1 userInfo:@{ @"AGGeocoderProvider" : @"Base provider class not implement any service" }]);
};

- (void)requestGeocodeForLocation:(CLLocation *)location andReadyBlock:(requestBlock)requestBlock {
    requestBlock(nil, [NSError errorWithDomain:@"com.agilie.pod.locationDispatch" code:1 userInfo:@{ @"AGGeocoderProvider" : @"Base provider class not implement any service" }]);
};


- (void)makeRequest:(NSString *)urlString andParameters:(NSDictionary *)parameters andReadyBlock:(requestBlock)requestBlock {

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        requestBlock(responseObject, nil);
        NSLog(@"JSON: %@", responseObject);
    }    failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        requestBlock(nil, error);
        NSLog(@"Error: %@", error);
    }];

};

@end
