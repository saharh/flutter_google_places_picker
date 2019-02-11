#import "GooglePlacesPickerPlugin.h"
//@import GoogleMaps;
@import GooglePlaces;
@import GooglePlacePicker;


@implementation GooglePlacesPickerPlugin
FlutterResult _result;
UIViewController *vc;
//GMSPlacesClient *placesClient;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    vc = [UIApplication sharedApplication].delegate.window.rootViewController;
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"plugin_google_place_picker"
                                     binaryMessenger:[registrar messenger]];
    GooglePlacesPickerPlugin* instance = [[GooglePlacesPickerPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    _result = result;
    if ([@"init" isEqualToString:call.method]) {
        [self initializewithApiKey: call.arguments[@"apiKey"]];
    } else if ([@"showPlacePicker" isEqualToString:call.method]) {
        [self showPlacePicker];
    } else if ([@"showAutocomplete" isEqualToString:call.method]) {
        [self showAutocomplete:call.arguments[@"country"]];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

-(void)initializewithApiKey: (NSString *) apiKey {
//    [GMSPlacesClient provideAPIKey:apiKey]; // Not needed anymore, done in AppDelegate (otherwise doesn't work)
//    placesClient = [GMSPlacesClient sharedClient];
    _result(nil);
}

-(void)showPlacePicker {
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:nil];
    GMSPlacePickerViewController *placePicker = [[GMSPlacePickerViewController alloc] initWithConfig:config];
    placePicker.delegate = self;
    [vc presentViewController:placePicker animated:YES completion:nil];
}

-(void)showAutocomplete: (NSString *) country {
    GMSAutocompleteViewController *autocompleteController = [[GMSAutocompleteViewController alloc] init];
    autocompleteController.delegate = self;
    GMSPlaceField fields = (GMSPlaceFieldPlaceID | GMSPlaceFieldAddressComponents);
    autocompleteController.placeFields = fields;
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterAddress;
    if (country != nil && ![country isEqual:[NSNull null]]) {
        filter.country = country;
    }
    autocompleteController.autocompleteFilter = filter;
    UIViewController *vc = [UIApplication sharedApplication].delegate.window.rootViewController;
    [vc presentViewController:autocompleteController animated:YES completion:nil];
    
}

- (void)placePicker:(nonnull GMSPlacePickerViewController *)viewController didPickPlace:(nonnull GMSPlace *)place {
    [vc dismissViewControllerAnimated:YES completion:nil];
    NSDictionary *placeMap = @{
                               @"name" : place.name,
                               @"latitude" : [NSString stringWithFormat:@"%.7f", place.coordinate.latitude],
                               @"longitude" : [NSString stringWithFormat:@"%.7f", place.coordinate.longitude],
                               @"id" : place.placeID,
                               };
    NSMutableDictionary *mutablePlaceMap = placeMap.mutableCopy;
    if (place.formattedAddress != nil) {
        mutablePlaceMap[@"address"] = place.formattedAddress;
    }
    _result(mutablePlaceMap);
    
}

- (void)viewController:(nonnull GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(nonnull GMSPlace *)place {
    [vc dismissViewControllerAnimated:YES completion:nil];
    NSDictionary *placeMap = @{
//                               @"name" : place.name,
//                               @"latitude" : [NSString stringWithFormat:@"%.7f", place.coordinate.latitude],
//                               @"longitude" : [NSString stringWithFormat:@"%.7f", place.coordinate.longitude],
                               @"id" : place.placeID,
                               @"address_components": [self addressComponentsToArray:place.addressComponents]
                               };
//    NSMutableDictionary *mutablePlaceMap = placeMap.mutableCopy;
//    if (place.formattedAddress != nil) {
//        mutablePlaceMap[@"address"] = place.formattedAddress;
//    }
//    _result(mutablePlaceMap);
    _result(placeMap);
}

-(NSArray *)addressComponentsToArray: (NSArray *) array {
    NSMutableArray *newArr = [[NSMutableArray alloc] initWithCapacity:[array count]];
    for (GMSAddressComponent* obj in array) {
        [newArr addObject: @{@"short_name" : [obj shortName], @"long_name" : [obj name], @"types" : @[[obj type]]}];
    }
    return newArr;
}

- (void)viewController:(nonnull GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(nonnull NSError *)error {
    FlutterError *fError = [FlutterError errorWithCode:@"PLACE_AUTOCOMPLETE_ERROR" message:error.localizedDescription details:nil];
    [vc dismissViewControllerAnimated:YES completion:nil];
    _result(fError);
}

- (void)wasCancelled:(nonnull GMSAutocompleteViewController *)viewController {
    FlutterError *fError = [FlutterError errorWithCode:@"USER_CANCELED" message:@"User has canceled the operation." details:nil];
    [vc dismissViewControllerAnimated:YES completion:nil];
    _result(fError);
}

@end
