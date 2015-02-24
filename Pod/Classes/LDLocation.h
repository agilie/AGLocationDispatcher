//
//  LDLocation.h
//  LocationDispatch
//
//  Created by Vermillion on 16.02.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface LDLocation : CLLocation

- (NSNumber *)user_id;

- (NSNumber *)battery;

- (void)setUser_id:(NSNumber *)user_id;

- (void)setBattery:(NSNumber *)battery;

@end
