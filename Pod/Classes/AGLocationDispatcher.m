//
//  AGLocationDispatch.m
//  LocationDispatch
//
//  Created by Vladimir Zgonik on 09.02.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "AGLocationDispatcher.h"
#import "gps.h"

@interface AGLocationDispatcher ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *locationDate;
@property (assign, nonatomic) AGLocationAccuracy desiredAccuracy;
@property (assign, nonatomic) AGLocationStatus locationStatusService;
@property (assign, nonatomic) BOOL isFetchLocationOnce;
@property (assign, nonatomic) BOOL isUpdatingUserLocation;
@property (assign, nonatomic) KalmanFilter kalmanFilter;
@property (strong, nonatomic) NSDate *lastPointDate;

@property (assign, nonatomic) BOOL needRestartLocationAfterForegroud;

// Used one-off for authorization requests
@property (strong, nonatomic) NSMutableArray *userAuthorizationRequests;

// Location Blocks
@property (copy) AGLocationServiceLocationUpdateBlock locationBlock;
@property (copy) AGLocationServiceLocationAndSpeedUpdateBlock locationAndSpeedBlock;
@property (copy) AGLocationServiceLocationUpdateFailBlock errorLocationBlock;

@end

@implementation AGLocationDispatcher

#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        self = [self initWithUpdatingInterval:kAGLocationUpdateIntervalOneMinute andDesiredAccuracy:kAGHorizontalAccuracyBlock];
        
        self.locationUpdateBackgroundMode = AGLocationBackgroundModeSignificantLocationChanges;
        
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(locationDispatchDidChangeAppBackgroundMode:)
                                                     name: UIApplicationDidEnterBackgroundNotification
                                                   object: nil ];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(locationDispatchDidChangeAppBackgroundMode:)
                                                     name: UIApplicationDidBecomeActiveNotification
                                                   object: nil ];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(locationDispatchDidChangeAppBackgroundMode:)
                                                     name: UIApplicationWillTerminateNotification
                                                   object: nil ];

        
        self.needRestartLocationAfterForegroud = NO;
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
        if ([[self class] locationServicesEnabled]) {
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self requestUserLocationWhenInUse];
            }
        }
        
    }
    return self;
}

+ (BOOL)locationServicesEnabled {
    return [CLLocationManager locationServicesEnabled];
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

- (void)locationDispatchDidChangeAppBackgroundMode:(NSNotification *) notification{
    
    BOOL currentAppIsActive =  [[UIApplication sharedApplication] applicationState] ? UIApplicationStateActive : YES;
    
    // self.locationUpdateBackgroundMode == LDLocationBackgroundModeDefault
    // dont need add any additional behavior
    
    BOOL applicationWillBeTerminate = NO;
    
    if([notification.name isEqualToString: UIApplicationWillTerminateNotification]){
        applicationWillBeTerminate = YES;
    }
    
    if(self.locationUpdateBackgroundMode == AGLocationBackgroundModeForegroundOnly){
        if(currentAppIsActive){
            if( self.needRestartLocationAfterForegroud ){
                [self startUpdatingLocation];
            }
        } else {
            if(_isUpdatingUserLocation){
                self.needRestartLocationAfterForegroud = YES;
                [self stopUpdatingLocation];
            }
        }
    }
    
    if(self.locationUpdateBackgroundMode == AGLocationBackgroundModeSignificantLocationChanges){

        if (applicationWillBeTerminate) {
            NSLog(@"UpdatingLocationMode to Background Significant %i", [CLLocationManager significantLocationChangeMonitoringAvailable ]);
            
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                [self.locationManager requestAlwaysAuthorization];
            }
            
            [self.locationManager stopUpdatingLocation];
            [self.locationManager startMonitoringSignificantLocationChanges];
            
        }
        
        
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    }
    
    if(self.locationUpdateBackgroundMode == AGLocationBackgroundModeFetch){
      
        if(currentAppIsActive==NO && _isUpdatingUserLocation==YES){
            [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
        }
        
        if(currentAppIsActive==YES){
            [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
        }
    }
       
    
    
}


- (BOOL) checkIOS8BackgroundModeTask {
    
    //We have to make sure that the Background app Refresh is enabled for the Location updates to work in the background.
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied)
    {
        // The user explicitly disabled the background services for this app or for the whole system.
        NSLog(@"The app doesn't work without the Background app Refresh enabled. To turn it on, go to Settings > General > Background app Refresh");
        return NO;
    }
    else if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted)
    {
        // Background services are disabled and the user cannot turn them on.
        // May occur when the device is restricted under parental control.
        NSLog(@"The functions of this app are limited because the Background app Refresh is disable.");
        return NO;
    }
    
    NSLog(@"App work with Background app Refresh enabled.");
    return YES;
}



- (void)currentLocationWithBlock:(AGLocationServiceLocationUpdateBlock)block errorBlock:(AGLocationServiceLocationUpdateFailBlock)errorBlock {
    _isFetchLocationOnce = YES;
    [self startTimeoutTimer];
    [self startUpdatingLocationWithBlock:block errorBlock:errorBlock];
}

- (void)startUpdatingLocationWithBlock:(AGLocationServiceLocationUpdateBlock)block errorBlock:(AGLocationServiceLocationUpdateFailBlock)errorBlock {
    self.locationBlock = block;
    self.errorLocationBlock = errorBlock;
    [self startUpdatingLocation];
}

- (void)startUpdatingLocationAndSpeedWithBlock:(AGLocationServiceLocationAndSpeedUpdateBlock)block errorBlock:(AGLocationServiceLocationUpdateFailBlock)errorBlock {
    self.locationAndSpeedBlock = block;
    self.errorLocationBlock = errorBlock;
    [self startUpdatingLocation];
}

