//
//  AGDispatcherDefines.h
//  LocationDispatch
//
//  Created by Vladimir Zgonik on 09.02.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#ifndef LocationDispatch_AGDispatcherDefines_h
#define LocationDispatch_AGDispatcherDefines_h

static NSString *const kAlertAuthorizationMsg = @"Warning! Unable to find %@ in Info.plist.  \
CLLocationManager requires that %@ be set in \
the Info.plist in order to function correctly.  \
Please consult the Apple Developer documentation titled \
\"Information Property List Key Reference.\"";

static NSString *const kNSLocationWhenInUseUsageDescription = @"NSLocationWhenInUseUsageDescription";
static NSString *const kNSLocationAlwaysUsageDescription = @"NSLocationAlwaysUsageDescription";
static NSString *const AGLocationServiceUserLocationDidChangeNotification = @"LocationManagerUserLocationDidChangeNotification";
static NSString *const AGLocationServiceNotificationLocationUserInfoKey = @"newLocation";

static NSTimeInterval const kAGLocationUpdateIntervalOneSec = 1.f; // in seconds
static NSTimeInterval const kAGLocationUpdateIntervalTenSec = 10.f; // in seconds
static NSTimeInterval const kAGLocationUpdateIntervalOneMinute = 60.f; // in seconds
static NSTimeInterval const kAGLocationUpdateInterval15Minutes = 15.f * 60.f; // in seconds
static NSTimeInterval const kAGLocationUpdateInterval60Minutes = 60.f * 60.f; // in seconds

static CGFloat const kAGHorizontalAccuracyCity = 5000.f;  // in meters
static CGFloat const kAGHorizontalAccuracyNeighborhood = 1000.f;  // in meters
static CGFloat const kAGHorizontalAccuracyBlock = 100.f;  // in meters
static CGFloat const kAGHorizontalAccuracyHouse = 15.f;  // in meters
static CGFloat const kAGHorizontalAccuracyRoom = 5.f;  // in meters

static NSTimeInterval const kAGUpdateIntervalCity = 600.f;  // in seconds
static NSTimeInterval const kAGUpdateIntervalNeighborhood = 300.f;  // in seconds
static NSTimeInterval const kAGUpdateIntervalBlock = 60.f;  // in seconds
static NSTimeInterval const kAGUpdateIntervalHouse = 15.f;  // in seconds
static NSTimeInterval const kAGUpdateIntervalRoom = 5.f;  // in seconds

typedef NS_ENUM (NSInteger, AGLocationUpdateInterval) {
    AGLocationUpdateIntervalOneSec,
    AGLocationUpdateIntervalTenSec,
    AGLocationUpdateIntervalOneMinute,
    AGLocationUpdateInterval15Minutes,
    AGLocationUpdateInterval60Minutes
};

typedef enum {
    // 'None' is not valid as a desired accuracy.
    /** Inaccurate (>5000 meters, and/or received >10 minutes ago). */
            AGLocationAccuracyNone = 0,
    // The below options are valid desired accuracies.
    /** 5000 meters or better, and received within the last 10 minutes. Lowest accuracy. */
            AGLocationAccuracyCity,
    /** 1000 meters or better, and received within the last 5 minutes. */
            AGLocationAccuracyNeighborhood,
    /** 100 meters or better, and received within the last 1 minute. */
            AGLocationAccuracyBlock,
    /** 15 meters or better, and received within the last 15 seconds. */
            AGLocationAccuracyHouse,
    /** 5 meters or better, and received within the last 5 seconds. Highest accuracy. */
            AGLocationAccuracyRoom
} AGLocationAccuracy;

typedef enum {
    // These statuses will accompany a valid location.
    /** Got a location and desired accuracy level was achieved successfully. */
            AGLocationStatusSuccess = 0,
    /** Got a location, but the desired accuracy level was not reached before timeout. (Not applicable to subscriptions.) */
            AGLocationStatusTimedOut,
    // These statuses indicate some sort of error, and will accompany a nil location.
    /** User has not responded to the permissions dialog. */
            AGLocationStatusServicesNotDetermined,
    /** User has explicitly denied this app permission to access location services. */
            AGLocationStatusServicesDenied,
    /** User does not have ability to enable location services (e.g. parental controls, corporate policy, etc). */
            AGLocationStatusServicesRestricted,
    /** User has turned off device-wide location services from system settings. */
            AGLocationStatusServicesDisabled,
    /** An error occurred while using the system location services. */
            AGLocationStatusError
} AGLocationStatus;

typedef enum {
    // These statuses will accompany a valid location.
    /** Always active location, 10 min. in background OR always active  (Need key in plist file.) */
    AGLocationBackgroundModeDefault = 0,
    /** Stop location on background */
    AGLocationBackgroundModeForegroundOnly,
    /** Active location on foreground and attemp to start SignificantLocation on backround need (Need key in plist file AND AppDelegate modification) */
    AGLocationBackgroundModeSignificantLocationChanges,
    /** Not implemented! */
    AGLocationBackgroundModeFetch
    
} AGLocationBackgroundMode;

#endif
