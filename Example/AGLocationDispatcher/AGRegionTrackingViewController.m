//
//  AGRegionTrackingViewController.m
//  AGLocationDispatcher
//
//  Created by Vermillion on 16.03.15.
//  Copyright (c) 2015 kalamaznik. All rights reserved.
//

#import "AGRegionTrackingViewController.h"
#import "AGRegionDispatcher.h"

@interface AGRegionTrackingViewController ()

@property (weak, nonatomic) IBOutlet UILabel *currentStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentLocationLabel;
@property (strong, nonatomic) AGRegionDispatcher *regionDispatcher;
@property (strong, nonatomic) AGLocation *centerLocation;

@end

@implementation AGRegionTrackingViewController

@synthesize regionDispatcher = _regionDispatcher;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Region dispatch"];
    __weak typeof(self) weakSelf = self;
    if ([AGRegionDispatcher regionMonitoringAvailable:[CLCircularRegion class]]) {
        [weakSelf.currentStatusLabel setText:@"Status: Ttracking user location (in/out region)"];
        [self.regionDispatcher startUpdatingLocationAndSpeedWithBlock:^(CLLocationManager *manager, AGLocation *newLocation, AGLocation *oldLocation, NSNumber *speed) {
            if (!weakSelf.centerLocation) {
                weakSelf.centerLocation = newLocation;
                [self addRegionForTracking:newLocation];
            } else {
                [self.currentLocationLabel setText:[NSString stringWithFormat:@"%@", newLocation]];
            }
        } errorBlock:^(CLLocationManager *manager, NSError *error) {
            [weakSelf.currentStatusLabel setText:@"Status: Current location tracking error"];
        }];
    } else {
        [weakSelf.currentStatusLabel setText:@"Status: Region monitoring is not available"];
    }
}

- (void)addRegionForTracking:(AGLocation *)newLocation {
    __weak typeof(self) weakSelf = self;
    [weakSelf.regionDispatcher addCoordinateForMonitoring:weakSelf.centerLocation.coordinate updateBlock:^(CLLocationManager *manager, CLCircularRegion *region, BOOL enter) {
        if (enter) {
            [weakSelf.currentStatusLabel setText:[NSString stringWithFormat:@"Status: Enter %@", region.description]];
        } else {
            [weakSelf.currentStatusLabel setText:[NSString stringWithFormat:@"Status: Exit %@", region.description]];
        }
    } failBlock:^(CLLocationManager *manager, CLCircularRegion *region, NSError *error) {
        [weakSelf.currentStatusLabel setText:@"Status: Region tracking error"];
    }];
}

- (AGRegionDispatcher*)regionDispatcher {
    if (!_regionDispatcher) {
        _regionDispatcher = [[AGRegionDispatcher alloc] init];
    }
    return _regionDispatcher;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.regionDispatcher stopMonitoringAllRegions];
}

@end
