//
//  AGDemoScreenViewController.m
//  AGLocationDispatcher
//
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "TrackingViewController.h"
#import <MapKit/MapKit.h>
#import <MapKit/MKGeodesicPolyline.h>

static NSString *const kMapAnnotationIdentifier = @"mapAnnotationIdentifier";

#define RGB255(R, G, B) [UIColor colorWithRed:R/255.f green:G/255.f blue:B/255.f alpha:1.0f]

@interface TrackingViewController () <MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *currentSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *showSavedRouteButton;
@property (weak, nonatomic) IBOutlet UIButton *startRecButton;
@property (weak, nonatomic) IBOutlet UIButton *stopRecButton;
@property (weak, nonatomic) IBOutlet UIView *markersView;
@property (weak, nonatomic) IBOutlet UICollectionView *markersCollectionView;
@property (strong, nonatomic) AGLocation *lastPoint;
@property (strong, nonatomic) AGAnnotation *currentPositionAnnotation;
@property (strong, nonatomic) AGAnnotation *startPositionAnnotation;
@property (assign, nonatomic) AGAnnotationType startMarkType;
@property (assign, nonatomic) AGAnnotationType finishMarkType;
@property (strong, nonatomic) AGRouteDispatcher *routeDispatch;
@property (strong, nonatomic) AGRoute *currentRoute;
@property (assign, nonatomic) BOOL isTrackingNow;
@property (assign, nonatomic) BOOL isSavedRoutes;
@property (assign, nonatomic) int currentRouteNumber;
@property (strong, nonatomic) NSArray *markers;
@property (strong, nonatomic) NSString *selectedMarkerImage;

@end

@implementation TrackingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    [self.markersCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.navigationItem setTitle:@"Tracking demo"];
    self.markers = @[@"finish0", @"finish1", @"finish2"];
    self.startMarkType = AGAnnotationType0Start;
    self.finishMarkType = AGAnnotationType0Finish;
    NSNumber *storedRouteNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentRouteIndex"];
    self.currentRouteNumber = -1;
    self.isSavedRoutes = NO;
    if (storedRouteNumber) {
        self.currentRouteNumber = [storedRouteNumber intValue];
        self.isSavedRoutes = YES;
    }
    self.isTrackingNow = NO;
    self.lastPoint = nil;
    [self.startRecButton setEnabled:YES];
    [self.startRecButton setAlpha:1.0];
    [self.stopRecButton setEnabled:NO];
    [self.stopRecButton setAlpha:0.5];
    if(!self.isSavedRoutes) {
        [self.showSavedRouteButton setEnabled:NO];
        [self.showSavedRouteButton setAlpha:0.5];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startTracking];
}

- (IBAction)showSavedRouteButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"showSaved" sender:nil];
}

- (IBAction)startButtonPressed:(id)sender {
    self.startPositionAnnotation = nil;
    NSString *routeName = @"route";
    self.currentRouteNumber++;
    routeName = [routeName stringByAppendingString:[NSString stringWithFormat:@"%i", self.currentRouteNumber]];
    [self.navigationItem setTitle:[NSString stringWithFormat:@"Recording %@", routeName]];
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs setObject:@(self.currentRouteNumber) forKey:@"currentRouteIndex"];
    [defs synchronize];
    
    self.currentRoute = [AGRoute new];
    [self.currentRoute setRefreshTimeout:kAGLocationUpdateIntervalOneSec];
    [self.currentRoute setMoveType:0];
    [self.currentRoute setSessionId:routeName];
    
    self.isTrackingNow = YES;
    [self.startRecButton setEnabled:NO];
    [self.startRecButton setAlpha:0.5];
    [self.stopRecButton setEnabled:YES];
    [self.stopRecButton setAlpha:1.0];
    if(!self.isSavedRoutes) {
        [self.showSavedRouteButton setEnabled:NO];
        [self.showSavedRouteButton setAlpha:0.5];
    }
    self.lastPoint = nil;
}

- (IBAction)stopButtonPressed:(id)sender {
    [self.navigationItem setTitle:@"Tracking demo"];
    self.currentPositionAnnotation = nil;
    self.isTrackingNow = NO;
    [self.stopRecButton setEnabled:NO];
    [self.stopRecButton setAlpha:0.5];
    [self.startRecButton setEnabled:YES];
    [self.startRecButton setAlpha:1.0];
    [self.showSavedRouteButton setEnabled:YES];
    [self.showSavedRouteButton setAlpha:1.0];
    self.lastPoint = nil;
    [self.currentSpeedLabel setText:@"cur speed: -"];
    [self.averageSpeedLabel setText:@"avg speed: -"];
    [self.distanceLabel setText:@"- :distance"];
    [self.currentRoute finishRoute];
    [self.routeDispatch saveRoute:self.currentRoute name:[self.currentRoute sessionId]];
}

