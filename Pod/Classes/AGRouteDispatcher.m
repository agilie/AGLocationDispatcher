//
//  AGRouteDispatch.m
//  Pods
//
//  Created by Vermillion on 20.02.15.
//
//

#define kDataKey        @"Data"
#define kDataFile       @"data.plist"

#import "AGRouteDispatcher.h"

@interface AGRouteDispatcher ()

@property (strong, nonatomic) AGRoute *data;

@end

@implementation AGRouteDispatcher

@synthesize docPath = _docPath;
@synthesize data = _data;

- (instancetype)init {
    self = [super init];
    if (self) {
        //default route init
    }
    return self;
}

- (instancetype)initWithUpdatingInterval:(NSTimeInterval)interval andDesiredAccuracy:(CLLocationAccuracy)horizontalAccuracy {
    self = [super initWithUpdatingInterval:interval andDesiredAccuracy:horizontalAccuracy];
    if (self) {
        //route init
    }
    return self;
}

- (void)setDocPath:(NSString *)docPath {
    internalDocPath = _docPath = docPath;
}

- (BOOL)createDataPath:(NSString *)fileName {

    if (internalDocPath == nil) {
        self.docPath = [AGRouteDispatcher nextRouteDocPath:fileName];
    }

    NSError *error;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:internalDocPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
        NSLog(@"Error creating data path: %@", [error localizedDescription]);
    }
    return success;

}

- (AGRoute *)loadRouteWithName:(NSString *)fileName {
    if (fileName) {
        if (internalDocPath == nil) {
            self.docPath = [AGRouteDispatcher nextRouteDocPath:fileName];
        }
        NSString *dataPath = [internalDocPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", fileName]];
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

- (AGRoute *)data {
    if (internalDocPath == nil) {
        self.docPath = [AGRouteDispatcher nextRouteDocPath:nil];
    }
    NSString *dataPath = [internalDocPath stringByAppendingPathComponent:kDataFile];
    NSData *codedData = [[NSData alloc] initWithContentsOfFile:dataPath];
    if (codedData == nil) return nil;

    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
    _data = [unarchiver decodeObjectForKey:kDataKey];
    [unarchiver finishDecoding];

    return _data;
}

- (void)saveRoute:(AGRoute *)route name:(NSString *)fileName {
    _data = route;
    if (_data == nil) return;

    [self createDataPath:fileName];

    NSString *dataPath = [internalDocPath stringByAppendingPathComponent:fileName ? [NSString stringWithFormat:@"%@.plist", fileName] : kDataFile];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:_data forKey:kDataKey];
    [archiver finishEncoding];
    [data writeToFile:dataPath atomically:YES];
}

- (void)deleteDocWithName:(NSString *)name {
    NSError *error;
    if (internalDocPath == nil) {
        self.docPath = [AGRouteDispatcher nextRouteDocPath:name ?: nil];
    }
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:internalDocPath error:&error];
    if (!success) {
        NSLog(@"Error removing document path: %@", error.localizedDescription);
    }
}

+ (NSString *)nextRouteDocPath:(NSString *)fileName {
    // Get private docs dir
    NSString *documentsDirectory = [AGRouteDispatcher getStoredRoutesDir];

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
            if ([file.pathExtension compare:@"AGRoute" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                NSString *fileName = [file stringByDeletingPathExtension];
                maxNumber = MAX(maxNumber, fileName.intValue);
            }
        }
    }

    // Get available name
    NSString *availableName = fileName ?: [NSString stringWithFormat:@"%d.route", maxNumber + 1];
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
