//
//  LDGeocodeGoogleProvider.m
//  LocationDispatch
//
//  Created by Ankudinov Alexander on 2/10/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "LDGeocodeGoogleProvider.h"

@implementation LDGeocodeGoogleProvider

-(id)init{
    self = [super init];
    return self;
}

- (void)requestLocationForAddress:(NSString *)address andReadyBlock:(requestBlock)requestBlock{
    
    [self makeRequest: kAPIGoogleService
        andParameters: [self createRequestParametersToGoogleGeocodingFor: address]
        andReadyBlock: ^(id data, NSError *err) {
            
            if (!err && data){
                data = [self parseGoogleServiceResponse:data withPath:@"results"
                                             andSubPath:@"geometry.location" isLocation:YES];
                
                if(!data) err = [NSError errorWithDomain:@"com.agilie.pod.locationDispatch" code:1 userInfo:@{@"ParsingWrong":@"Google"}];
            }
            requestBlock(data,err);
        }];
    
};

- (void)requestGeocodeForLocation:(CLLocation *)location  andReadyBlock:(requestBlock)requestBlock{
    
    NSString *stringedLocation = [NSString stringWithFormat:@"%f, %f", location.coordinate.latitude, location.coordinate.longitude];
    
    [self makeRequest: kAPIGoogleService
        andParameters: [self createRequestParametersToGoogleGeocodingFor: stringedLocation]
        andReadyBlock: ^(id data, NSError *err) {
            
            if (!err && data){
                data = [self parseGoogleServiceResponse:data withPath:@"results"
                                             andSubPath:@"formatted_address" isLocation:NO];
                
                if(!data) err = [NSError errorWithDomain:@"com.agilie.pod.locationDispatch" code:1 userInfo:@{@"ParsingWrong":@"Google"}];
            }
            requestBlock(data,err);
        }];
};

-(NSDictionary *)createRequestParametersToGoogleGeocodingFor:(id)location{
    return @{ @"address":[NSString stringWithFormat:@"%@ %@" , self.resultRegionPrefix, location],
              @"region": self.resultIsoRegionAndLocalizationCode
              };
}

- (NSArray *)parseGoogleServiceResponse:(id)responce withPath:(NSString*)path andSubPath:(NSString*)subPath isLocation:(BOOL)isLocation{
    
    NSMutableArray *locationArray = nil;
    
    id mainResponceBlock = [responce valueForKeyPath: path];
    
    if([mainResponceBlock isKindOfClass: [NSArray class]]){
        
        locationArray = [NSMutableArray array];
        
        for (id locationSubObject in mainResponceBlock) {
            
            if(![locationSubObject valueForKeyPath: subPath]){
                locationArray = nil;                            //Parsing error!
                break;
            }
            
            id temporaryPoint = [locationSubObject valueForKeyPath: subPath ];
            if(isLocation){
       
                if([temporaryPoint objectForKey:@"lat"] && [temporaryPoint objectForKey:@"lng"]) {
                    
                    NSNumber *lat = [temporaryPoint objectForKey:@"lat"];
                    NSNumber *lng = [temporaryPoint objectForKey:@"lng"];
                    
                    temporaryPoint = [[CLLocation alloc]
                                      initWithLatitude: [lat doubleValue]
                                      longitude: [lng doubleValue] ];
                } else {
                    locationArray = nil;                            //Parsing error!
                    break;
                }
            }
            [locationArray addObject:  temporaryPoint ];
        }
    } else {
        locationArray = nil;                                    //Parsing error!
    }
    
    return locationArray;
}

@end
