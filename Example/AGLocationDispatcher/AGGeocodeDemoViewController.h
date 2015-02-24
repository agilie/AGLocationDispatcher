//
//  AGGeocodeDemoViewController.h
//  AGLocationDispatcher
//
//  Created by Ankudinov Alexander on 2/10/15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGGeocodeDemoViewController : UIViewController<UIActionSheetDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *demoGeocodeTargetEdit;

- (IBAction)demoGeocodeTargetAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *demoLocationTargetEdit;

- (IBAction)demoLocationTargetAction:(id)sender;

- (IBAction)demoGeocodeChangeProviderAction:(id)sender;

@end
