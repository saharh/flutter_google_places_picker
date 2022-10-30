#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
@import GooglePlaces;
//@import GoogleMaps;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
    NSString *googlePlacesApiKey = @"YOUR_IOS_RESTRICTED_API_KEY";
    [GMSPlacesClient provideAPIKey:googlePlacesApiKey];
//    [GMSServices provideAPIKey:googlePlacesApiKey];

  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
