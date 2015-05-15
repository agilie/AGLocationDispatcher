//
//  ViewController.m
//  AGGeoCodeDemo
//
//  Created by Ankudinov Alexander on 5/14/15.
//  Copyright (c) 2015 org.cocoapods.demo. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "AGDispatcherHeaders.h"

@interface ViewController ()

@property (strong, nonatomic) AGGeoDispatcher *demoLocationService;
@property (strong, nonatomic) AGLocationDispatcher *demoLocationDispatcher;

@end

@implementation ViewController

id shit;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.demoLocationService = [[AGGeoDispatcher alloc] init];
    [self.providerSelectButton setTitle:@"Current provide: Yandex" forState: UIControlStateNormal];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldShouldReturn:)];
    [self.view addGestureRecognizer: tapGesture];
    
    self.demoLocationDispatcher = [[AGLocationDispatcher alloc] initWithUpdatingInterval:kAGLocationUpdateIntervalOneSec andDesiredAccuracy:kAGHorizontalAccuracyNeighborhood];

    [self.demoLocationDispatcher currentLocationWithBlock:^(CLLocationManager *manager, AGLocation *newLocation, AGLocation *oldLocation) {
        self.lanEdit.text = [NSString stringWithFormat:@"%f", newLocation.coordinate.longitude];
        self.latEdit.text = [NSString stringWithFormat:@"%f", newLocation.coordinate.latitude ];
        
        [self.demoLocationDispatcher stopUpdatingLocation];
        
        [self convertToAdressTap: nil];
        
    } errorBlock:^(CLLocationManager *manager, NSError *error) {
         [self displayDemoError:error];
    }];
 
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.adressEdit resignFirstResponder];
    [self.lanEdit resignFirstResponder];
    [self.latEdit resignFirstResponder];
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)convertToCoordinateTap:(id)sender {
    
    [self.demoLocationService requestLocationForAddress:self.adressEdit.text success:^(id rezult) {
        
        CLLocation *temploc = [rezult lastObject];
        
        self.lanEdit.text = [NSString stringWithFormat:@"%f", temploc.coordinate.longitude];
        self.latEdit.text = [NSString stringWithFormat:@"%f", temploc.coordinate.latitude ];
        
    } andFail:^(NSError *err) {
        
        [self displayDemoError:err];
        
    }];
    
}

- (IBAction)convertToAdressTap:(id)sender {
    
    CLLocation *temploc = [[CLLocation alloc] initWithLatitude:   [self.latEdit.text floatValue] longitude: [self.lanEdit.text floatValue]];
    
    [self.demoLocationService requestGeocodeForLocation:temploc success:^(id rezult) {
        
        self.adressEdit.text = [rezult firstObject];
        
    } andFail:^(NSError *err) {
        
        [self displayDemoError:err];
        
    }];
    
}

- (IBAction)providerSelectTap:(id)sender {
    
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select geocode delegate:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Yandex",
                            @"Google",
                            @"Apple",
                            @"Custom Yandex",
                            nil];
    popup.tag = 1;
    [popup showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSArray *providerNames =   @[@"Yandex",
                                 @"Google",
                                 @"Apple",
                                 @"Custom Yandex"];
    
    if([providerNames count] > buttonIndex ) {
        [self.providerSelectButton setTitle:[NSString stringWithFormat: @"Current provide: %@", providerNames[buttonIndex]] forState: UIControlStateNormal];
    }

    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [self.demoLocationService setGeocoderProvider:[[AGGeocodeYandexProvider alloc] init]];
                    break;
                    
                case 1:
                    [self.demoLocationService setGeocoderProvider:[[AGGeocodeGoogleProvider alloc] init]];
                    break;
                    
                case 2:
                    [self.demoLocationService setGeocoderProvider:[[AGGeocodeAppleProvider alloc] init]];
                    break;
                    
                case 3:
                    [self.demoLocationService setGeocoderProvider:[[AGGeocodeYandexProvider alloc] init] withApiKey:nil andISOLanguageAndRegionCode:@"uk_UA"];
                    break;
                    
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void)displayDemoError:(NSError *)error {
    
    [[[UIAlertView alloc] initWithTitle:@"Geocode error!" message:[error description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    
}

@end
