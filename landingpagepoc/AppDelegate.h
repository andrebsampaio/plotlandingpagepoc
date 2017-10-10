//
//  AppDelegate.h
//  landingpagepoc
//

#import <UIKit/UIKit.h>
#import <PlotProjects/Plot.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,PlotDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,retain) CLLocationManager *locationManager;



@end

