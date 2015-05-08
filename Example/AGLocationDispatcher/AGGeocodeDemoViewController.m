//
//  AGGeocodeDemoViewController.m
//  AGLocationDispatcher
//
//  Created by Ankudinov Alexander on 2/10/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "AGGeocodeDemoViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "AGDispatcherHeaders.h"

@interface AGGeocodeDemoViewController ()

@property (weak, nonatomic) IBOutlet UIButton *geocodeProviderButton;
@property (weak, nonatomic) IBOutlet UITextField *geocodeAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *geocodeLatitudeTextField;
@property (weak, nonatomic) IBOutlet UITextField *geocodeLongitudeTextField;

@property (strong, nonatomic) AGGeoDispatcher *demoLocationService;
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@property (strong, nonatomic) AGLocationDispatcher *locationDispatcher;

- (IBAction)pressGeocodeAddressButton:(id)sender;
- (IBAction)pressGeocodeLocationButton:(id)sender;
- (IBAction)pressChangeGeocodeProviderButton:(id)sender;
- (IBAction)pressGeocodeCurrentLocationButton:(id)sender;

@end

@implementation AGGeocodeDemoViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Geocode demo"];
    self.demoLocationService = [[AGGeoDispatcher alloc] init]; // Set Yandex geocode provider by default
}

#pragma mark - Getters

- (NSNumberFormatter *)numberFormatter {
    if (!_numberFormatter) {
        _numberFormatter = [NSNumberFormatter new];
    }
    return _numberFormatter;
}

- (AGLocationDispatcher *)locationDispatcher {
    if (!_locationDispatcher) {
        _locationDispatcher = [AGLocationDispatcher new];
    }
    return _locationDispatcher;
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - IBActions

- (IBAction)pressGeocodeAddressButton:(id)sender {
    NSString *address = self.geocodeAddressTextField.text;
    if ([address length] > 0) {
        [self.demoLocationService requestLocationForAddress:self.geocodeAddressTextField.text success:^(id rezult) {
            CLLocation *geocodedLocation = [rezult lastObject];
            self.geocodeLatitudeTextField.text = [NSString stringWithFormat:@"%f", geocodedLocation.coordinate.latitude];
            self.geocodeLongitudeTextField.text = [NSString stringWithFormat:@"%f", geocodedLocation.coordinate.longitude];
        } andFail:^(NSError *error) {
            [self showError:error];
        }];
    } else {
        [self showErrorMessage:@"Please fill in address field"];
    }
}

- (IBAction)pressGeocodeLocationButton:(id)sender {
    NSNumber *latitudeNumber = [self.numberFormatter numberFromString:self.geocodeLatitudeTextField.text];
    NSNumber *longitudeNumber = [self.numberFormatter numberFromString:self.geocodeLongitudeTextField.text];
    if ([self isLatitudeValid:latitudeNumber] && [self isLongitudeValid:longitudeNumber]) {
        CLLocation *locationToGeocode = [[CLLocation alloc] initWithLatitude:[latitudeNumber doubleValue] longitude:[longitudeNumber doubleValue]];
        [self geocodeLocation:locationToGeocode];
    } else {
        [self showErrorMessage:@"Please fill in valid latitude and longitude"];
    }
}

- (IBAction)pressGeocodeCurrentLocationButton:(id)sender {
    __weak typeof(self)weakSelf = self;
    [self.locationDispatcher currentLocationWithBlock:^(CLLocationManager *manager, AGLocation *newLocation, AGLocation *oldLocation) {
        [weakSelf geocodeLocation:newLocation];
    } errorBlock:^(CLLocationManager *manager, NSError *error) {
        [self showError:error];
    }];
}

- (IBAction)pressChangeGeocodeProviderButton:(id)sender {
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select geocode delegate:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Yandex",
                            @"Google",
                            @"Apple",
                            @"Custom Yandex",
                            nil];
    popup.tag = 1;
    [popup showInView:self.view];
}

- (void)geocodeLocation:(CLLocation *)location {
    [self.demoLocationService requestGeocodeForLocation:location success:^(id rezult) {
        [[[UIAlertView alloc] initWithTitle:@"Reverse geocoded address" message:[rezult firstObject] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } andFail:^(NSError *error) {
        [self showError:error];
    }];
}

#pragma mark - Location Validators

- (BOOL)isLatitudeValid:(NSNumber *)latitudeNumber {
    double latitude = [latitudeNumber doubleValue];
    return latitudeNumber && latitude >= -90 && latitude <= 90;
}

- (BOOL)isLongitudeValid:(NSNumber *)longitudeNumber {
    double longitude = [longitudeNumber doubleValue];
    return longitudeNumber && longitude >= -180 && longitude <= 180;
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {

    NSString *geocodeProviderTitle = [popup buttonTitleAtIndex:buttonIndex];
    [self.geocodeProviderButton setTitle:geocodeProviderTitle forState:UIControlStateNormal];
    
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

#pragma mark - Error Handler

- (void)showError:(NSError *)error {
    [self showErrorMessage:[error localizedDescription] title:@"Error"];
}

- (void)showErrorMessage:(NSString *)errorMessage {
    [self showErrorMessage:errorMessage title:@"Error"];
}

- (void)showErrorMessage:(NSString *)errorMessage title:(NSString *)title {
    [[[UIAlertView alloc] initWithTitle:title message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark - View Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
