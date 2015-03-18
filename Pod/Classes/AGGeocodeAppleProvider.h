//
//  AGGeocodeAppleProvider.h
//  LocationDispatch
//
//  Created by Ankudinov Alexander on 2/10/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "AGGeocodeBaseProvider.h"
#import <CoreLocation/CoreLocation.h>

@interface AGGeocodeAppleProvider : AGGeocodeBaseProvider

@property (strong, nonatomic) CLGeocoder *appleGeocoder;

@end
