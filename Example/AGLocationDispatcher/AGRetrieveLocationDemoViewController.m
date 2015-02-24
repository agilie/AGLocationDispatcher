//
//  LDRetrieveLocationDemoViewController.m
//  AGLocationDispatcher
//
//  Created by Vladimir Zgonik on 11.02.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "AGRetrieveLocationDemoViewController.h"
#import "LDLocationDispatch.h"
#import "LDRoute.h"
#import "LDAnnotation.h"
#import "LDLocation.h"
#import "LDGeoLocationDispatch.h"
#import "LDRouteDispatch.h"

static NSString *const kMapAnnotationIdentifier = @"mapAnnotationIdentifier";

@interface AGRetrieveLocationDemoViewController ()<LDLocationServiceDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation AGRetrieveLocationDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    LDLocationDispatch *service = [[LDLocationDispatch alloc] init];
    [service currentPosition:^(CLLocationManager *manager, CLLocation *newLocation, CLLocation *oldLocation) {
        self.locationLabel.text = [NSString stringWithFormat:@"%g , %g", newLocation.coordinate.longitude, newLocation.coordinate.latitude];
    }                onError:nil];

    LDRoute *currentRoute = [[LDRouteDispatch new] loadRouteWithName:@"route00001"];
    if (currentRoute) {
        [self drawRoute:currentRoute];
    }
}

- (void)drawRoute:(LDRoute *)route {
    __block LDLocation *prewPoint = nil;
    [route.routeParts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[LDRoutePart class]]) {
            LDRoutePart *part = (LDRoutePart *)obj;
            [part.routePartPoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                LDLocation *location = (LDLocation *)obj;
                if (!prewPoint) {
                    prewPoint = location;
                    LDAnnotation *startPoint = [[LDAnnotation alloc] initWithType:LDAnnotationTypeStart location:location];
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
    LDAnnotation *finishPoint = [[LDAnnotation alloc] initWithType:LDAnnotationTypeFinish location:prewPoint];
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
    if ([annotation isKindOfClass:[LDAnnotation class]]) {
        NSString *imageName = [(LDAnnotation *)annotation annotationImageName];
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
