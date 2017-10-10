//
//  AppDelegate.m
//  landingpagepoc
//

#import "AppDelegate.h"
#import <MapKit/MapKit.h>


@interface AppDelegate ()

@end

@implementation AppDelegate
    
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initLocationManager];
    //initializes the Plot library:
    [Plot initializeWithLaunchOptions:launchOptions delegate:self];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:5.0f]; // Wait until some geotriggers are loaded
        [self checkForLandingPage];
    });
    return YES;
}
    
-(void) initLocationManager{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)checkForLandingPage{
    NSArray<PlotGeotrigger *> *geotriggers = [Plot loadedGeotriggers];
    PlotGeotrigger* closestGeotrigger = nil;
    double closestDistance = DBL_MAX;
    for (PlotGeotrigger* geotrigger in geotriggers){
        double lat = [[[geotrigger userInfo]objectForKey:PlotGeotriggerGeofenceLatitude] doubleValue];
        double lon = [[[geotrigger userInfo]objectForKey:PlotGeotriggerGeofenceLongitude] doubleValue];
        CLLocation *startLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:self.locationManager.location.coordinate.latitude
                                                             longitude:self.locationManager.location.coordinate.longitude];
        CLLocationDistance distance = [startLocation distanceFromLocation:endLocation];
        if (distance < [[[geotrigger userInfo]objectForKey:PlotGeotriggerMatchRange] doubleValue]){
            if (closestDistance > distance){
                closestGeotrigger = geotrigger;
            }
        }
    }
    if (closestGeotrigger){
        NSURL *url = [NSURL URLWithString:[[closestGeotrigger userInfo]objectForKey:PlotGeotriggerDataKey]];
        UIApplication *application = [UIApplication sharedApplication];
        [application openURL:url options:@{} completionHandler:nil];
    }
}
    
- (void)applicationWillEnterForeground:(UIApplication *)application {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self checkForLandingPage];
    });
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
