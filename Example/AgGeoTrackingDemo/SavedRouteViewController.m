//
//  AGRetrieveLocationDemoViewController.m
//  AGLocationDispatcher
//
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "SavedRouteViewController.h"
#import "AGDispatcherHeaders.h"

static NSString *const kMapAnnotationIdentifier = @"mapAnnotationIdentifier";

@interface SavedRouteViewController () <AGLocationServiceDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *savedRoutesButton;
@property (weak, nonatomic) IBOutlet UILabel *maxSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *avgSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (assign, nonatomic) AGAnnotationType startMarkType;
@property (assign, nonatomic) AGAnnotationType finishMarkType;
@property (strong, nonatomic) NSMutableArray *savedRouteNames;
@property (strong, nonatomic) AGRoute *currentRoute;
@property (strong, nonatomic) NSString *currentRouteName;

@end

@implementation SavedRouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.tableView setHidden:YES];
    NSNumber *storedMarkType = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedMarkType"];
    if (storedMarkType) {
        self.startMarkType = [storedMarkType intValue];
        switch (self.startMarkType) {
            case AGAnnotationType0Start:
                self.finishMarkType = AGAnnotationType0Finish;
                break;
            case AGAnnotationType1Start:
                self.finishMarkType = AGAnnotationType1Finish;
                break;
            case AGAnnotationType2Start:
                self.finishMarkType = AGAnnotationType2Finish;
                break;
            default:
                break;
        }
    } else {
        self.startMarkType = AGAnnotationType0Start;
        self.finishMarkType = AGAnnotationType0Finish;
    }
    
    NSString *routeString = [AGRouteDispatcher getStoredRoutesDir];
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:routeString error:&error];
    if (files == nil) {
        AGLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
    }
    self.savedRouteNames = [NSMutableArray array];
    for (NSString *file in files) {
        [self.savedRouteNames addObject:file];
    }
    [self.savedRouteNames sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int indx1 = [[(NSString*)obj1 stringByReplacingOccurrencesOfString:@"route" withString:@""] intValue];
        int indx2 = [[(NSString*)obj2 stringByReplacingOccurrencesOfString:@"route" withString:@""] intValue];
        return indx1 > indx2;
    }];
    
    self.currentRouteName = [self.savedRouteNames lastObject];
    [self.navigationItem setTitle:self.currentRouteName];
    self.currentRoute = [[AGRouteDispatcher new] loadRouteWithName:self.currentRouteName];
    if (self.currentRoute) {
        [self drawRoute:self.currentRoute];
    }
}

- (IBAction)savedRoutesButtonPressed:(id)sender {
    [self.savedRoutesButton setHidden:YES];
    [self.tableView setHidden:NO];
}

- (void)drawRoute:(AGRoute *)route {
    [self.mapView removeOverlays:[self.mapView overlays]];
    [self.mapView removeAnnotations:[self.mapView annotations]];
    __block AGLocation *prewPoint = nil;
    int maxSpeed = (int)[route maxSpeed];
    [self.maxSpeedLabel setText:[NSString stringWithFormat:@"max speed: %i km/h", maxSpeed]];
    int avgSpeed = (int)[route averageSpeed];
    [self.avgSpeedLabel setText:[NSString stringWithFormat:@"avg speed: %i km/h", avgSpeed]];
    int dist = (int)[route routeDistance];
    [self.distanceLabel setText:[NSString stringWithFormat:@"%i m :distance", dist]];
    [route.routeParts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[AGRoutePart class]]) {
            AGRoutePart *part = (AGRoutePart *)obj;
            [part.routePartPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                AGLocation *location = (AGLocation *)obj;
                if (!prewPoint) {
                    prewPoint = location;
                    AGAnnotation *startPoint = [[AGAnnotation alloc] initWithType:self.startMarkType location:location];
                    [self.mapView addAnnotation:startPoint];
                } else {
                    CLLocationCoordinate2D coordinates[2];
                    coordinates[0] = prewPoint.coordinate;
                    coordinates[1] = location.coordinate;
                    MKGeodesicPolyline *geoPolyline = [MKGeodesicPolyline polylineWithCoordinates:coordinates count:2];
                    if (geoPolyline) {
                        [self.mapView addOverlay:geoPolyline];
                    }
                    prewPoint = location;
                }
            }];
        }
    }];
    AGAnnotation *finishPoint = [[AGAnnotation alloc] initWithType:self.finishMarkType location:prewPoint];
    [self.mapView addAnnotation:finishPoint];
    [self centerMapWithUserCoordinate:prewPoint.coordinate];
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
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.04f, 0.04f));
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    [cell.textLabel setText:[self.savedRouteNames objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView setHidden:YES];
    [self.savedRoutesButton setHidden:NO];
    self.currentRouteName = [self.savedRouteNames objectAtIndex:indexPath.row];
    [self.navigationItem setTitle:self.currentRouteName];
    self.currentRoute = [[AGRouteDispatcher new] loadRouteWithName:self.currentRouteName];
    if (self.currentRoute) {
        [self drawRoute:self.currentRoute];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.savedRouteNames.count;
}

@end
