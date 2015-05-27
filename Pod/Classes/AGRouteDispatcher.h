//
//  AGRouteDispatch.h
//  Pods
//
//  Created by Vermillion on 20.02.15.
//
//

#import "AGLocationDispatcher.h"
#import "AGRoute.h"

@interface AGRouteDispatcher : AGLocationDispatcher {
    NSString *internalDocPath;
}

@property (strong, nonatomic) NSString *docPath;

- (instancetype)init;

- (instancetype)initWithUpdatingInterval:(NSTimeInterval)interval andDesiredAccuracy:(CLLocationAccuracy)horizontalAccuracy;

- (AGRoute *)loadRouteWithName:(NSString *)fileName;

- (void)saveRoute:(AGRoute *)route name:(NSString *)fileName;

- (void)deleteDocWithName:(NSString *)name;

- (void)setDocPath:(NSString *)docPath;

+ (NSString*)getStoredRoutesDir;

@end
