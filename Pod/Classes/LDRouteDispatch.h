//
//  LDRouteDispatch.h
//  Pods
//
//  Created by Vermillion on 20.02.15.
//
//

#import "LDLocationService.h"
#import "LDRoute.h"

@interface LDRouteDispatch : LDLocationService {
    NSString *internalDocPath;
}

@property (strong, nonatomic) NSString *docPath;

- (instancetype)init;
- (instancetype)initWithUpdatingInterval:(NSTimeInterval)interval andDesiredAccuracy:(CLLocationAccuracy)horizontalAccuracy;

- (LDRoute *)loadRouteWithName:(NSString*)fileName;

- (void)saveRoute:(LDRoute*)route name:(NSString*)fileName;

- (void)deleteDocWithName:(NSString*)name;

- (void)setDocPath:(NSString *)docPath;

- (void)addDelegate:(id <LDLocationServiceDelegate>)delegate;
- (void)removeDelegate:(id <LDLocationServiceDelegate>)delegate;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

@end
