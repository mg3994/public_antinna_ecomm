import 'dart:html';
import 'dart:convert';

class LocationData {
  double? lat;
  double? lon;
  String? pin;
  String? city;

  LocationData({this.lat, this.lon, this.pin, this.city});

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lon': lon,
        'pin': pin,
        'city': city,
      };

  static LocationData fromJson(Map<String, dynamic> json) => LocationData(
        lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
        lon: json['lon'] != null ? double.tryParse(json['lon'].toString()) : null,
        pin: json['pin']?.toString(),
        city: json['city']?.toString(),
      );
}

class LocationManager {
  LocationData data = LocationData();
  final String storageKey = 'antinna_location';

  LocationManager() {
    loadFromStorage();
  }

  void loadFromStorage() {
    final saved = window.localStorage[storageKey];
    if (saved != null && saved.isNotEmpty) {
      try {
        final parsed = json.decode(saved) as Map<String, dynamic>;
        data = LocationData.fromJson(parsed);
      } catch (_) {}
    }
  }

  void save() {
    window.localStorage[storageKey] = json.encode(data.toJson());
  }

  void setData({double? lat, double? lon, String? pin, String? city}) {
    if (lat != null) data.lat = lat;
    if (lon != null) data.lon = lon;
    if (pin != null) data.pin = pin;
    if (city != null) data.city = city;
    save();
  }

  void clear() {
    data = LocationData();
    window.localStorage.remove(storageKey);
  }

  Future<Map<String, dynamic>> reverseGeocode(double lat, double lon) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json';
      final response = await HttpRequest.getString(url);
      final d = json.decode(response) as Map<String, dynamic>;
      final address = d['address'] as Map<String, dynamic>?;
      if (address != null) {
        return {
          'pin': address['postcode']?.toString() ?? data.pin,
          'city': address['city']?.toString() ?? address['town']?.toString() ?? address['village']?.toString() ?? address['state_district']?.toString(),
        };
      }
    } catch (e) {
      print("Geocoding failed: $e");
    }
    return {};
  }

  Future<Map<String, dynamic>> lookupPin(String pin) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/search?postalcode=$pin&country=India&format=json&addressdetails=1';
      final response = await HttpRequest.getString(url);
      final list = json.decode(response) as List<dynamic>;
      if (list.isNotEmpty) {
        final d = list.first as Map<String, dynamic>;
        final address = d['address'] as Map<String, dynamic>?;
        final latVal = double.tryParse(d['lat']?.toString() ?? '');
        final lonVal = double.tryParse(d['lon']?.toString() ?? '');
        var cityVal = '';
        if (address != null) {
          cityVal = address['city']?.toString() ?? address['town']?.toString() ?? address['village']?.toString() ?? address['state_district']?.toString() ?? address['county']?.toString() ?? '';
        }
        return {
          'lat': latVal,
          'lon': lonVal,
          'city': cityVal,
        };
      }
    } catch (e) {
      print("PIN lookup failed: $e");
    }
    return {'city': null, 'lat': null, 'lon': null};
  }
}
