//
//  RegionTrackingViewController.m
//  AGGeoRegionTrackingDemo
//
//  Created by Vermillion on 28.05.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "RegionTrackingViewController.h"
#import <MapKit/MapKit.h>
#import <MapKit/MKGeodesicPolyline.h>

static const int kRegionRadius = 100;
static NSString *const kMapAnnotationIdentifier = @"mapAnnotationIdentifier";

@interface RegionTrackingViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) AGLocationDispatcher *locationDispatcher;
@property (assign, nonatomic) BOOL isTrackingNow;
@property (assign, nonatomic) BOOL isRegionSelected;
@property (strong, nonatomic) AGLocation *userStartLocation;
@property (strong, nonatomic) AGRegionDispatcher *regionDispatcher;
@property (strong, nonatomic) AGLocation *centerLocation;
@property (strong, nonatomic) CLCircularRegion *region;
@property (strong, nonatomic) MKCircle *circle;
@property (strong, nonatomic) AGAnnotation *currentPositionAnnotation;

@end

@implementation RegionTrackingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isTrackingNow = self.isRegionSelected = NO;
    if (![AGRegionDispatcher regionMonitoringAvailable:[CLCircularRegion class]]) {
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Region monitoring is not available" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setCurrentLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addRegionForTracking:(AGLocation *)location {
    __weak typeof(self) weakSelf = self;
    self.region = [[CLCircularRegion alloc] initWithCenter:location.coordinate radius:kRegionRadius identifier:@"region"];
    [weakSelf.regionDispatcher addRegionForMonitoring:self.region desiredAccuracy:AGLocationAccuracyRoom updateBlock:^(CLLocationManager *manager, CLCircularRegion *region, BOOL enter) {
        if (enter) {
            [[[UIAlertView alloc] initWithTitle:@"Region tracking" message:@"You have entered region" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Region tracking" message:@"You have left region" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    } failBlock:^(CLLocationManager *manager, CLCircularRegion *region, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error!" message:[error description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }];
}

- (void)stopTrackingRegion {
    [self.regionDispatcher stopMonitoringForRegion:self.region];
}

- (AGRegionDispatcher*)regionDispatcher {
    if (!_regionDispatcher) {
        _regionDispatcher = [[AGRegionDispatcher alloc] init];
    }
    return _regionDispatcher;
}

- (void)setCurrentLocation {
    if (!self.locationDispatcher) {
        self.locationDispatcher = [[AGLocationDispatcher alloc] initWithUpdatingInterval:kAGLocationUpdateIntervalOneSec andDesiredAccuracy:kAGHorizontalAccuracyRoom];
    }
    [self.locationDispatcher startUpdatingLocationWithBlock:^(CLLocationManager *manager, AGLocation *newLocation, AGLocation *oldLocation) {
        if (!self.currentPositionAnnotation) {
            self.currentPositionAnnotation = [[AGAnnotation alloc] initWithType:AGAnnotationType0Finish location:newLocation];
            [self.mapView addAnnotation:self.currentPositionAnnotation];
        }
        [self.currentPositionAnnotation setCoordinate:newLocation.coordinate];
        if (self.isTrackingNow) {
            [self centerMapWithUserCoordinate:newLocation.coordinate];
        }
        if (!self.userStartLocation) {
            self.userStartLocation = self.centerLocation = newLocation;
            [self centerMapWithUserCoordinate:self.userStartLocation.coordinate];
            if (!self.circle) {
                self.circle = [MKCircle circleWithCenterCoordinate:self.centerLocation.coordinate radius:kRegionRadius];
                [self.mapView addOverlay:self.circle];
            }
        }
    } errorBlock:^(CLLocationManager *manager, NSError *error) {
        [self displayDemoError:error];
    }];
}

- (void)centerMapWithUserCoordinate:(CLLocationCoordinate2D)coordinate {
    [self.mapView setCenterCoordinate:coordinate animated:YES];
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.004f, 0.004f));
    [self.mapView setRegion:region animated:YES];
}

-(MKOverlayRenderer *)mapView:(MKMapView*)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKCircle * circle = (MKCircle *)overlay;
    MKCircleRenderer * renderer = [[MKCircleRenderer alloc] initWithCircle:circle];
    [renderer setFillColor:[UIColor greenColor]];
    [renderer setStrokeColor:[UIColor blackColor]];
    [renderer setLineWidth:1];
    [renderer setAlpha:0.25];
    return renderer;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[AGAnnotation class]]) {
        NSString *imageName = [(AGAnnotation *)annotation annotationImageName];
        if (imageName) {
            MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kMapAnnotationIdentifier];
            if (!annotationView) {
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kMapAnnotationIdentifier];
            } else {
                annotationView.annotation = annotation;
            }
            annotationView.image = [UIImage imageNamed:imageName];
            return annotationView;
        }
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (self.circle && !self.isTrackingNow) {
        self.centerLocation = [[AGLocation alloc] initWithLatitude:[self.mapView region].center.latitude longitude:[self.mapView region].center.longitude];
        [self.mapView removeOverlay:self.circle];
        self.circle = [MKCircle circleWithCenterCoordinate:self.centerLocation.coordinate radius:kRegionRadius];
        [self.mapView addOverlay:self.circle];
    }
}

- (void)displayDemoError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:@"Geocode error!" message:[error description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

- (IBAction)startTrackingRegionButtonPressed:(id)sender {
    if (!self.isTrackingNow) {
        self.centerLocation = [[AGLocation alloc] initWithLatitude:[self.mapView region].center.latitude longitude:[self.mapView region].center.longitude];
        [sender setTitle:@"Stop tracking this region" forState:UIControlStateNormal];
        [self addRegionForTracking:self.centerLocation];
    } else {
        [sender setTitle:@"Start tracking this region" forState:UIControlStateNormal];
        [self.mapView removeOverlay:self.circle];
        self.circle = [MKCircle circleWithCenterCoordinate:self.userStartLocation.coordinate radius:kRegionRadius];
        [self.mapView addOverlay:self.circle];
        [self stopTrackingRegion];
    }
    self.isTrackingNow = !self.isTrackingNow;
    [self.infoLabel setHidden:self.isTrackingNow];
}

@end
