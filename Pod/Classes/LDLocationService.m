//
//  LDLocationService.m
//  LocationDispatch
//
//  Created by Vladimir Zgonik on 09.02.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "LDLocationService.h"
#import "LDLocationDefines.h"
#import "gps.h"

@interface LDLocationService ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocationManager *regionLocationManager;
@property (strong, nonatomic) LDGeocoderManager *geocoderManager;
@property (copy, nonatomic) SenderBlock onSuccess; // On success block.
@property (copy, nonatomic) SenderBlock onError; // On failure block.
@property (strong, nonatomic) NSMutableArray *delegates;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *locationDate;
@property (assign, nonatomic) LDLocationAccuracy desiredAccuracy;
@property (assign, nonatomic) LDLocationStatus locationStatusService;
@property (assign, nonatomic) BOOL isFetchLocationOnce;
@property (assign, nonatomic) BOOL isUpdatingUserLocation;
@property (assign, nonatomic) KalmanFilter kalmanFilter;
@property (strong, nonatomic) NSDate *lastPointDate;

// Used one-off for authorization requests
@property (strong, nonatomic) NSMutableArray *userAuthorizationRequests;
@property (strong, nonatomic) NSMutableArray *regionAuthorizationRequests;

// Location Blocks
@property (copy) LDLocationServiceLocationUpdateBlock locationBlock;
@property (copy) LDLocationServiceLocationUpdateFailBlock errorLocationBlock;

// Region Blocks
@property (copy) LDLocationServiceRegionUpdateBlock regionBlock;
@property (copy) LDLocationServiceRegionUpdateFailBlock errorRegionBlock;

// Used for continuous updates of authorization requests
@property (copy) LDLocationServiceAuthorizationStatusChangeBlock userAuthorizationStatusChangeBlock;
@property (copy) LDLocationServiceAuthorizationStatusChangeBlock regionAuthorizationStatusChangeBlock;

@end

@implementation LDLocationService

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self = [self initWithUpdatingInterval:kDefaultLocationTimeIntervalUpdateOneMinute andDesiredAccuracy:kLDHorizontalAccuracyThresholdBlock];
    }
    return self;
}

- (instancetype)initWithUpdatingInterval:(NSTimeInterval)interval andDesiredAccuracy:(CLLocationAccuracy)horizontalAccuracy {
    self = [super init];
    if (self) {
        self.kalmanFilter = alloc_filter_velocity2d(10.f);
        self.locationUpdateInterval = interval;
        self.desiredAccuracy = horizontalAccuracy;
        self.isFetchLocationOnce = NO;
        self.isUpdatingUserLocation = NO;
        self.locationManager.delegate = self;
        self.regionLocationManager.delegate = self;
        if ([[self class] locationServicesEnabled]) {
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self requestRegionLocationWhenInUse];
            }
        }
    }
    return self;
}


+ (BOOL)locationServicesAvaliable {
    if ([CLLocationManager locationServicesEnabled] == NO) {
        return NO;
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        return NO;
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        return NO;
    }
    return YES;
}

+ (BOOL)locationServicesEnabled {
    return [CLLocationManager locationServicesEnabled];
}

+ (BOOL)regionMonitoringAvailable:(Class)regionClass {
    return [CLLocationManager isMonitoringAvailableForClass:regionClass];
}

+ (BOOL)significantLocationChangeMonitoringAvailable {
    return [CLLocationManager significantLocationChangeMonitoringAvailable];
}

#pragma mark - Manage Update Location

- (void)startUpdatingLocation {
    _isUpdatingUserLocation = YES;
    
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation {
    _isUpdatingUserLocation = NO;
    if (_locationManager) {
        [self.locationManager stopUpdatingLocation];
    }
}
 
- (void)currentPosition:(LDLocationServiceLocationUpdateBlock)onSucess onError:(LDLocationServiceLocationUpdateFailBlock)onError {
    _isFetchLocationOnce = YES;
    [self startTimeoutTimer];
    [self startUpdatingLocationWithBlock:onSucess errorBlock:onError];
}

- (void)startUpdatingLocationWithBlock:(LDLocationServiceLocationUpdateBlock)block errorBlock:(LDLocationServiceLocationUpdateFailBlock)errorBlock {
    self.locationBlock = block;
    self.errorLocationBlock = errorBlock;
    [self startUpdatingLocation];
}

- (void)updateUserLocation {
    if (!_isFetchLocationOnce) {
        _isFetchLocationOnce = YES;
        [self startUpdatingLocation];
    }
}

- (void)resetBlocks {
    self.onSuccess = nil;
    self.onError = nil;
    self.locationBlock = nil;
    self.errorLocationBlock = nil;
    self.regionBlock = nil;
    self.errorRegionBlock = nil;
}

#pragma mark - Timer

- (void)startTimeoutTimer {
    [self endTimeoutTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.locationUpdateInterval target:self selector:@selector(updateLocation:) userInfo:nil repeats:YES];
}

- (void)updateLocation:(NSTimer *)timer {
    [self stopUpdatingLocation];
    [self endTimeoutTimer];
    if (self.locationBlock != nil) {
        self.locationBlock(self.locationManager, _location, nil);
    }
    for (id <LDLocationServiceDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(didUpdateUserLocation:)]) {
            [delegate didUpdateUserLocation:self.location];
        }
    }
}

