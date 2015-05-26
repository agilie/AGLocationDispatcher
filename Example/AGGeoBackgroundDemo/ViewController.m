//
//  ViewController.m
//  AGGeoBackgroundDemo
//
//  Created by Ankudinov Alexander on 5/22/15.
//  Copyright (c) 2015 org.cocoapods.demo. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "AGDispatcherHeaders.h"

@interface ViewController ()

@property (strong, nonatomic) AGLocationDispatcher *demoLocationDispatcher;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    if([AGLocationDispatcher locationServicesEnabled]){
        self.demoLocationDispatcher = [[AGLocationDispatcher alloc] initWithUpdatingInterval:kAGLocationUpdateIntervalOneSec andDesiredAccuracy:kAGHorizontalAccuracyNeighborhood];
        
        [self.demoLocationDispatcher setLocationUpdateBackgroundMode: AGLocationBackgroundModeSignificantLocationChanges];
        
        //This for both ignificant and fetch location update demo, in mormal mode use or AGLocationBackgroundModeSignificantLocationChanges or AGLocationBackgroundModeFetch
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
        
        [self.demoLocationDispatcher currentLocationWithBlock:^(CLLocationManager *manager, AGLocation *newLocation, AGLocation *oldLocation) {
            
            if(newLocation){
                self.locationView.text = [NSString stringWithFormat:@"%f;%f",newLocation.coordinate.latitude ,newLocation.coordinate.longitude];
            }
            
            [self.demoLocationDispatcher stopUpdatingLocation];
            
        } errorBlock:^(CLLocationManager *manager, NSError *error) {
            [self displayDemoError:error];
        }];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)hrhrthrthh:(id)sender {
}


- (void)displayDemoError:(NSError *)error {
    
    [[[UIAlertView alloc] initWithTitle:@"Geocode error!" message:[error description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    
}


@end
