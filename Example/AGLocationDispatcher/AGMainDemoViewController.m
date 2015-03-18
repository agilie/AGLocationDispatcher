//
//  AGMainDemoViewController.m
//  AGLocationDispatcher
//
//  Created by Vladimir Zgonik on 09.02.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "AGMainDemoViewController.h"
#import "AGDemoScreenViewController.h"
#import "AGGeocodeDemoViewController.h"
#import "AGRetrieveLocationDemoViewController.h"
#import "AGRegionTrackingViewController.h"

@interface AGMainDemoViewController ()

@end

@implementation AGMainDemoViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)geocodeButtonPressed:(id)sender {
    [self.navigationController pushViewController:[AGGeocodeDemoViewController new] animated:YES];
}

- (IBAction)trackingButtonPressed:(id)sender {
    [self.navigationController pushViewController:[AGDemoScreenViewController new] animated:YES];
}

- (IBAction)storeDataButtonPressed:(id)sender {
    [self.navigationController pushViewController:[AGRetrieveLocationDemoViewController new] animated:YES];
}

- (IBAction)regionDispatchDemoButtonPressed:(id)sender {
    [self.navigationController pushViewController:[AGRegionTrackingViewController new] animated:YES];
}

@end