- (void)endTimeoutTimer {
    if (_timer) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        _timer = nil;
    }
}

#pragma mark - Setter

- (void)setLocationUpdateInterval:(NSTimeInterval)locationUpdateInterval {
    _locationUpdateInterval = locationUpdateInterval;
}

- (void)setGeocoderProvider:(LDGeocodeBaseProvider *)provider {
    [self setGeocoderProvider: provider withApiKey: nil andISOLanguageAndRegionCode:nil];
};

- (void)setGeocoderProvider:(LDGeocodeBaseProvider *)provider withApiKey:(NSString *)key andISOLanguageAndRegionCode:(NSString *)lanRegCode {
  
    _geocoderManager =  [[LDGeocoderManager alloc] initWithGeocodeProvider: provider];
    
    [_geocoderManager setGeocodeServiceApiKey:key languageRegionIso:lanRegCode andRezultCount:1 andRegionNamePrefix:@""];
};

#pragma mark - Getters

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
    }
    if ([_locationManager respondsToSelector:@selector(pausesLocationUpdatesAutomatically)]) {
        _locationManager.pausesLocationUpdatesAutomatically = NO;
    }
    return _locationManager;
}

- (LDGeocoderManager *)geocoderManager {
    if(!_geocoderManager) {
        _geocoderManager = [[LDGeocoderManager alloc] init];
    }
    
    return _geocoderManager;
}

- (NSMutableArray *)delegates {
    if (!_delegates) {
        _delegates = [NSMutableArray array];
    }
    return _delegates;
}

- (NSMutableArray *)regionAuthorizationRequests {
    if (!_regionAuthorizationRequests) {
        _regionAuthorizationRequests = [NSMutableArray array];
    }
    return _regionAuthorizationRequests;
}

- (NSMutableArray *)userAuthorizationRequests {
    if (!_userAuthorizationRequests) {
        _userAuthorizationRequests = [NSMutableArray array];
    }
    return _userAuthorizationRequests;
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self locationDidUpdateToNewLocation:newLocation fromOldLocation:oldLocation withManager:manager];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *previousLocation = nil;
    if (locations.count > 1) {
        previousLocation = [locations objectAtIndex:locations.count - 2];
    }
    [self locationDidUpdateToNewLocation:[locations lastObject] fromOldLocation:previousLocation withManager:manager];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorized || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self startUpdatingLocation];
    } else {
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
    }
    if (manager == _regionLocationManager) {
        for (id <LDLocationServiceDelegate> delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(didChangeRegionAuthorizationStatus:)]) {
                [delegate didChangeRegionAuthorizationStatus:status];
            }
        }
        if (_regionAuthorizationStatusChangeBlock != nil) {
            _regionAuthorizationStatusChangeBlock(manager, status);
        }
        for (LDLocationServiceAuthorizationStatusChangeBlock block in [_regionAuthorizationRequests copy]) {
            block(manager, status);
        }
    } else if (manager == _locationManager) {
        for (id <LDLocationServiceDelegate> delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(didChangeRegionAuthorizationStatus:)]) {
                [delegate didChangeRegionAuthorizationStatus:status];
            }
        }
        if (_userAuthorizationStatusChangeBlock != nil) {
            _userAuthorizationStatusChangeBlock(manager, status);
        }
        for (LDLocationServiceAuthorizationStatusChangeBlock block in [_userAuthorizationRequests copy]) {
            block(manager, status);
        }
    }
}

