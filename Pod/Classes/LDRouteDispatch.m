//
//  LDRouteDispatch.m
//  Pods
//
//  Created by Vermillion on 20.02.15.
//
//

#import "LDRouteDispatch.h"
#import "LDRoute.h"

#define kDataKey        @"Data"
#define kDataFile       @"data.plist"

@interface LDRouteDispatch()

@property (strong, nonatomic) LDRoute* data;

@end

@implementation LDRouteDispatch

@synthesize docPath = _docPath;
@synthesize data = _data;

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithUpdatingInterval:(NSTimeInterval)interval andDesiredAccuracy:(CLLocationAccuracy)horizontalAccuracy {
    self = [super initWithUpdatingInterval:interval andDesiredAccuracy:horizontalAccuracy];
    if (self) {
        
    }
    return self;
}

- (void)setDocPath:(NSString *)docPath {
    internalDocPath = _docPath = docPath;
}

- (BOOL)createDataPath:(NSString*)fileName {
    
    if (internalDocPath == nil) {
        self.docPath = [LDRouteDispatch nextRouteDocPath:fileName];
    }
    
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:internalDocPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) {
        NSLog(@"Error creating data path: %@", [error localizedDescription]);
    }
    return success;
    
}

- (LDRoute *)loadRouteWithName:(NSString*)fileName {
    if (fileName) {
        if (internalDocPath == nil) {
            self.docPath = [LDRouteDispatch nextRouteDocPath:fileName];
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

- (LDRoute *)data {
    if (internalDocPath == nil) {
        self.docPath = [LDRouteDispatch nextRouteDocPath:nil];
    }
    NSString *dataPath = [internalDocPath stringByAppendingPathComponent:kDataFile];
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
    
    NSString *dataPath = [internalDocPath stringByAppendingPathComponent:fileName ? [NSString stringWithFormat:@"%@.plist", fileName] : kDataFile];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:_data forKey:kDataKey];
    [archiver finishEncoding];
    [data writeToFile:dataPath atomically:YES];
}

- (void)deleteDocWithName:(NSString*)name {
    NSError *error;
    if (internalDocPath == nil) {
        self.docPath = [LDRouteDispatch nextRouteDocPath:name ?: nil];
    }
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:internalDocPath error:&error];
    if (!success) {
        NSLog(@"Error removing document path: %@", error.localizedDescription);
    }
}

+ (NSString *)nextRouteDocPath:(NSString*)fileName {
    // Get private docs dir
    NSString *documentsDirectory = [LDRouteDispatch getStoredRoutesDir];
    
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

#pragma mark - LDLocationSeviceDelegates

- (void)addDelegate:(id<LDLocationServiceDelegate>)delegate {
    [super addDelegate:delegate];
}

- (void)removeDelegate:(id<LDLocationServiceDelegate>)delegate {
    [super removeDelegate:delegate];
}

@end
