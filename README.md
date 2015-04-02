# AGLocationDispatcher

Dispatcher provides easy-to-use access to iOS device location/background location/tracking/etc. It wraps CoreLocation with convenient well customized interface. Dispatcher's classes for tracking current user location, direct and reverse geocoding , tracking enter/exit region, logging user route and speed.

[![CI Status](http://img.shields.io/travis/agilie/AGLocationDispatcher.svg?style=flat)](https://travis-ci.org/agilie/AGLocationDispatcher)
[![Version](https://img.shields.io/cocoapods/v/AGLocationDispatcher.svg?style=flat)](http://cocoadocs.org/docsets/AGLocationDispatcher)
[![License](https://img.shields.io/cocoapods/l/AGLocationDispatcher.svg?style=flat)](http://cocoadocs.org/docsets/AGLocationDispatcher)
[![Platform](https://img.shields.io/cocoapods/p/AGLocationDispatcher.svg?style=flat)](http://cocoadocs.org/docsets/AGLocationDispatcher)

[![AGLocationManager demo video](http://img.youtube.com/vi/LbmLdLJagbM/0.jpg)](http://www.youtube.com/watch?v=LbmLdLJagbM)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Add required .plist entries

By reason of iOS 8 you are required to define a message that will be presented to the user on location authorization request. You should define this message into your app's *-Info.plist file. 
Add at least one of the following keys, depending on which location update mode you request:

NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription

Make sure you added this key in the right .plist file (common mistake is entering it into test-Info.plist) and appropriate message text as a value.

## Tracking user location

To start tracking location, initialize AGLocationDispatcher or AGRouteDispatcher with default init for standart setup  
(default updating interval - 1 min, horizontal accuracy - 100 meters)

also you can customize service with following initializer -

initWithUpdatingInterval: andDesiredAccuracy:

Example:

```obj-c
AGRouteDispatcher *routeDisptcher = [AGRouteDispatcher initWithUpdatingInterval:kDefaultLocationTimeIntervalUpdateOneMinute andDesiredAccuracy:kAGHorizontalAccuracyThresholdBlock]
```

At viewcontroller's module, you can use this methods with blocks:

```obj-c
- (void)startUpdatingLocationWithBlock: errorBlock:
- (void)startUpdatingLocationAndSpeedWithBlock: errorBlock:
- (void)requestUserLocationWhenInUseWithBlock:
- (void)requestUserLocationAlwaysWithBlock:
- (void)currentLocationWithBlock: errorBlock:
```

inits and getters:

```obj-c
+ (BOOL)locationServicesEnabled;
+ (BOOL)significantLocationChangeMonitoringAvailable;

- (instancetype)init;
- (instancetype)initWithUpdatingInterval:(NSTimeInterval)interval andDesiredAccuracy:(CLLocationAccuracy)horizontalAccuracy;
- (CLLocationManager *)locationManager;
- (CLLocationAccuracy)horizontalAccuracyThreshold;
```

## Background Tracking user location

AGLocationDispatcher allows several methods of background location, depends of application info plist configuratons and locationUpdateBackgroundMode setting (default is AGLocationBackgroundModeSignificantLocationChanges mode)
When application is suspended or terminated you need use spectial background location wrapper: AGBackgroundLocationDispatcher  (see example AppDelegate methods)

Background location modes:

- No background location mode: When app go to backgroud location updated will stop. After app did become active location updating will be activated again.
Set locationUpdateBackgroundMode property (AGLocationDispatcher object) to AGLocationBackgroundModeForegroundOnly state;

- Always actiwe: required UIBackgroundModes "location" key, application never suspend, location accuracy and battery rate will be maximum, no need additional code.
Set locationUpdateBackgroundMode property (AGLocationDispatcher object) to any state except AGLocationBackgroundModeForegroundOnly;

- Significant location mode: Work when app is terminated/suspended, provide GPS-level accuracy (over 500 metters positon change) and very low-energy location updating. Required UIBackgroundModes "location" key and implementin special handler(based on AGBackgroundLocationDispatcher wrapper) in app delegate code (see example appDelegate method didFinishLaunchingWithOptions). 
Set locationUpdateBackgroundMode property (AGLocationDispatcher object) to AGLocationBackgroundModeSignificantLocationChanges state;

- Fetch based location mode: Work when app is suspended, provide normall accuracy and very middle-energy location updating, but activated when device is unblock/activate. Required UIBackgroundModes "fetch" key and implementin special handler(based on AGBackgroundLocationDispatcher wrapper) in app delegate code (see example appDelegate method performFetchWithCompletionHandler). 
Set locationUpdateBackgroundMode property (AGLocationDispatcher object) to AGLocationBackgroundModeFetch state;

AGBackgroundLocationDispatcher code runs when app is NOT active, you default apps object amd UI will NOT exist. AGBackgroundLocationDispatcher code must store location locally (in file, coredata etc), send it to server side or create UILocalNotification (for start the app in normal mode).  AGBackgroundLocationDispatcher code will be terminated by system after 10s~30s after active running.

AGBackgroundLocationDispatcher wrapper provide init method with block for you background code and callback block, you need call that block when you location task will complete. 

Example AGBackgroundLocationDispatcher code:

```obj-c
[[AGBackgroundLocationDispatcher alloc] initWithASynchronousLocationUpdateBlock:^(AGLocation *newLocation, LDSignificationLocationASynchronousEndUpdateBlock updateCompletionBlock) {

    NSString *string = [NSString stringWithFormat:@"example.com?location=%@",  [newLocation description] ];
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest: request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        updateCompletionBlock(); //data send successfully

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        updateCompletionBlock(); //data dont send 

    }];

    [operation start];

}];
```

## Use geocoding

Use AGGeoDispatcher class for direct and reverse geocoding.

Just initialize AGGeoDispatcher class

```obj-c
AGGeoDispatcher *geoDispatcher = [[AGGeoDispatcher alloc] init]
```

implement following methods:

```obj-c
- (void)requestGeocodeForLocation: success: andFail:
- (void)requestLocationForAddress: success: andFail:
```

To choose geocode provider (Apple, Google, Yandex) use following method:

```obj-c
- (void)setGeocoderProvider:
```

## Manage your route

AGRouteDispatcher class provide save/load AGRoute data in local storage with methods:

```obj-c
- (AGRoute *)loadRouteWithName:
- (void)saveRoute: name:
- (void)deleteDocWithName:
```

## Regions Dispatcher

AGRegionDispatcher class used for monitoring enter/exit some region. Use this block methods for monitoring:

```obj-c
- (void)addCoordinateForMonitoring: updateBlock: failBlock:
- (void)addCoordinateForMonitoring: withRadius: desiredAccuracy: updateBlock: failBlock:
- (void)addRegionForMonitoring: desiredAccuracy: updateBlock: failBlock:
- (void)stopMonitoringForRegion:
- (void)stopMonitoringAllRegions
```

## Requirements

## Installation

AGLocationDispatcher is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "AGLocationDispatcher"

## Author

Agilie info@agilie.com

## License

AGLocationDispatcher is available under the MIT license. See the LICENSE file for more info.

