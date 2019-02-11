import 'dart:async';

import 'package:flutter/services.dart';

class Place {
  double latitude;
  double longitude;
  String id;
  String name;
  String address;
  List<AddressComponent> addressComponents;
}

class AddressComponent {
  final List<String> types;

  /// JSON long_name
  final String longName;

  /// JSON short_name
  final String shortName;

  AddressComponent(
      this.types,
      this.longName,
      this.shortName,
      );

  factory AddressComponent.fromJson(Map json) => json != null
      ? new AddressComponent((json["types"] as List)?.cast<String>(),
      json["long_name"], json["short_name"])
      : null;
}

enum PlaceAutocompleteMode { MODE_OVERLAY, MODE_FULLSCREEN }

class PluginGooglePlacePicker {
  static const MethodChannel _channel = const MethodChannel('plugin_google_place_picker');

  static Future<void> init(String apiKey) async {
    await _channel.invokeMethod('init', {"apiKey": apiKey});
  }

//  static Future<Place> fetchPlace(String placeId) async {
//    final Map placeMap = await _channel.invokeMethod('fetchPlace', {'id': placeId});
//    return _initPlaceFromMap(placeMap);
//  }

  static Future<Place> showPlacePicker() async {
    final Map placeMap = await _channel.invokeMethod('showPlacePicker');
    return _initPlaceFromMap(placeMap);
  }

  static Future<Place> showAutocomplete(PlaceAutocompleteMode mode, {String country}) async {
    var argMap = new Map();
//    Random values
    argMap["mode"] = mode == PlaceAutocompleteMode.MODE_OVERLAY ? 71 : 72;
    argMap["country"] = country;
    final Map placeMap = await _channel.invokeMethod('showAutocomplete', argMap);
    return _initPlaceFromMap(placeMap);
  }

  static Place _initPlaceFromMap(Map placeMap) {
    var place = Place()..id = placeMap["id"];
    var addressComp = placeMap["address_components"];
    if (addressComp is List) {
      place.addressComponents = addressComp.map((ac) => AddressComponent.fromJson(ac)).where((ac) => ac != null).toList();
    }
    return place;
//    if (placeMap["latitude"] is double) {
//      return new Place()
//        ..name = placeMap["name"]
//        ..id = placeMap["id"]
//        ..address = placeMap["address"]
//        ..latitude = placeMap["latitude"]
//        ..longitude = placeMap["longitude"];
//    } else {
//      return new Place()
//        ..name = placeMap["name"]
//        ..id = placeMap["id"]
//        ..address = placeMap["address"]
//        ..latitude = double.parse(placeMap["latitude"])
//        ..longitude = double.parse(placeMap["longitude"]);
//    }
  }
}
