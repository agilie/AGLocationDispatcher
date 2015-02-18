//
//  LDRouteManager.m
//  LocationDispatch
//
//  Created by Vermillion on 13.02.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "LDRouteManager.h"
#import "LDRoute.h"

@interface LDRouteManager()

@property (strong, nonatomic) LDRoute* data;

@end

#define kDataKey        @"Data"
#define kDataFile       @"data.plist"

@implementation LDRouteManager

@synthesize docPath = _docPath;
@synthesize data = _data;

- (instancetype)initWithDocPath:(NSString *)docPath {
    if ((self = [super init])) {
        _docPath = [docPath copy];
    }
    return self;
}

- (BOOL)createDataPath:(NSString*)fileName {
    
    if (_docPath == nil) {
        self.docPath = [LDRouteManager nextRouteDocPath:fileName];
    }
    
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:_docPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
        NSLog(@"Error creating data path: %@", [error localizedDescription]);
    }
    return success;
    
}

- (LDRoute *)loadRouteWithName:(NSString*)fileName {
    if (fileName) {
        if (_docPath == nil) {
            self.docPath = [LDRouteManager nextRouteDocPath:fileName];
        }
        NSString *dataPath = [_docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", fileName]];
        NSData *codedData = [[NSData alloc] initWithContentsOfFile:dataPath];
        if (codedData == nil) return nil;
        
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
        _data = [unarchiver decodeObjectForKey:kDataKey];
        [unarchiver finishDecoding];
        
        return _data;
    } else {
        return [self data];
    }
}

- (LDRoute *)data {
    if (_docPath == nil) {
        self.docPath = [LDRouteManager nextRouteDocPath:nil];
    }
    NSString *dataPath = [_docPath stringByAppendingPathComponent:kDataFile];
    NSData *codedData = [[NSData alloc] initWithContentsOfFile:dataPath];
    if (codedData == nil) return nil;
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
    _data = [unarchiver decodeObjectForKey:kDataKey];
    [unarchiver finishDecoding];
    
    return _data;
}

- (void)saveRoute:(LDRoute*)route name:(NSString*)fileName{
    _data = route;
    if (_data == nil) return;
    
    [self createDataPath:fileName];
    
    NSString *dataPath = [_docPath stringByAppendingPathComponent:fileName ? [NSString stringWithFormat:@"%@.plist", fileName] : kDataFile];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:_data forKey:kDataKey];
    [archiver finishEncoding];
    [data writeToFile:dataPath atomically:YES];
}

- (void)deleteDocWithName:(NSString*)name {
    NSError *error;
    if (_docPath == nil) {
        self.docPath = [LDRouteManager nextRouteDocPath:name ?: nil];
    }
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:_docPath error:&error];
    if (!success) {
        NSLog(@"Error removing document path: %@", error.localizedDescription);
    }
}

+ (NSString *)nextRouteDocPath:(NSString*)fileName {
    // Get private docs dir
    NSString *documentsDirectory = [LDRouteManager getStoredRoutesDir];
    
    int maxNumber = 0;
    if (!fileName) {
        // Get contents of documents directory
        NSError *error;
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
        if (files == nil) {
            NSLog(@"Error reading contents of documents directory: %@", [error localizedDescription]);
            return nil;
        }
        
        // Search for an available name
        for (NSString *file in files) {
            if ([file.pathExtension compare:@"LDRoute" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                NSString *fileName = [file stringByDeletingPathExtension];
                maxNumber = MAX(maxNumber, fileName.intValue);
            }
        }
    }
    
    // Get available name
    NSString *availableName = fileName ?: [NSString stringWithFormat:@"%d.route", maxNumber+1];
    return [documentsDirectory stringByAppendingPathComponent:availableName];
}

+ (NSString *)getStoredRoutesDir {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *routesDirectory = [paths objectAtIndex:0];
    routesDirectory = [routesDirectory stringByAppendingPathComponent:@"StoredRoutes"];
    
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:routesDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    
    return routesDirectory;
}

@end
