//
//  LDSignificantLocationDispatch.m
//  Pods
//
//  Created by Ankudinov Alexander on 3/6/15.
//
//

#import "AGBackgroundLocationDispatcher.h"
#import "AGDispatcherDefines.h"

@interface AGBackgroundLocationDispatcher ()

@property (copy) LDSignificationLocationASynchronousUpdateBlock asyncUpdateBlock;
@property (copy) LDSignificationLocationASynchronousEndUpdateBlock endUpdateBlock;

@property UIBackgroundTaskIdentifier backgroundTask;

@property CLLocationManager *locationManager;
@property NSTimer *nonSleepTimer;

@end

@implementation AGBackgroundLocationDispatcher

static AGBackgroundLocationDispatcher *sharedAGSignificantLocationDispatcher = nil;


- (instancetype)initWithASynchronousLocationUpdateBlock:(LDSignificationLocationASynchronousUpdateBlock)updateBlock {
    self = [super init];
    
    if (self) {
        
        self.backgroundTask  = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: ^{
            [[UIApplication sharedApplication] endBackgroundTask: self.backgroundTask  ];
        }];
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        
        self.locationManager.delegate = self;
        
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        {
            [self.locationManager requestAlwaysAuthorization];
        }
        
        [self.locationManager startUpdatingLocation];
        
        self.asyncUpdateBlock = updateBlock;
        
        self.nonSleepTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                        target:self
                                                      selector:@selector(iAmLiveTimerMethod)
                                                      userInfo:nil
                                                       repeats:YES];
        
    }
    
    return self;
}

-(void) iAmLiveTimerMethod{
     AGLog(@"AGSignificantLocationDispatcher are live");
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{

     AGLog(@"AGSignificantLocationDispatcher location fails with error: %@", error);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    if(self.nonSleepTimer){
    
        [self.nonSleepTimer invalidate];
        self.nonSleepTimer = nil;
        if(self.asyncUpdateBlock ){
        
            __weak typeof(self) weakSelf = self;
      
            self.endUpdateBlock = ^void{
                [weakSelf endBackgroundTask];
            };
        
            self.asyncUpdateBlock( [locations lastObject], self.endUpdateBlock );

        } else {
            [self endBackgroundTask];
        }
    }
}

- (void)endBackgroundTask {
    if (self.backgroundTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask: self.backgroundTask ];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
    
    [self.locationManager stopUpdatingLocation];
    
}

- (void)dealloc{
    [self endBackgroundTask];
    AGLog(@"AGSignificantLocationDispatcher are die");
}

@end
