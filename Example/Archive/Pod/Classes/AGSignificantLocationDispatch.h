//
//  LDSignificantLocationDispatch.h
//  Pods
//
//  Created by Ankudinov Alexander on 3/6/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AGDispatcherHeaders.h"
#import <CoreLocation/CoreLocation.h>

@interface AGSignificantLocationDispatch : NSObject<CLLocationManagerDelegate>

typedef void(^LDSignificationLocationASynchronousEndUpdateBlock)();
typedef void(^LDSignificationLocationASynchronousUpdateBlock)(AGLocation *newLocation , LDSignificationLocationASynchronousEndUpdateBlock updateCompletionBlock);

@end
