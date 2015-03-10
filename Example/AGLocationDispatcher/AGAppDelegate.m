//
//  AGAppDelegate.m
//  AGLocationDispatcher
//
//  Created by Vladimir Zgonik on 09.02.15.
//  Copyright (c) 2015 Agilie. All rights reserved.
//

#import "AGAppDelegate.h"
#import "AGMainDemoViewController.h"

#import "AGMainDemoViewController.h"

#import "AGDispatcherHeaders.h"

@interface AGAppDelegate ()

@property UIBackgroundTaskIdentifier backgroundTask;

@end

@implementation AGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    
    if ([launchOptions objectForKey: UIApplicationLaunchOptionsLocationKey]) {
        
       
        
        self.backgroundTask = [[UIApplication sharedApplication]
                               beginBackgroundTaskWithExpirationHandler:
                               ^{
                                   [[UIApplication sharedApplication] endBackgroundTask: self.backgroundTask];
                               }];
        
        UILocalNotification *notification = [[UILocalNotification alloc]init];
        [notification setAlertBody:@"YAPY IS NEW LOCATION BITCH"];
        [notification setFireDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        [notification setTimeZone:[NSTimeZone  defaultTimeZone]];
        [application setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
        
        [[UIApplication sharedApplication] endBackgroundTask: self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
        
    } else {
    
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[AGMainDemoViewController new]];
        self.window.rootViewController = navigationController;
        [self.window makeKeyAndVisible];
    
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSDictionary* userInfo = @{@"applicationWillBeTerminate": @(0)};
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"AGLocationDispatchDidChangeAppBackgroundMode"
     object: userInfo];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSDictionary* userInfo = @{@"applicationWillBeTerminate": @(0)};
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"AGLocationDispatchDidChangeAppBackgroundMode"
     object: userInfo];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    NSDictionary* userInfo = @{@"applicationWillBeTerminate": @(1)};
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"AGLocationDispatchDidChangeAppBackgroundMode"
     object: userInfo];
}

@end
