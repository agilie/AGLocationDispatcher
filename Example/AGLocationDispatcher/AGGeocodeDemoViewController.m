//
//  AGGeocodeDemoViewController.m
//  AGLocationDispatcher
//
//  Created by Ankudinov Alexander on 2/10/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "AGGeocodeDemoViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "LDDispatchHeaders.h"

@interface AGGeocodeDemoViewController ()

@property (strong, nonatomic) LDGeoLocationDispatch *demoLocationService;

@end

@implementation AGGeocodeDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setTitle:@"Geocode demo"];
    self.demoLocationService = [[LDGeoLocationDispatch alloc] init];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

id temp;

- (IBAction)demoGeocodeTargetAction:(id)sender {

    [self.demoLocationService requestLocationForAddress:self.demoGeocodeTargetEdit.text success:^(id rezult) {

        CLLocation *temploc = [rezult lastObject];

        NSString *stringedLocation = [NSString stringWithFormat:@"%f, %f", temploc.coordinate.latitude, temploc.coordinate.longitude];

        self.demoLocationTargetEdit.text = stringedLocation;

        temp = [rezult firstObject];

    }                                           andFail:^(NSError *err) {

        [self displayDemoError:err];

    }];

}

- (IBAction)demoLocationTargetAction:(id)sender {

    [self.demoLocationService requestGeocodeForLocation:temp success:^(id rezult) {

        [[[UIAlertView alloc] initWithTitle:@"We find that:" message:[rezult firstObject] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];

    }                                           andFail:^(NSError *err) {

        [self displayDemoError:err];

    }];
}

- (IBAction)demoGeocodeChangeProviderAction:(id)sender {

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

    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:

                    [self.demoLocationService setGeocoderProvider:[[LDGeocodeYandexProvider alloc] init]];

                    break;
                case 1:

                    [self.demoLocationService setGeocoderProvider:[[LDGeocodeGoogleProvider alloc] init]];

                    break;
                case 2:

                    [self.demoLocationService setGeocoderProvider:[[LDGeocodeAppleProvider alloc] init]];

                    break;
                case 3:

                    [self.demoLocationService setGeocoderProvider:[[LDGeocodeYandexProvider alloc] init] withApiKey:nil andISOLanguageAndRegionCode:@"uk_UA"];

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
