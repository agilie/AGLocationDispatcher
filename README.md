# AGLocationDispatcher

Dispatcher provides easy-to-use access to iOS device location/tracking/etc. It wraps CoreLocation with convenient well customized interface. Dispatcher's classes for tracking current user location, direct and reverse geocoding , tracking enter/exit region, logging user route and speed.

[![CI Status](http://img.shields.io/travis/ideas-world/AGLocationDispatcher.svg?style=flat)](https://travis-ci.org/ideas-world/AGLocationDispatcher)
[![Version](https://img.shields.io/cocoapods/v/AGLocationDispatcher.svg?style=flat)](http://cocoadocs.org/docsets/AGLocationDispatcher)
[![License](https://img.shields.io/cocoapods/l/AGLocationDispatcher.svg?style=flat)](http://cocoadocs.org/docsets/AGLocationDispatcher)
[![Platform](https://img.shields.io/cocoapods/p/AGLocationDispatcher.svg?style=flat)](http://cocoadocs.org/docsets/AGLocationDispatcher)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

# Add required .plist entries
By reason of iOS 8 you are required to define a message that will be presented to the user on location authorization request. You should define this message into your app's *-Info.plist file. 
Add at least one of the following keys, depending on which location update mode you request:

NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription

Make sure you added this key in the right .plist file (common mistake is entering it into test-Info.plist) and appropriate message text as a value.

# Tracking user location

To start tracking location, initialize AGLocationDispatch or AGRouteDispatch with default init for standart setup  
(default updating interval - 1 min, horizontal accuracy - 100 meters)

also you can customize service with following initializer -

initWithUpdatingInterval: andDesiredAccuracy:

Example:

AGRouteDispatch *routeDisptch = [AGRouteDispatch initWithUpdatingInterval:kDefaultLocationTimeIntervalUpdateOneMinute andDesiredAccuracy:kAGHorizontalAccuracyThresholdBlock]

At viewcontroller's module, you can use this methods with blocks:

- (void)startUpdatingLocationWithBlock: errorBlock:
- (void)startUpdatingLocationAndSpeedWithBlock: errorBlock:

or implement this AGLocationServiceDelegate methods:

- (void)didUpdateUserLocation:
- (void)didUpdateUserLocation: speed:
- (void)didChangeUserAuthorizationStatus:
- (void)didFailWithError:

Add your controller's instance to AGLocationDispatch or AGRouteDispatch delegates

[self.routeDispatch addDelegate:self]

run method

[self.routeDispatch startUpdatingLocation]

# Use geocoding

Use AGGeoDispatcher class for direct and reverse geocoding.

Just initialize AGGeoDispatcher class

AGGeoDispatcher *geoDispatch = [[AGGeoDispatcher alloc] init]

implement following methods:

- (void)requestGeocodeForLocation: success: andFail:
- (void)requestLocationForAddress: success: andFail:

To choose geocode provider (Apple, Google, Yandex) use following method:

- (void)setGeocoderProvider:

# Manage your route

AGRouteDispatch class provide save/load AGRoute data in local storage.

# Regions (under development)

AGRegionMonitorDispatch class used for monitoring when enter/exit region.

## Requirements

## Installation

AGLocationDispatcher is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "AGLocationDispatcher"

## Author

Agilie info@agilie.com

## License

AGLocationDispatcher is available under the MIT license. See the LICENSE file for more info.