- (void)resetBlocks {
    self.locationBlock = nil;
    self.errorLocationBlock = nil;
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
    if (self.locationAndSpeedBlock != nil) {
        self.locationAndSpeedBlock(self.locationManager, _location, nil, [self getSpeed]);
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
    
    if (_userAuthorizationStatusChangeBlock != nil) {
        _userAuthorizationStatusChangeBlock(manager, status);
    }
    for (AGLocationServiceAuthorizationStatusChangeBlock block in [_userAuthorizationRequests copy]) {
        block(manager, status);
    }
}

- (void)locationDidUpdateToNewLocation:(CLLocation *)newLocation fromOldLocation:(CLLocation *)oldLocation withManager:(CLLocationManager *)manager {
    self.locationObtained = YES;
    AGLocation *correctedLocation = [self correctLocationForLocation:newLocation];
    self.location = correctedLocation;
    // Call location block
    if (self.locationBlock != nil) {
        self.locationBlock(manager, correctedLocation, (AGLocation *)oldLocation);
    }
    if (self.locationAndSpeedBlock != nil) {
        self.locationAndSpeedBlock(manager, correctedLocation, (AGLocation *)oldLocation, [self getSpeed]);
    }
    if (correctedLocation.horizontalAccuracy <= manager.desiredAccuracy || _isFetchLocationOnce == NO) {
        if (_isFetchLocationOnce) {
            // Stop querying timer because accurate location was obtained
            [self endTimeoutTimer];
            [_locationManager stopUpdatingLocation];
            self.locationBlock = nil;
            self.locationAndSpeedBlock = nil;
            _isFetchLocationOnce = NO;
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
}

#pragma mark - Location Authorization Request Status and Continuous Update

- (void)requestUserLocationWhenInUse {
    CLAuthorizationStatus const status = [CLLocationManager authorizationStatus];
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self checkBundleInfoFor:kNSLocationWhenInUseUsageDescription];
        if (status == kCLAuthorizationStatusNotDetermined) {
            [_locationManager requestWhenInUseAuthorization];
        }
    }
}

- (void)requestUserLocationAlways {
    CLAuthorizationStatus const status = [CLLocationManager authorizationStatus];
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self checkBundleInfoFor:kNSLocationAlwaysUsageDescription];
        if (status == kCLAuthorizationStatusNotDetermined) {
            [_locationManager requestAlwaysAuthorization];
        }
    }
}

- (void)requestUserLocationWhenInUseWithBlock:(AGLocationServiceAuthorizationStatusChangeBlock)block {
    self.userAuthorizationStatusChangeBlock = block;
    [self requestUserLocationWhenInUse];
}

- (void)requestUserLocationAlwaysWithBlock:(AGLocationServiceAuthorizationStatusChangeBlock)block {
    self.userAuthorizationStatusChangeBlock = block;
    [self requestUserLocationAlways];
}

- (void)requestUserLocationWhenInUseWithBlockOnce:(AGLocationServiceAuthorizationStatusChangeBlock)block {
    [_userAuthorizationRequests addObject:[block copy]];
    [self requestUserLocationWhenInUse];
}

- (void)requestUserLocationAlwaysOnce:(AGLocationServiceAuthorizationStatusChangeBlock)block {
    [_userAuthorizationRequests addObject:[block copy]];
    [self requestUserLocationAlways];
}

#pragma mark -

// Returns the associated recency threshold (in seconds) for the location request's desired accuracy level.
- (NSTimeInterval)updateTimeStaleThreshold {
    switch (self.desiredAccuracy) {
        case AGLocationAccuracyRoom:
            return kAGUpdateIntervalRoom;
            break;
        case AGLocationAccuracyHouse:
            return kAGUpdateIntervalHouse;
            break;
        case AGLocationAccuracyBlock:
            return kAGUpdateIntervalBlock;
            break;
        case AGLocationAccuracyNeighborhood:
            return kAGUpdateIntervalNeighborhood;
            break;
        case AGLocationAccuracyCity:
            return kAGUpdateIntervalCity;
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
        case AGLocationAccuracyRoom:
            return kAGHorizontalAccuracyRoom;
            break;
        case AGLocationAccuracyHouse:
            return kAGHorizontalAccuracyHouse;
            break;
        case AGLocationAccuracyBlock:
            return kAGHorizontalAccuracyBlock;
            break;
        case AGLocationAccuracyNeighborhood:
            return kAGHorizontalAccuracyNeighborhood;
            break;
        case AGLocationAccuracyCity:
            return kAGHorizontalAccuracyCity;
            break;
        default:
            NSAssert(NO, @"Unknown desired accuracy.");
            return 0.0;
            break;
    }
}

- (void)checkBundleInfoFor:(NSString *)key {
    NSDictionary *const infoPlist = [[NSBundle mainBundle] infoDictionary];
    if (![infoPlist objectForKey:key]) {
        NSLog(kAlertAuthorizationMsg, key, key);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:[NSString stringWithFormat:kAlertAuthorizationMsg, key, key] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)dealloc {
    [self endTimeoutTimer];
}

- (AGLocation *)correctLocationForLocation:(CLLocation *)location {
    double secondsFromLastUpdate = self.lastPointDate ? fabs([self.lastPointDate timeIntervalSinceNow]) : 0.01f;
    update_velocity2d(self.kalmanFilter, location.coordinate.latitude, location.coordinate.longitude, secondsFromLastUpdate);
    double correctedLatitude, correctedLongitude;
    get_lat_long(self.kalmanFilter, &correctedLatitude, &correctedLongitude);
    return [[AGLocation alloc] initWithLatitude:correctedLatitude longitude:correctedLongitude];
}

- (NSNumber *)getSpeed {
    return @(get_mph(self.kalmanFilter));
}

@end