- (void)locationDidUpdateToNewLocation:(CLLocation *)newLocation fromOldLocation:(CLLocation *)oldLocation withManager:(CLLocationManager *)manager  {
    self.locationObtained = YES;
    CLLocation *correctedLocation = [self correctLocationForLocation:newLocation];
    self.location = correctedLocation;
    // Call location block
    if (self.locationBlock != nil) {
        self.locationBlock(manager, correctedLocation, oldLocation);
    }
    if (correctedLocation.horizontalAccuracy <= manager.desiredAccuracy || _isFetchLocationOnce == NO) {
        if (_isFetchLocationOnce) {
            // Stop querying timer because accurate location was obtained
            [self endTimeoutTimer];
            [_locationManager stopUpdatingLocation];
            self.locationBlock = nil;
            _isFetchLocationOnce = NO;
        }
    }
    for (id <LDLocationServiceDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(didUpdateUserLocation:)]) {
            [delegate didUpdateUserLocation:correctedLocation];
        }
    }
    self.lastPointDate = [NSDate new];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self.locationManager stopUpdatingLocation];
    // Call location block
    if (self.errorLocationBlock != nil) {
        self.errorLocationBlock(manager, error);
        self.errorLocationBlock = nil;
    }
    for (id <LDLocationServiceDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(didFailWithError:)]) {
            [delegate didFailWithError:error];
        }
    }
}

#pragma mark - Location Authorization Request Status and Continuous Update

- (void)requestUserLocationWhenInUse {
    CLAuthorizationStatus const status = [CLLocationManager authorizationStatus];
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self checkBundleInfoFor:kNSLocationWhenInUseUsageDescription];
        if (status == kCLAuthorizationStatusNotDetermined) {
            [_locationManager requestWhenInUseAuthorization];
        } else {
            for (id <LDLocationServiceDelegate> delegate in self.delegates) {
                if ([delegate respondsToSelector:@selector(didChangeRegionAuthorizationStatus:)]) {
                    [delegate didChangeRegionAuthorizationStatus:status];
                }
            }
        }
    } else {
        for (id <LDLocationServiceDelegate> delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(didChangeRegionAuthorizationStatus:)]) {
                [delegate didChangeRegionAuthorizationStatus:status];
            }
        }
    }
}

- (void)requestUserLocationAlways {
    CLAuthorizationStatus const status = [CLLocationManager authorizationStatus];
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self checkBundleInfoFor:kNSLocationAlwaysUsageDescription];
        if (status == kCLAuthorizationStatusNotDetermined) {
            [_locationManager requestAlwaysAuthorization];
        } else {
            for (id <LDLocationServiceDelegate> delegate in self.delegates) {
                if ([delegate respondsToSelector:@selector(didChangeRegionAuthorizationStatus:)]) {
                    [delegate didChangeRegionAuthorizationStatus:status];
                }
            }
        }
    } else {
        for (id <LDLocationServiceDelegate> delegate in self.delegates) {
            if ([delegate respondsToSelector:@selector(didChangeRegionAuthorizationStatus:)]) {
                [delegate didChangeRegionAuthorizationStatus:status];
            }
        }
    }
}

- (void)requestUserLocationWhenInUseWithBlock:(LDLocationServiceAuthorizationStatusChangeBlock)block {
    self.userAuthorizationStatusChangeBlock = block;
    [self requestUserLocationWhenInUse];
}

- (void)requestUserLocationAlways:(LDLocationServiceAuthorizationStatusChangeBlock)block {
    self.userAuthorizationStatusChangeBlock = block;
    [self requestUserLocationAlways];
}

- (void)requestUserLocationWhenInUseWithBlockOnce:(LDLocationServiceAuthorizationStatusChangeBlock)block {
    [_userAuthorizationRequests addObject:[block copy]];
    [self requestUserLocationWhenInUse];
}

- (void)requestUserLocationAlwaysOnce:(LDLocationServiceAuthorizationStatusChangeBlock)block {
    [_userAuthorizationRequests addObject:[block copy]];
    [self requestUserLocationAlways];
}



- (void)requestRegionLocationWhenInUse {
    CLAuthorizationStatus const status = [CLLocationManager authorizationStatus];
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self checkBundleInfoFor:kNSLocationWhenInUseUsageDescription];
        if (status == kCLAuthorizationStatusNotDetermined) {
            [_locationManager requestWhenInUseAuthorization];
        } else {
            [self locationManager:_locationManager didChangeAuthorizationStatus:status];
        }
    } else {
        [self locationManager:_regionLocationManager didChangeAuthorizationStatus:status];
    }
    
}

- (void)requestRegionLocationAlways {
    CLAuthorizationStatus const status = [CLLocationManager authorizationStatus];
    if ([_regionLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self checkBundleInfoFor:kNSLocationAlwaysUsageDescription];
        if (status == kCLAuthorizationStatusNotDetermined) {
            [_regionLocationManager requestAlwaysAuthorization];
        } else {
            [self locationManager:_regionLocationManager didChangeAuthorizationStatus:status];
        }
    } else {
        [self locationManager:_regionLocationManager didChangeAuthorizationStatus:status];
    }
}

