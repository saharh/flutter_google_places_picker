import 'dart:async';

import 'package:flutter/services.dart';
import 'package:google_maps_webservice/places.dart';

class Place {
  late double latitude;
  late double longitude;
  late String id;
  String? name;
  String? address;
  List<AddressComponent>? addressComponents;

  @override
  String toString() {
    return 'Place{latitude: $latitude, longitude: $longitude, id: $id, name: $name, address: $address, addressComponents: ${addressComponents?.map((e) => e.description())}}';
  }
}

extension AddressComponentToString on AddressComponent {
  String description() {
    return 'AddressComponent{types: $types, longName: $longName, shortName: $shortName}';
  }
}

enum PlaceAutocompleteMode { MODE_OVERLAY, MODE_FULLSCREEN }

enum TypeFilter { ADDRESS, CITIES, ESTABLISHMENT, GEOCODE, REGIONS }

class LocationBias {
  double northEastLat = 90.0;
  double northEastLng = 180.0;
  double southWestLat = 0.0;
  double southWestLng = 0.0;

  LocationBias({
    required this.northEastLat,
    required this.northEastLng,
    required this.southWestLat,
    required this.southWestLng,
  });

  @override
  String toString() {
    return 'LocationBias{northEastLat: $northEastLat, northEastLng: $northEastLng, southWestLat: $southWestLat, southWestLng: $southWestLng}';
  }
}

class LocationRestriction {
  double northEastLat = 90.0;
  double northEastLng = 180.0;
  double southWestLat = 0.0;
  double southWestLng = 0.0;

  LocationRestriction({
    required this.northEastLat,
    required this.northEastLng,
    required this.southWestLat,
    required this.southWestLng,
  });

  @override
  String toString() {
    return 'LocationRestriction{northEastLat: $northEastLat, northEastLng: $northEastLng, southWestLat: $southWestLat, southWestLng: $southWestLng}';
  }
}

class PluginGooglePlacePicker {
  static const MethodChannel _channel = const MethodChannel('plugin_google_place_picker');

  static Future<Place> showAutocomplete({
    required PlaceAutocompleteMode mode,
    LocationBias? bias,
    LocationRestriction? restriction,
    TypeFilter? typeFilter,
    String? countryCode,
  }) async {
    var argMap = {
      "mode": mode == PlaceAutocompleteMode.MODE_OVERLAY ? 71 : 72,
      "bias": _convertLocationBiasToMap(bias),
      "restriction": _convertLocationRestrictionToMap(restriction),
      "type": _convertFilterTypeToString(typeFilter),
      "country": countryCode
    };
    final Map placeMap = await (_channel.invokeMethod('showAutocomplete', argMap));
    return _initPlaceFromMap(placeMap);
  }

  static Future<void> initialize({String? androidApiKey, String? iosApiKey}) async {
    await _channel.invokeMethod('initialize', {"androidApiKey": androidApiKey, "iosApiKey": iosApiKey});
  }

  static Place _initPlaceFromMap(Map placeMap) {
    var place = Place()
      ..name = placeMap["name"]
      ..address = placeMap["address"]
      ..latitude = placeMap["latitude"] is double ? placeMap["latitude"] : null
      ..longitude = placeMap["longitude"] is double ? placeMap["longitude"] : null
      ..id = placeMap["id"];

    var addressComp = placeMap["address_components"];
    if (addressComp is List) {
      place.addressComponents = addressComp
          .map((ac) => AddressComponent.fromJson(Map<String, Object?>.from(ac)))
          .where((ac) => ac != null)
          .toList();
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

  static String? _convertFilterTypeToString(TypeFilter? type) {
    if (type == null) {
      return null;
    }
    switch (type) {
      case TypeFilter.ADDRESS:
        return "address";
      case TypeFilter.CITIES:
        return "cities";
      case TypeFilter.ESTABLISHMENT:
        return "establishment";
      case TypeFilter.GEOCODE:
        return "geocode";
      case TypeFilter.REGIONS:
        return "regions";
    }
  }

  static Map<String, double>? _convertLocationBiasToMap(LocationBias? bias) {
    if (bias == null) {
      return null;
    }
    return {
      "southWestLat": bias.southWestLat,
      "southWestLng": bias.southWestLng,
      "northEastLat": bias.northEastLat,
      "northEastLng": bias.northEastLng
    };
  }

  static Map<String, double>? _convertLocationRestrictionToMap(LocationRestriction? restriction) {
    if (restriction == null) {
      return null;
    }
    return {
      "southWestLat": restriction.southWestLat,
      "southWestLng": restriction.southWestLng,
      "northEastLat": restriction.northEastLat,
      "northEastLng": restriction.northEastLng
    };
  }
}
