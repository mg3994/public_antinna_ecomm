import 'dart:html';
import 'dart:convert';
import 'dart:js' as js;

class ProductionApiService {
  static final ProductionApiService _instance = ProductionApiService._internal();
  final String baseUrl = 'https://api.antinna.in';

  ProductionApiService._internal();

  factory ProductionApiService() {
    return _instance;
  }

  Future<Map<String, dynamic>> _request(String method, String path, {Map<String, dynamic>? body}) async {
    // Dynamically fetch authorization headers from global JS variables
    final firebaseAuthToken = js.context['firebaseAuthToken']?.toString() ?? '';
    final antinnaClientId = window.localStorage['antinna_client_id'] ?? '';

    final headers = {
      'Content-Type': 'application/json',
      'X-Antinna-Client-Id': antinnaClientId,
      if (firebaseAuthToken.isNotEmpty) 'Authorization': 'Bearer $firebaseAuthToken',
    };

    final request = HttpRequest();
    request.open(method, '$baseUrl$path');
    headers.forEach((key, val) {
      request.setRequestHeader(key, val);
    });

    final payload = body != null ? json.encode(body) : null;
    request.send(payload);

    await request.onLoadEnd.first;

    if (request.status != 200 && request.status != 201) {
      throw Exception('API error! status: ${request.status}');
    }

    return json.decode(request.responseText ?? '{}') as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> order) {
    return _request('POST', '/orders', body: order);
  }

  Future<Map<String, dynamic>> recordPayment(Map<String, dynamic> paymentData) {
    return _request('POST', '/payments', body: paymentData);
  }

  Future<Map<String, dynamic>> isOrderPaid(String orderId) {
    return _request('GET', '/orders/$orderId/status');
  }

  Future<Map<String, dynamic>> listNotifications({int page = 1, int pageSize = 20}) {
    return _request('GET', '/notifications?page=$page&pageSize=$pageSize');
  }
}
