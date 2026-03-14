import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Service to handle GPS location detection and reverse geocoding
///
/// Provides methods to:
/// - Get current device location
/// - Convert coordinates to city and state
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Get current device location
  /// Returns Position with latitude and longitude
  /// Throws exception if permission denied or location unavailable
  Future<Position> getCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled. Please enable location services.',
      );
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Please enable them in app settings.',
      );
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Reverse geocode coordinates to get city and state
  /// Returns a map with 'city' and 'state' keys
  /// Returns null if geocoding fails
  Future<Map<String, String>?> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        return null;
      }

      Placemark place = placemarks[0];

      // Extract city and state
      String? city =
          place.locality ??
          place.subAdministrativeArea ??
          place.administrativeArea;
      String? state = place.administrativeArea;

      // For US states, try to get abbreviation from subAdministrativeArea or use full name
      String? stateAbbrev = place.isoCountryCode == 'US'
          ? _getStateAbbreviation(state ?? '')
          : state;

      if (city == null && state == null) {
        return null;
      }

      return {'city': city ?? '', 'state': stateAbbrev ?? state ?? ''};
    } catch (e) {
      print('Error reverse geocoding: $e');
      return null;
    }
  }

  /// Get city and state from current location
  /// Combines getCurrentLocation and reverseGeocode
  Future<Map<String, String>?> getCurrentCityAndState() async {
    try {
      Position position = await getCurrentLocation();
      return await reverseGeocode(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting current city and state: $e');
      rethrow;
    }
  }

  /// Convert US state name to abbreviation
  /// Returns abbreviation if found, otherwise returns original string
  String? _getStateAbbreviation(String stateName) {
    const Map<String, String> stateAbbreviations = {
      'Alabama': 'AL',
      'Alaska': 'AK',
      'Arizona': 'AZ',
      'Arkansas': 'AR',
      'California': 'CA',
      'Colorado': 'CO',
      'Connecticut': 'CT',
      'Delaware': 'DE',
      'Florida': 'FL',
      'Georgia': 'GA',
      'Hawaii': 'HI',
      'Idaho': 'ID',
      'Illinois': 'IL',
      'Indiana': 'IN',
      'Iowa': 'IA',
      'Kansas': 'KS',
      'Kentucky': 'KY',
      'Louisiana': 'LA',
      'Maine': 'ME',
      'Maryland': 'MD',
      'Massachusetts': 'MA',
      'Michigan': 'MI',
      'Minnesota': 'MN',
      'Mississippi': 'MS',
      'Missouri': 'MO',
      'Montana': 'MT',
      'Nebraska': 'NE',
      'Nevada': 'NV',
      'New Hampshire': 'NH',
      'New Jersey': 'NJ',
      'New Mexico': 'NM',
      'New York': 'NY',
      'North Carolina': 'NC',
      'North Dakota': 'ND',
      'Ohio': 'OH',
      'Oklahoma': 'OK',
      'Oregon': 'OR',
      'Pennsylvania': 'PA',
      'Rhode Island': 'RI',
      'South Carolina': 'SC',
      'South Dakota': 'SD',
      'Tennessee': 'TN',
      'Texas': 'TX',
      'Utah': 'UT',
      'Vermont': 'VT',
      'Virginia': 'VA',
      'Washington': 'WA',
      'West Virginia': 'WV',
      'Wisconsin': 'WI',
      'Wyoming': 'WY',
      'District of Columbia': 'DC',
    };

    // Check if it's already an abbreviation (2 letters)
    if (stateName.length == 2) {
      return stateName.toUpperCase();
    }

    // Look up full name
    return stateAbbreviations[stateName] ?? stateName;
  }
}
