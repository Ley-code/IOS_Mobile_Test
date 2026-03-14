import 'dart:convert';
import 'package:http/http.dart' as http;

/// Model for place search results
class PlaceResult {
  final String displayName;
  final String city;
  final String? state;
  final double? latitude;
  final double? longitude;

  PlaceResult({
    required this.displayName,
    required this.city,
    this.state,
    this.latitude,
    this.longitude,
  });
}

/// Service to handle place autocomplete using OpenStreetMap Nominatim API
/// 
/// Free API, no key required, but has rate limiting (1 request/second)
/// Uses debouncing in the widget to respect rate limits
class PlaceAutocompleteService {
  static final PlaceAutocompleteService _instance = PlaceAutocompleteService._internal();
  factory PlaceAutocompleteService() => _instance;
  PlaceAutocompleteService._internal();

  // Base URL for Nominatim API
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  /// Search for places matching the query
  /// Returns list of PlaceResult with city and state information
  /// Returns empty list if no results or error occurs
  Future<List<PlaceResult>> searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      // Build URL with query parameters
      final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: {
        'q': query,
        'format': 'json',
        'addressdetails': '1',
        'limit': '10',
        'countrycodes': 'us', // Focus on US cities for now
        'featuretype': 'city', // Focus on cities
      });

      // Make request with proper User-Agent (required by Nominatim)
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'VyrlApp/1.0 (mobile app)',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return _parseResults(data);
      } else {
        print('Nominatim API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }

  /// Parse Nominatim API response into PlaceResult objects
  List<PlaceResult> _parseResults(List<dynamic> data) {
    final List<PlaceResult> results = [];

    for (var item in data) {
      try {
        final address = item['address'] as Map<String, dynamic>?;
        if (address == null) continue;

        // Extract city name
        String city = address['city'] ?? 
                     address['town'] ?? 
                     address['village'] ?? 
                     address['municipality'] ?? 
                     '';

        if (city.isEmpty) continue;

        // Extract state
        String? state = address['state'];
        String? stateCode = address['state_code'];
        
        // Prefer state code (abbreviation) if available, otherwise use full state name
        String? finalState = stateCode?.toUpperCase() ?? state;

        // Extract coordinates
        double? lat;
        double? lon;
        if (item['lat'] != null && item['lon'] != null) {
          lat = double.tryParse(item['lat'].toString());
          lon = double.tryParse(item['lon'].toString());
        }

        // Build display name
        String displayName = city;
        if (finalState != null) {
          displayName = '$city, $finalState';
        }

        results.add(PlaceResult(
          displayName: displayName,
          city: city,
          state: finalState,
          latitude: lat,
          longitude: lon,
        ));
      } catch (e) {
        print('Error parsing place result: $e');
        continue;
      }
    }

    return results;
  }

  /// Search for places with a broader scope (not just cities)
  /// Useful for finding locations that might not be classified as cities
  Future<List<PlaceResult>> searchPlacesBroad(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: {
        'q': query,
        'format': 'json',
        'addressdetails': '1',
        'limit': '10',
        'countrycodes': 'us',
      });

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'VyrlApp/1.0 (mobile app)',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return _parseResults(data);
      } else {
        print('Nominatim API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error searching places: $e');
      return [];
    }
  }
}
