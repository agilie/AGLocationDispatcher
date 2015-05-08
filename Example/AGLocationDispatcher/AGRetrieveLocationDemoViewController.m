//
//  AGRetrieveLocationDemoViewController.m
//  AGLocationDispatcher
//
//  Created by Vladimir Zgonik on 11.02.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "AGRetrieveLocationDemoViewController.h"
#import "AGDispatcherHeaders.h"

static NSString *const kMapAnnotationIdentifier = @"mapAnnotationIdentifier";

@interface AGRetrieveLocationDemoViewController ()<AGLocationServiceDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) AGLocationDispatcher *locationDispatcher;

@end

@implementation AGRetrieveLocationDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationDispatcher = [[AGLocationDispatcher alloc] init];
    [self.locationDispatcher currentLocationWithBlock:^(CLLocationManager *manager, CLLocation *newLocation, CLLocation *oldLocation) {
        self.locationLabel.text = [NSString stringWithFormat:@"%g , %g", newLocation.coordinate.longitude, newLocation.coordinate.latitude];
    } errorBlock:nil];

    AGRoute *currentRoute = [[AGRouteDispatcher new] loadRouteWithName:@"route00001"];
    if (currentRoute) {
        [self drawRoute:currentRoute];
    }
}

- (void)drawRoute:(AGRoute *)route {
    __block AGLocation *prewPoint = nil;
    [route.routeParts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[AGRoutePart class]]) {
            AGRoutePart *part = (AGRoutePart *)obj;
            [part.routePartPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                AGLocation *location = (AGLocation *)obj;
                if (!prewPoint) {
                    prewPoint = location;
                    AGAnnotation *startPoint = [[AGAnnotation alloc] initWithType:AGAnnotationTypeStart location:location];
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
    AGAnnotation *finishPoint = [[AGAnnotation alloc] initWithType:AGAnnotationTypeFinish location:prewPoint];
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

@end
