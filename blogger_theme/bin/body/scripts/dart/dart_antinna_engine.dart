import 'dart:html';
import 'dart:convert';
import 'dart:js' as js;
import 'core/state.dart';
import 'core/parser.dart';
import 'core/schema_resolver.dart';
import 'core/location_manager.dart';
import 'core/cart_manager.dart';
import 'infrastructure/production_api_service.dart';
import 'infrastructure/apps_script_service.dart';
import 'infrastructure/blogger_data_service.dart';
import 'infrastructure/google_pay_service.dart';
import 'presentation/grid_renderer.dart';
import 'presentation/carousel_renderer.dart';
import 'presentation/product_renderer.dart';
import 'presentation/service_renderer.dart';
import 'presentation/phone_verification_renderer.dart';

void main() {
  // Instantiate core managers and services
  final loc = LocationManager();
  final cart = CartManager();
  final api = ProductionApiService();
  final gas = AppsScriptService();
  final blogger = BloggerDataService();
  final gpay = GooglePayService();
  final phoneVerify = PhoneVerificationRenderer();

  // Expose LocationManager with a highly compatible JS-wrapper
  final jsLoc = js.JsObject.jsify({
    'getData': js.allowInterop(() {
      return js.JsObject.jsify({
        'lat': loc.data.lat,
        'lon': loc.data.lon,
        'pin': loc.data.pin,
        'city': loc.data.city,
      });
    }),
    'setData': js.allowInterop((js.JsObject partial) {
      loc.setData(
        lat: partial['lat'] != null ? double.tryParse(partial['lat'].toString()) : null,
        lon: partial['lon'] != null ? double.tryParse(partial['lon'].toString()) : null,
        pin: partial['pin']?.toString(),
        city: partial['city']?.toString(),
      );
    }),
    'clear': js.allowInterop(loc.clear),
  });
  js.context['LocationManager'] = jsLoc;

  // Expose CartManager with a highly compatible JS-wrapper
  final jsCart = js.JsObject.jsify({
    'getOrder': js.allowInterop(() {
      return js.JsObject.jsify(cart.order);
    }),
    'addItem': js.allowInterop((js.JsObject item, [js.JsObject? seller, js.JsObject? variants, int? quantity]) {
      final itemJson = js.context['JSON'].callMethod('stringify', [item]) as String;
      final itemMap = json.decode(itemJson) as Map<String, dynamic>;

      Map<String, dynamic>? sellerMap;
      if (seller != null) {
        final sellerJson = js.context['JSON'].callMethod('stringify', [seller]) as String;
        sellerMap = json.decode(sellerJson) as Map<String, dynamic>;
      }

      Map<String, dynamic>? variantsMap;
      if (variants != null) {
        final variantsJson = js.context['JSON'].callMethod('stringify', [variants]) as String;
        variantsMap = json.decode(variantsJson) as Map<String, dynamic>;
      }

      return cart.addItem(
        itemMap,
        seller: sellerMap,
        selectedVariants: variantsMap,
        quantity: quantity ?? 1,
      );
    }),
    'removeItem': js.allowInterop(cart.removeItem),
    'updateQty': js.allowInterop(cart.updateQty),
    'clear': js.allowInterop(cart.clear),
  });
  js.context['CartManager'] = jsCart;

  // Expose ProductionApiService with highly compatible JS-wrapper
  final jsApi = js.JsObject.jsify({
    'createOrder': js.allowInterop((js.JsObject order) async {
      final orderJson = js.context['JSON'].callMethod('stringify', [order]) as String;
      final orderMap = json.decode(orderJson) as Map<String, dynamic>;
      final result = await api.createOrder(orderMap);
      return js.JsObject.jsify(result);
    }),
    'recordPayment': js.allowInterop((js.JsObject paymentData) async {
      final paymentJson = js.context['JSON'].callMethod('stringify', [paymentData]) as String;
      final paymentMap = json.decode(paymentJson) as Map<String, dynamic>;
      final result = await api.recordPayment(paymentMap);
      return js.JsObject.jsify(result);
    }),
    'isOrderPaid': js.allowInterop((String orderId) async {
      final result = await api.isOrderPaid(orderId);
      return js.JsObject.jsify(result);
    }),
  });
  js.context['ProductionApiService'] = jsApi;

  // Expose AppsScriptService with highly compatible JS-wrapper
  final jsGas = js.JsObject.jsify({
    'setMapUrl': js.allowInterop(gas.setMapUrl),
    'getPlaceSuggestions': js.allowInterop((String token) async {
      final result = await gas.getPlaceSuggestions(token);
      return js.JsObject.jsify(result);
    }),
    'processLocationAndMetrics': js.allowInterop((double originLat, double originLng, String destination) async {
      final result = await gas.processLocationAndMetrics(originLat, originLng, destination);
      return js.JsObject.jsify(result);
    }),
  });
  js.context['AppsScriptService'] = jsGas;

  // Expose BloggerDataService with highly compatible JS-wrapper
  final jsBlogger = js.JsObject.jsify({
    'fetchFeedData': js.allowInterop(({int? maxResults, int? startIndex, dynamic labels, String? searchQuery}) async {
      final result = await blogger.fetchFeedData(
        maxResults: maxResults ?? 50,
        startIndex: startIndex ?? 1,
        labels: labels ?? '',
        searchQuery: searchQuery ?? '',
      );
      return js.JsObject.jsify(result);
    }),
    'fetchSearchSuggestions': js.allowInterop((String query) async {
      final result = await blogger.fetchSearchSuggestions(query);
      return js.JsObject.jsify(result);
    }),
  });
  js.context['BloggerDataService'] = jsBlogger;

  // Expose GooglePayService with highly compatible JS-wrapper
  final jsGpay = js.JsObject.jsify({
    'initPayment': js.allowInterop((js.JsObject order, [js.JsObject? verifiedLocation]) async {
      final orderJson = js.context['JSON'].callMethod('stringify', [order]) as String;
      final orderMap = json.decode(orderJson) as Map<String, dynamic>;

      Map<String, dynamic>? locationMap;
      if (verifiedLocation != null) {
        final locJson = js.context['JSON'].callMethod('stringify', [verifiedLocation]) as String;
        locationMap = json.decode(locJson) as Map<String, dynamic>;
      }

      await gpay.initPayment(orderMap, verifiedLocation: locationMap);
    }),
  });
  js.context['GooglePayService'] = jsGpay;

  // Expose PhoneVerificationRenderer with highly compatible JS-wrapper
  final jsPhoneVerify = js.JsObject.jsify({
    'render': js.allowInterop(phoneVerify.render),
  });
  js.context['PhoneVerificationRenderer'] = jsPhoneVerify;

  document.addEventListener('DOMContentLoaded', (event) {
    window.animationFrame.then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (document.getElementById('post-body-raw') != null) {
          initItem();
        }
        if (document.getElementById('app-grid') != null) {
          GridRenderer.init();
        }
      });
    });
  });

  // Bind carousel navigation to global window object
  js.context['goToSlide'] = js.allowInterop(CarouselRenderer.goToSlide);
  js.context['nextSlide'] = js.allowInterop(CarouselRenderer.nextSlide);
  js.context['prevSlide'] = js.allowInterop(CarouselRenderer.prevSlide);
}

