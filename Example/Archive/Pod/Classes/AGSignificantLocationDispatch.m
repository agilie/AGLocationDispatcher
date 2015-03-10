//
//  LDSignificantLocationDispatch.m
//  Pods
//
//  Created by Ankudinov Alexander on 3/6/15.
//
//

#import "AGSignificantLocationDispatch.h"


@interface AGSignificantLocationDispatch ()

@property (copy) LDSignificationLocationASynchronousUpdateBlock asyncUpdateBlock;
@property (copy) LDSignificationLocationASynchronousEndUpdateBlock endUpdateBlock;

@property UIBackgroundTaskIdentifier backgroundTask;

@property CLLocationManager *locationManager;

@end

@implementation AGSignificantLocationDispatch


- (instancetype)initWithASynchronousLocationUpdateBlock:(LDSignificationLocationASynchronousUpdateBlock)updateBlock {
    self = [super init];
    if (self) {
        
        self.backgroundTask  = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: ^{
            [[UIApplication sharedApplication] endBackgroundTask: self.backgroundTask  ];
        }];
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        self.asyncUpdateBlock = updateBlock;
        
    }
    
    return self;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    if(self.asyncUpdateBlock ){
        
        __weak typeof(self) weakSelf = self;
        
        self.asyncUpdateBlock( [locations lastObject], self.endUpdateBlock );

        self.endUpdateBlock = ^void{
            [weakSelf endBackgroundTask];
        };
        
    } else {
        [self endBackgroundTask];
    }
    
}

- (void)endBackgroundTask {
    if (self.backgroundTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask: self.backgroundTask ];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}

@end