- (void)startTracking {
    if (!self.routeDispatch) {
        self.routeDispatch = [[AGRouteDispatcher alloc] initWithUpdatingInterval:kAGLocationUpdateIntervalOneSec andDesiredAccuracy:kAGHorizontalAccuracyNeighborhood];
    }
    [self.routeDispatch startUpdatingLocationAndSpeedWithBlock:^(CLLocationManager *manager, AGLocation *newLocation, AGLocation *oldLocation, NSNumber *speed) {
        if (self.markersView.hidden) {
            if (!self.currentPositionAnnotation) {
                self.currentPositionAnnotation = [[AGAnnotation alloc] initWithType:self.finishMarkType location:newLocation];
                [self.mapView addAnnotation:self.currentPositionAnnotation];
            } else {
                [self.currentPositionAnnotation setCoordinate:newLocation.coordinate];
            }
        }
        [self centerMapWithUserCoordinate:newLocation.coordinate];
        if (self.isTrackingNow) {
            if (!self.startPositionAnnotation) {
                self.startPositionAnnotation = [[AGAnnotation alloc] initWithType:self.startMarkType location:newLocation];
                [self.mapView addAnnotation:self.startPositionAnnotation];
            }
            [self.currentRoute addRoutePoint:newLocation];
            
            if (self.lastPoint) {
                CLLocationCoordinate2D coordinates[2];
                coordinates[0] = self.lastPoint.coordinate;
                coordinates[1] = newLocation.coordinate;
                MKGeodesicPolyline *geoPolyline = [MKGeodesicPolyline polylineWithCoordinates:coordinates count:2];
                if (geoPolyline) {
                    [self.mapView addOverlay:geoPolyline];
                }
            }
            
            //speed
            int calculatedSpeed = [speed intValue];
            if (calculatedSpeed > -1) {
                [self.currentRoute addSpeed:calculatedSpeed];
                [self.currentSpeedLabel setText:[NSString stringWithFormat:@"cur speed: %i km/h", calculatedSpeed]];
            }
            
            int avgSpeed = (int)[self.currentRoute averageSpeed];
            if (avgSpeed > 0) {
                [self.averageSpeedLabel setText:[NSString stringWithFormat:@"avg speed: %i km/h", avgSpeed]];
            }
            int dist = (int)[self.currentRoute routeDistance];
            [self.distanceLabel setText:[NSString stringWithFormat:@"%i m :distance", dist]];
        }
        
        self.lastPoint = newLocation;
    }
                                                    errorBlock:^(CLLocationManager *manager, NSError *error) {
                                                        [self displayDemoError:error];
                                                        NSLog(@"Fail start Tracking %@", error);
                                                    }];
}

- (void)didChangeRegionAuthorizationStatus:(CLAuthorizationStatus)status {
    [self startTracking];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        routeRenderer.strokeColor = [UIColor greenColor];
        routeRenderer.lineWidth = 4;
        return routeRenderer;
    }
    else {return nil;}
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

- (void)centerMapWithUserCoordinate:(CLLocationCoordinate2D)coordinate {
    [self.mapView setCenterCoordinate:coordinate animated:YES];
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.004f, 0.004f));
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];
}

- (void)displayDemoError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:@"Geocode error!" message:[error description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [imageView setImage:[UIImage imageNamed:[self.markers objectAtIndex:indexPath.row]]];
    [cell.contentView addSubview:imageView];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            self.startMarkType = AGAnnotationType0Start;
            self.finishMarkType = AGAnnotationType0Finish;
            break;
        case 1:
            self.startMarkType = AGAnnotationType1Start;
            self.finishMarkType = AGAnnotationType1Finish;
            break;
        case 2:
            self.startMarkType = AGAnnotationType2Start;
            self.finishMarkType = AGAnnotationType2Finish;
            break;
        default:
            self.startMarkType = AGAnnotationType0Start;
            self.finishMarkType = AGAnnotationType0Finish;
            break;
    }
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs setObject:@(self.startMarkType) forKey:@"selectedMarkType"];
    [defs synchronize];
    [self.markersView setHidden:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.markers.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

@end
