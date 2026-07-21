import 'dart:html';
import 'dart:convert';

class AppsScriptService {
  static final AppsScriptService _instance = AppsScriptService._internal();
  String mapUrl = 'https://script.google.com/macros/s/AKfycbyca4Xz_AE6Om1okIMf0TQ9EE9uIifQcVZhsDwnZK0K4weG7VD0w3jEzM0aCcuBeoWIIA/exec';

  AppsScriptService._internal();

  factory AppsScriptService() {
    return _instance;
  }

  void setMapUrl(String url) {
    mapUrl = url;
  }

  Future<Map<String, dynamic>> _callAction(String action, {Map<String, dynamic>? params}) async {
    final payload = {
      'action': action,
      'params': params ?? {},
    };

    final request = HttpRequest();
    request.open('POST', mapUrl);
    // Use text/plain for GAS to avoid CORS preflight (OPTIONS) which GAS doesn't support
    request.setRequestHeader('Content-Type', 'text/plain;charset=utf-8');
    request.send(json.encode(payload));

    await request.onLoadEnd.first;

    if (request.status != 200 && request.status != 201) {
      throw Exception('Apps Script error! status: ${request.status}');
    }

    return json.decode(request.responseText ?? '{}') as Map<String, dynamic>;
  }

  Future<List<String>> getPlaceSuggestions(String inputToken) async {
    try {
      final res = await _callAction('getPlaceSuggestions', params: {'inputToken': inputToken});
      if (res['success'] == true) {
        final suggestions = res['suggestions'] as List<dynamic>? ?? [];
        return suggestions.map((s) => s.toString()).toList();
      }
    } catch (e) {
      print("Failed getting place suggestions: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>> processLocationAndMetrics(double originLat, double originLng, String destinationQuery) {
    return _callAction('processLocationAndMetrics', params: {
      'originLat': originLat,
      'originLng': originLng,
      'destinationQuery': destinationQuery,
    });
  }

  Future<Map<String, dynamic>> processPinDropMetrics(double originLat, double originLng, double pinLat, double pinLng) {
    return _callAction('processPinDropMetrics', params: {
      'originLat': originLat,
      'originLng': originLng,
      'pinLat': pinLat,
      'pinLng': pinLng,
    });
  }
}
