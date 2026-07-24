import 'dart:html';
import 'dart:convert';
import 'dart:js' as js;
import 'production_api_service.dart';

class GooglePayService {
  static final GooglePayService _instance = GooglePayService._internal();
  final String merchantId = 'BCR2DN5TVPLKL4KZ';
  final String merchantName = 'Antinna';

  GooglePayService._internal();

  factory GooglePayService() {
    return _instance;
  }

  Future<void> initPayment(Map<String, dynamic> order, {Map<String, dynamic>? verifiedLocation}) async {
    if (js.context['PaymentRequest'] == null) {
      window.alert('Payment Request API not supported in this browser.');
      return;
    }

    // Call backend to create order record asynchronously
    try {
      final api = ProductionApiService();
      final recordMap = {...order};
      if (verifiedLocation != null) {
        recordMap['verifiedLocation'] = verifiedLocation;
      }
      await api.createOrder(recordMap);
    } catch (e) {
      print("Failed to record order in backend: $e");
    }

    final currency = order['priceCurrency']?.toString() ?? 'INR';

    // Google Pay India (UPI) supported methods
    final googlePayUPI = {
      'supportedMethods': 'https://tez.google.com/pay',
      'data': {
        'pa': 'manishsharma3994@okhdfcbank',
        'pn': merchantName,
        'tr': 'TR${DateTime.now().millisecondsSinceEpoch}',
        'url': window.location.href,
        'mc': '5251',
        'tn': 'Order from $merchantName',
      },
    };

    // Standard Google Pay (Card) supported methods for Desktop/Global
    final googlePayGlobal = {
      'supportedMethods': 'https://google.com/pay',
      'data': {
        'environment': 'PRODUCTION',
        'apiVersion': 2,
        'apiVersionMinor': 0,
        'merchantInfo': {
          'merchantId': merchantId,
          'merchantName': merchantName,
        },
        'allowedPaymentMethods': [
          {
            'type': 'CARD',
            'parameters': {
              'allowedAuthMethods': ['PAN_ONLY', 'CRYPTOGRAM_3DS'],
              'allowedCardNetworks': ['MASTERCARD', 'VISA'],
            },
            'tokenizationSpecification': {
              'type': 'PAYMENT_GATEWAY',
              'parameters': {
                'gateway': 'example',
                'gatewayMerchantId': 'exampleGatewayMerchantId',
              },
            },
          },
        ],
      },
    };

    final supportedInstruments = [
      js.JsObject.jsify(googlePayUPI),
      js.JsObject.jsify(googlePayGlobal),
    ];

    final displayItems = <dynamic>[];
    final orderedItems = order['orderedItem'] is List ? (order['orderedItem'] as List) : [];

    for (var item in orderedItems) {
      if (item is Map<String, dynamic>) {
        final orderedObj = item['orderedItem'] as Map<String, dynamic>? ?? {};
        final name = orderedObj['name']?.toString() ?? '';
        final qty = int.tryParse(item['orderQuantity']?.toString() ?? '1') ?? 1;
        final offers = orderedObj['offers'] as Map<String, dynamic>? ?? {};
        final price = double.tryParse(offers['price']?.toString() ?? '0.0') ?? 0.0;

        displayItems.add({
          'label': '$name (x$qty)',
          'amount': {
            'currency': currency,
            'value': (price * qty).toStringAsFixed(2),
          },
        });

        final addOns = item['addOns'] is List ? (item['addOns'] as List) : [];
        for (var addon in addOns) {
          if (addon is Map<String, dynamic>) {
            final addonOrdered = addon['orderedItem'] as Map<String, dynamic>? ?? {};
            final aName = addonOrdered['name']?.toString() ?? '';
            final aQty = int.tryParse(addon['orderQuantity']?.toString() ?? '1') ?? 1;
            final aOffers = addonOrdered['offers'] as Map<String, dynamic>? ?? {};
            final aPrice = double.tryParse(aOffers['price']?.toString() ?? '0.0') ?? 0.0;

            displayItems.add({
              'label': '  + $aName (x$aQty)',
              'amount': {
                'currency': currency,
                'value': (aPrice * aQty).toStringAsFixed(2),
              },
            });
          }
        }
      }
    }

    if (verifiedLocation != null) {
      displayItems.add({
        'label': 'Delivery: ${verifiedLocation['address'] ?? 'Verified Location'}',
        'amount': {
          'currency': currency,
          'value': '0.00',
        },
      });
    }

    final totalPrice = double.tryParse(order['totalPrice']?.toString() ?? '0.0') ?? 0.0;

    final details = {
      'total': {
        'label': 'Total Amount',
        'amount': {
          'currency': currency,
          'value': totalPrice.toStringAsFixed(2),
        },
      },
      'displayItems': displayItems,
    };

    try {
      final request = js.JsObject(js.context['PaymentRequest'] as js.JsFunction, [
        js.JsObject.jsify(supportedInstruments),
        js.JsObject.jsify(details),
      ]);

      await request.callMethod('canMakePayment');
      final response = await request.callMethod('show');
      print('Payment response: $response');
    } catch (e) {
      print("Payment Error: $e");
    }
  }
}
