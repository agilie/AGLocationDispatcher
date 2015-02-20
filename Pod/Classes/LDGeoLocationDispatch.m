//
//  LDGeoLocationDispatch.m
//  Pods
//
//  Created by Vermillion on 19.02.15.
//
//

#import "LDGeoLocationDispatch.h"
#import "LDLocationDefines.h"

@interface LDGeoLocationDispatch()

@property (strong, nonatomic) LDGeocoderManager *geocoderManager;

@end

@implementation LDGeoLocationDispatch

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)requestGeocodeForLocation:(CLLocation *)location success:(GeoSuccesBlock)completionHandler andFail:(FailBlock)failHandler {
    
    [self.geocoderManager requestGeocodeForLocation:location success:completionHandler andFail:failHandler];
};

- (void)requestLocationForAddress:(NSString *)address success:(LocSuccesBlock)completionHandler andFail:(FailBlock)failHandler {
    
    [self.geocoderManager requestLocationForAddress:address success:completionHandler andFail:failHandler];
};

#pragma mark - Setter

- (void)setGeocoderProvider:(LDGeocodeBaseProvider *)provider {
    [self setGeocoderProvider: provider withApiKey: nil andISOLanguageAndRegionCode:nil];
};

- (void)setGeocoderProvider:(LDGeocodeBaseProvider *)provider withApiKey:(NSString *)key andISOLanguageAndRegionCode:(NSString *)lanRegCode {
    
    _geocoderManager =  [[LDGeocoderManager alloc] initWithGeocodeProvider: provider];
    
    [_geocoderManager setGeocodeServiceApiKey:key languageRegionIso:lanRegCode andRezultCount:1 andRegionNamePrefix:@""];
};

#pragma mark - Getters

- (LDGeocoderManager *)geocoderManager {
    if(!_geocoderManager) {
        _geocoderManager = [[LDGeocoderManager alloc] init];
    }
    
    return _geocoderManager;
}

@end
