//
//  LDGeocodeAppleProvider.m
//  LocationDispatch
//
//  Created by Ankudinov Alexander on 2/10/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "LDGeocodeAppleProvider.h"

@implementation LDGeocodeAppleProvider


-(id)init{
    self = [super init];
    self.appleGeocoder = [[CLGeocoder alloc] init];
    return self;
}

- (void)requestLocationForAddress:(NSString *)address andReadyBlock:(requestBlock)requestBlock{
    
    [self.appleGeocoder geocodeAddressString: address completionHandler:^(NSArray *placemarks, NSError *error) {
      
        NSMutableArray *rezult = [NSMutableArray array];
        
        if([placemarks isKindOfClass:[NSArray class]]) {
        
            for (CLPlacemark *place in placemarks){
                [rezult addObject: place.location];
            }
        }
        
        requestBlock(rezult , error);
        
    }];
};

- (void)requestGeocodeForLocation:(CLLocation *)location  andReadyBlock:(requestBlock)requestBlock{
    
    [self.appleGeocoder reverseGeocodeLocation: location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        NSMutableArray *rezult = [NSMutableArray array];
        
        if([placemarks isKindOfClass:[NSArray class]]) {
            
            for (CLPlacemark *place in placemarks){
                
                NSArray *lines = place.addressDictionary[ @"FormattedAddressLines"];
                NSString *addressString = [lines componentsJoinedByString:@"\n"];
                
                [rezult addObject: addressString];
            }
        }
        
        requestBlock(rezult , error);
        
    }];
    
};


@end