- (void)requestRegionLocationWhenInUseWithBlock:(LDLocationServiceAuthorizationStatusChangeBlock)block {
    self.regionAuthorizationStatusChangeBlock = block;
    [self requestRegionLocationWhenInUse];
}

- (void)requestRegionLocationAlwaysWithBlock:(LDLocationServiceAuthorizationStatusChangeBlock)block {
    self.regionAuthorizationStatusChangeBlock = block;
    [self requestRegionLocationAlways];
}

- (void)requestRegionLocationWhenInUseWithBlockOnce:(LDLocationServiceAuthorizationStatusChangeBlock)block {
    [_regionAuthorizationRequests addObject:[block copy]];
    [self requestRegionLocationWhenInUse];
}

- (void)requestRegionLocationAlwaysWithBlockOnce:(LDLocationServiceAuthorizationStatusChangeBlock)block {
    [_regionAuthorizationRequests addObject:[block copy]];
    [self requestRegionLocationAlways];
}

- (void)requestGeocodeForLocation:(CLLocation *)location success:(GeoSuccesBlock)completionHandler andFail:(FailBlock)failHandler {
    
    [self.geocoderManager requestGeocodeForLocation:location success:completionHandler andFail:failHandler];
};

- (void)requestLocationForAddress:(NSString *)address success:(LocSuccesBlock)completionHandler andFail:(FailBlock)failHandler {
    
    [self.geocoderManager requestLocationForAddress:address success:completionHandler andFail:failHandler];
};

#pragma mark - LDLocationSeviceDelegates

- (void)addDelegate:(id<LDLocationServiceDelegate>)delegate {
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}

- (void)removeDelegate:(id<LDLocationServiceDelegate>)delegate {
    if ([self.delegates containsObject:delegate]) {
        [self.delegates removeObject:delegate];
    }
}

#pragma mark -

// Returns the associated recency threshold (in seconds) for the location request's desired accuracy level.
- (NSTimeInterval)updateTimeStaleThreshold {
    switch (self.desiredAccuracy) {
        case LDLocationAccuracyRoom:
            return kLDUpdateTimeIntervalThresholdRoom;
            break;
        case LDLocationAccuracyHouse:
            return kLDUpdateTimeIntervalThresholdHouse;
            break;
        case LDLocationAccuracyBlock:
            return kLDUpdateTimeIntervalThresholdBlock;
            break;
        case LDLocationAccuracyNeighborhood:
            return kLDUpdateTimeIntervalThresholdNeighborhood;
            break;
        case LDLocationAccuracyCity:
            return kLDUpdateTimeIntervalThresholdCity;
            break;
        default:
            NSAssert(NO, @"Unknown desired accuracy.");
            return 0.0;
            break;
    }
}

// Returns the associated horizontal accuracy threshold (in meters) for the location request's desired accuracy level.
- (CLLocationAccuracy)horizontalAccuracyThreshold {
    switch (self.desiredAccuracy) {
        case LDLocationAccuracyRoom:
            return kLDHorizontalAccuracyThresholdRoom;
            break;
        case LDLocationAccuracyHouse:
            return kLDHorizontalAccuracyThresholdHouse;
            break;
        case LDLocationAccuracyBlock:
            return kLDHorizontalAccuracyThresholdBlock;
            break;
        case LDLocationAccuracyNeighborhood:
            return kLDHorizontalAccuracyThresholdNeighborhood;
            break;
        case LDLocationAccuracyCity:
            return kLDHorizontalAccuracyThresholdCity;
            break;
        default:
            NSAssert(NO, @"Unknown desired accuracy.");
            return 0.0;
            break;
    }
}

-(void)checkBundleInfoFor:(NSString*)key {
    NSDictionary *const infoPlist = [[NSBundle mainBundle] infoDictionary];
    if (![infoPlist objectForKey:key]) {
        NSLog(kAlertAuthorizationMsg, key, key);
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:[NSString stringWithFormat:kAlertAuthorizationMsg, key, key] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)dealloc {
    [self endTimeoutTimer];
}

- (CLLocation *)correctLocationForLocation:(CLLocation *)location {
    double secondsFromLastUpdate = self.lastPointDate ? fabs([self.lastPointDate timeIntervalSinceNow]) : 0.01f;
    update_velocity2d(self.kalmanFilter, location.coordinate.latitude, location.coordinate.longitude, secondsFromLastUpdate);
    double correctedLatitude, correctedLongitude;
    get_lat_long(self.kalmanFilter, &correctedLatitude, &correctedLongitude);
    return [[CLLocation alloc] initWithLatitude:correctedLatitude longitude:correctedLongitude];
}

@end