void initItem() async {
  final rawEl = document.getElementById('post-body-raw');
  if (rawEl == null) return;

  var data = SchemaParser.parseJSON(rawEl.text);

  if (data == null) {
    final allScripts = document.querySelectorAll('script[type="application/ld+json"]');
    for (var s in allScripts) {
      final parsed = SchemaParser.parseJSON(s.text);
      if (parsed != null) {
        final type = parsed['@type'];
        if (type == 'ProductGroup' || type == 'Service' || type == 'LocalBusiness' || type == 'Product') {
          data = parsed;
          break;
        }
      }
    }
  }

  if (data == null) {
    final initEl = document.getElementById('initializing-state');
    if (initEl != null) {
      initEl.setInnerHtml('<div style="color:red; font-weight:bold;">Error: No valid Product or Service data found in this post.</div>');
    }
    return;
  }

  // Resolve references asynchronously using our SOLID SchemaResolver!
  final resolvedData = await SchemaResolver.resolve(data);

  final type = resolvedData['@type'];
  if (type == 'ProductGroup') {
    state.product = resolvedData;
    ProductRenderer.renderProduct();
  } else if (type == 'LocalBusiness' || type == 'Service' || type == 'Product') {
    state.service = resolvedData;
    ServiceRenderer.renderService();
  }

  final init = document.getElementById('initializing-state');
  if (init != null) {
    init.classes.add('hidden');
  }

  document.getElementById('carousel-section')?.classes.remove('hidden');
  document.getElementById('details-section')?.classes.remove('hidden');
}
