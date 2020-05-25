import 'package:dog_pal/models/location_data.dart';
import 'package:dog_pal/utils/app_secrets.dart';
import 'package:dog_pal/utils/constants_util.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:permission_handler/permission_handler.dart';

//Google Places Api
//https://developers.google.com/maps/documentation/geocoding/intro

enum LocationType {
  city,
  town,
  district,
}

//Singleton
class LocationUtil {
  static final LocationUtil _instance = LocationUtil._internal();

  factory LocationUtil() {
    return _instance;
  }

  LocationUtil._internal() {
    _places = GoogleMapsPlaces(apiKey: PLACE_API_KEY);

    _geocoder = GoogleMapsGeocoding(apiKey: GEOCODE_API_KEY);
  }

  GoogleMapsPlaces _places;
  GoogleMapsGeocoding _geocoder;

  Future<bool> isLocationPermissionGranted() async {
    PermissionStatus status = await Permission.locationWhenInUse.status.timeout(
      Duration(seconds: 6),
      onTimeout: () => PermissionStatus.undetermined,
    );
    print(status.toString());
    return status == PermissionStatus.granted;
  }

  Future<List<Prediction>> completePlacesQuery(String input) async {
    PlacesAutocompleteResponse response =
        await _places.autocomplete(input, types: ['(cities)']);

    return response.predictions;
  }

  Future<Map<String, String>> getDetailsFromPrediction(
      Prediction prediction) async {
    PlacesDetailsResponse pdr = await _places.getDetailsByPlaceId(
      prediction.placeId,
      fields: [
        'geometry',
      ],
    ).timeout(
      Duration(seconds: 8),
      onTimeout: () => null,
    );

    if (pdr == null || !pdr.isOkay) {
      return null;
    }

    GeocodingResponse response = await _geocoder.searchByLocation(
      Location(
        pdr.result.geometry.location.lat,
        pdr.result.geometry.location.lng,
      ),
      resultType: [
        'administrative_area_level_3',
        'administrative_area_level_2',
        'administrative_area_level_1',
        'locality'
      ],
    ).timeout(
      Duration(seconds: 8),
      onTimeout: () => null,
    );

    if (response == null || !response.isOkay || response.results.isEmpty) {
      return null;
    }

    String town = getLocationName(
      LocationType.town,
      response.results,
    );

    String city = getLocationName(
      LocationType.city,
      response.results,
    );

    String district = getLocationName(
      LocationType.district,
      response.results,
    );

    return {
      UserConsts.TOWN: town,
      UserConsts.CITY: city,
      UserConsts.DISTRICT: district,
    };
  }

  String getLocationName(
    LocationType type,
    List<GeocodingResult> geocodingResults,
  ) {
    //https://developers.google.com/maps/documentation/geocoding/intro#Types

    AddressComponent component;

    for (GeocodingResult result in geocodingResults) {
      component = result.addressComponents.firstWhere(
        (comp) {
          if (type == LocationType.town) {
            return comp.types.contains('administrative_area_level_3') ||
                comp.types.contains('locality');
          } else if (type == LocationType.city) {
            return comp.types.contains('administrative_area_level_2');
          } else if (type == LocationType.district) {
            return comp.types.contains('administrative_area_level_1');
          } else {
            throw PlatformException(code: 'Unknown type of location');
          }
        },
        orElse: () => null,
      );

      if (component != null) break;
    }
    if (component != null && component.longName != null) {
      print('$type: ${component.longName}');
      return component.longName;
    } else {
      print('$type not available');
      return null;
    }
  }

  Future<Position> getLocation(LocationAccuracy accuracy) async {
    Position position = await Geolocator().getCurrentPosition(
      desiredAccuracy: accuracy,
      locationPermissionLevel: GeolocationPermission.locationWhenInUse,
    );

    return position;
  }

  //A convenience function to directly get the city and district
  Future<UserLocationData> getInfoFromPosition() async {
    Position position = await getLocation(
      LocationAccuracy.high,
    ).timeout(
      Duration(seconds: 10),
      onTimeout: () => null,
    );

    if (position == null) {
      return null;
    } else {
      GeocodingResponse response = await _geocoder
          .searchByLocation(
            Location(
              position.latitude,
              position.longitude,
            ),
          )
          .timeout(Duration(seconds: 8), onTimeout: () => null);

      if (response == null || !response.isOkay || response.results.isEmpty) {
        return null;
      }

      String town = getLocationName(
        LocationType.town,
        response.results,
      );

      String city = getLocationName(
        LocationType.city,
        response.results,
      );

      String district = getLocationName(
        LocationType.district,
        response.results,
      );

      if (town == null && city == null && district == null) {
        return null;
      } else {
        return UserLocationData(
          userCity: city,
          userDistrict: district,
          userTown: town,
          userDisplay: town ?? city ?? district,
        );
      }
    }
  }
}
