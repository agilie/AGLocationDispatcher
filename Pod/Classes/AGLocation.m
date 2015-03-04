//
//  AGLocation.m
//  LocationDispatch
//
//  Created by Vermillion on 16.02.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "AGLocation.h"

@interface AGLocation ()

@property (nonatomic, retain) NSNumber *user_id;   //!< User id.
@property (nonatomic, retain) NSNumber *battery;   //!< Battery state.

@end

@implementation AGLocation

@synthesize user_id = _user_id;
@synthesize battery = _battery;

- (NSNumber *)user_id {
    return _user_id;
}

- (NSNumber *)battery {
    return _battery;
}

- (void)setUser_id:(NSNumber *)user_id {
    _user_id = user_id;
}

- (void)setBattery:(NSNumber *)battery {
    _battery = battery;
}

@end
