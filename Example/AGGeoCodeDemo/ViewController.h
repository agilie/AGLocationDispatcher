//
//  ViewController.h
//  AGGeoCodeDemo
//
//  Created by Ankudinov Alexander on 5/14/15.
//  Copyright (c) 2015 org.cocoapods.demo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIActionSheetDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *adressEdit;
@property (weak, nonatomic) IBOutlet UITextField *lanEdit;
@property (weak, nonatomic) IBOutlet UITextField *latEdit;
@property (weak, nonatomic) IBOutlet UIButton *providerSelectButton;

- (IBAction)convertToCoordinateTap:(id)sender;
- (IBAction)convertToAdressTap:(id)sender;
- (IBAction)providerSelectTap:(id)sender;

@end

