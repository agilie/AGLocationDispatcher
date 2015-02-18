//
//  LDRouteManager.h
//  LocationDispatch
//
//  Created by Vermillion on 13.02.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LDRoute.h"

@interface LDRouteManager : NSObject {
    NSString *_docPath;
}

@property (copy) NSString *docPath;

- (id)initWithDocPath:(NSString *)docPath;

- (LDRoute *)loadRouteWithName:(NSString*)fileName;

- (void)saveRoute:(LDRoute*)route name:(NSString*)fileName;

- (void)deleteDocWithName:(NSString*)name;

@end
