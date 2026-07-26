import 'dart:html';
import 'dart:js' as js;
import '../core/cart_manager.dart';
import '../core/schema_extractor.dart';

class OrderSummaryRenderer {
  static final OrderSummaryRenderer _instance = OrderSummaryRenderer._internal();
  final CartManager cartManager = CartManager();

  OrderSummaryRenderer._internal();

  factory OrderSummaryRenderer() {
    return _instance;
  }

  void render(Map<String, dynamic>? verifiedLocation, [Map<String, dynamic>? orderDelivery]) {
    var modal = document.getElementById('antinna-summary-modal');
    if (modal == null) {
      modal = DivElement()
        ..id = 'antinna-summary-modal'
        ..className = 'antinna-geo-backdrop';
      document.body?.append(modal);
    }

    final order = cartManager.order;
    final currency = order['priceCurrency']?.toString() ?? 'INR';
    final currencySymbol = SchemaExtractor.getCurrencySymbol(currency);

    // Compute serviceability errors
    final serviceabilityErrors = _getServiceabilityErrors(verifiedLocation);
    final isServiceable = serviceabilityErrors.isEmpty;

    final orderedItems = SchemaExtractor.getArray(order['orderedItem']);
    var itemsHtml = '';

    for (var item in orderedItems) {
      if (item is Map<String, dynamic>) {
        final orderedObj = item['orderedItem'] as Map<String, dynamic>? ?? {};
        final name = SchemaExtractor.getFirst(orderedObj['name'])?.toString() ?? 'Unnamed Item';
        final qty = int.tryParse(item['orderQuantity']?.toString() ?? '1') ?? 1;

        final offers = orderedObj['offers'] as Map<String, dynamic>? ?? {};
        final priceData = SchemaExtractor.extractPrice(offers);
        final price = double.tryParse(priceData['price']?.toString() ?? '0.0') ?? 0.0;
        final bookingReq = SchemaExtractor.extractAdvanceBookingRequirement(offers);

        // Render Addons
        var addOnsHtml = '';
        final addOns = SchemaExtractor.getArray(item['addOns']);
        for (var addon in addOns) {
          if (addon is Map<String, dynamic>) {
            final addonOrdered = addon['orderedItem'] as Map<String, dynamic>? ?? {};
            final addonName = SchemaExtractor.getFirst(addonOrdered['name'])?.toString() ?? 'Unnamed Addon';
            final addonQty = int.tryParse(addon['orderQuantity']?.toString() ?? '1') ?? 1;
            final addonOffers = addonOrdered['offers'] as Map<String, dynamic>? ?? {};
            final addonPriceData = SchemaExtractor.extractPrice(addonOffers);
            final addonPrice = double.tryParse(addonPriceData['price']?.toString() ?? '0.0') ?? 0.0;

            addOnsHtml += '''
              <div style="display:flex; justify-content:space-between; font-size:0.75rem; opacity:0.7; padding-left:15px; margin-top:4px;">
                <span>+ $addonName <b>x$addonQty</b></span>
                <span>$currencySymbol${(addonPrice * addonQty).toStringAsFixed(2)}</span>
              </div>
            ''';
          }
        }

        itemsHtml += '''
          <div style="padding:10px 0; border-bottom:1px solid #eee; font-size:0.9rem;">
            <div style="display:flex; justify-content:space-between;">
              <span style="flex:1;">$name <b>x$qty</b></span>
              <span style="font-weight:700;">$currencySymbol${(price * qty).toStringAsFixed(2)}</span>
            </div>
            $addOnsHtml
            ${bookingReq != null ? '<div style="font-size:0.75rem; color:var(--accent); margin-top:2px;">Booking: $bookingReq</div>' : ''}
          </div>
        ''';
      }
    }

    var errorHtml = '';
    if (!isServiceable) {
      final errorsListHtml = serviceabilityErrors.map((e) => '<li>$e</li>').join('');
      errorHtml = '''
        <div style="margin-bottom:20px; padding:15px; background:#fff5f5; border:1px solid #feb2b2; border-radius:12px; color:#c53030; font-size:0.85rem;">
          <div style="font-weight:800; margin-bottom:5px;">⚠️ Non-Serviceable Items</div>
          <p style="margin:0;">The following items are not available in your area:</p>
          <ul style="margin:5px 0 0 15px; padding:0;">
            $errorsListHtml
          </ul>
          <div style="margin-top:10px; font-weight:700;">Please remove these from your cart to continue.</div>
        </div>
      ''';
    }

    final maxLeadTime = _getMaxLeadTime();
    final travelDurationStr = verifiedLocation != null ? verifiedLocation['duration']?.toString() ?? '0 mins' : '0 mins';
    final travelMinutes = int.tryParse(travelDurationStr.replaceAll(RegExp(r'\D'), '')) ?? 0;
    final totalMinutes = travelMinutes + maxLeadTime;

    var formattedEstTime = '$totalMinutes mins';
    if (totalMinutes >= 60) {
      final hours = totalMinutes ~/ 60;
      final mins = totalMinutes % 60;
      formattedEstTime = mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }

    var destAddress = 'Verified Location';
    if (orderDelivery != null) {
      final addr = orderDelivery['deliveryAddress'] as Map<String, dynamic>? ?? {};
      destAddress = '${addr['extendedAddress'] ?? ''}, ${addr['streetAddress'] ?? ''}, ${addr['addressLocality'] ?? ''}';
    } else if (verifiedLocation != null) {
      destAddress = verifiedLocation['address']?.toString() ?? 'Verified Location';
    }

    modal.setInnerHtml('''
      <div class="antinna-geo-content">
        <div class="antinna-geo-header">
          <h3>Order Summary</h3>
          <button class="antinna-geo-close" id="antinna-summary-modal-close">&times;</button>
        </div>

        $errorHtml

        <div style="margin-bottom:20px; padding:15px; background:var(--bg); border-radius:12px;">
          <div style="font-size:0.75rem; text-transform:uppercase; color:#777; margin-bottom:5px; font-weight:800;">Delivery Destination</div>
          <div style="font-weight:700; font-size:0.95rem;">
            $destAddress
          </div>
          <div style="font-size:0.8rem; color:var(--accent); margin-top:4px;">
            Distance: ${verifiedLocation != null ? verifiedLocation['distance'] ?? '--' : '--'} | Est. Time: $formattedEstTime
          </div>
        </div>

        <div style="max-height:200px; overflow-y:auto; margin-bottom:20px;">
          $itemsHtml
        </div>

        <div style="display:flex; justify-content:space-between; font-weight:900; font-size:1.2rem; margin:20px 0;">
          <span>Grand Total</span>
          <span>$currencySymbol${order['totalPrice'] ?? 0}</span>
        </div>

        <div id="google-pay-button-container" style="display:flex; justify-content:center; margin-top:20px;"></div>

        <p style="font-size:0.7rem; text-align:center; opacity:0.5; margin-top:15px;">
          By clicking Pay, you agree to our <a href="/p/terms-conditions.html" target="_blank" style="color:inherit; text-decoration:underline;">terms and conditions</a>.
        </p>
      </div>
    ''', treeSanitizer: NodeTreeSanitizer.trusted);

    final closeBtn = modal.querySelector('#antinna-summary-modal-close');
    closeBtn?.onClick.listen((_) {
      modal?.classes.remove('active');
    });

    modal.classes.add('active');
    _renderGooglePayButton(order, verifiedLocation, isServiceable);
  }

  void _renderGooglePayButton(Map<String, dynamic> order, Map<String, dynamic>? verifiedLocation, bool isServiceable) {
    final container = document.getElementById('google-pay-button-container');
    if (container == null) return;
    container.text = '';

    if (!isServiceable) {
      container.setInnerHtml('''
        <button class="v-btn" style="width:100%; opacity:0.5; cursor:not-allowed;" disabled>
          Check Coverage to Pay
        </button>
      ''', treeSanitizer: NodeTreeSanitizer.trusted);
      return;
    }

    final isDark = document.documentElement?.classes.contains('dark') ?? false;

    final btn = ButtonElement()
      ..className = 'gpay-button ${isDark ? 'white' : 'black'}'
      ..style.backgroundImage = 'url(\'https://www.gstatic.com/instantbuy/svg/${isDark ? 'light' : 'dark'}_gpay.svg\')'
      ..style.backgroundOrigin = 'content-box'
      ..style.backgroundPosition = 'center'
      ..style.backgroundRepeat = 'no-repeat'
      ..style.backgroundSize = 'contain'
      ..style.border = '0'
      ..style.borderRadius = '4px'
      ..style.boxShadow = '0 1px 1px 0 rgba(60, 64, 67, 0.3), 0 1px 3px 1px rgba(60, 64, 67, 0.15)'
      ..style.cursor = 'pointer'
      ..style.height = '48px'
      ..style.minWidth = '160px'
      ..style.padding = '12px 24px'
      ..style.width = '100%'
      ..style.backgroundColor = isDark ? '#fff' : '#000';

    btn.onClick.listen((_) {
      if (js.context['GooglePayService'] != null) {
        js.context['GooglePayService'].callMethod('initPayment', [
          js.JsObject.jsify(order),
          verifiedLocation != null ? js.JsObject.jsify(verifiedLocation) : null,
        ]);
      }
    });

    container.append(btn);
  }

  List<String> _getServiceabilityErrors(Map<String, dynamic>? verifiedLocation) {
    final items = SchemaExtractor.getArray(cartManager.order['orderedItem']);
    final errors = <String>[];

    for (var item in items) {
      if (item is Map<String, dynamic>) {
        final itemOffered = item['orderedItem'] as Map<String, dynamic>? ?? {};
        final name = SchemaExtractor.getFirst(itemOffered['name'])?.toString() ?? 'Unnamed Item';
        final areas = SchemaExtractor.extractAreaServed(itemOffered);

        if (areas.isNotEmpty && verifiedLocation != null) {
          final isServiceable = areas.any((area) {
            return SchemaExtractor.isLocationInArea(
              double.tryParse(verifiedLocation['lat']?.toString() ?? ''),
              double.tryParse(verifiedLocation['lng']?.toString() ?? verifiedLocation['lon']?.toString() ?? ''),
              verifiedLocation['addressDetails'] as Map<String, dynamic>?,
              area as Map<String, dynamic>?,
            );
          });
          if (!isServiceable) {
            errors.add(name);
          }
        }

        // Check Business Hours
        final seller = item['seller'] as Map<String, dynamic>?;
        if (seller != null) {
          final status = SchemaExtractor.isBusinessOpen(seller);
          if (status['isOpen'] != true) {
            errors.add('$name (Seller currently closed: ${status['message'] ?? 'Closed'})');
          }
        }

        // Check addons
        final addOns = SchemaExtractor.getArray(item['addOns']);
        for (var addon in addOns) {
          if (addon is Map<String, dynamic>) {
            final addonOrdered = addon['orderedItem'] as Map<String, dynamic>? ?? {};
            final addonName = SchemaExtractor.getFirst(addonOrdered['name'])?.toString() ?? 'Unnamed Addon';
            final aAreas = SchemaExtractor.extractAreaServed(addonOrdered);
            if (aAreas.isNotEmpty && verifiedLocation != null) {
              final isAServiceable = aAreas.any((area) {
                return SchemaExtractor.isLocationInArea(
                  double.tryParse(verifiedLocation['lat']?.toString() ?? ''),
                  double.tryParse(verifiedLocation['lng']?.toString() ?? verifiedLocation['lon']?.toString() ?? ''),
                  verifiedLocation['addressDetails'] as Map<String, dynamic>?,
                  area as Map<String, dynamic>?,
                );
              });
              if (!isAServiceable) {
                errors.add(addonName);
              }
            }
          }
        }
      }
    }

    return errors;
  }

  int _getMaxLeadTime() {
    final items = SchemaExtractor.getArray(cartManager.order['orderedItem']);
    var maxLead = 0;

    for (var item in items) {
      if (item is Map<String, dynamic>) {
        final orderedObj = item['orderedItem'] as Map<String, dynamic>? ?? {};
        final lead = SchemaExtractor.extractLeadTime(orderedObj);
        if (lead > maxLead) maxLead = lead;

        final addOns = SchemaExtractor.getArray(item['addOns']);
        for (var addon in addOns) {
          if (addon is Map<String, dynamic>) {
            final addonOrdered = addon['orderedItem'] as Map<String, dynamic>? ?? {};
            final aLead = SchemaExtractor.extractLeadTime(addonOrdered);
            if (aLead > maxLead) maxLead = aLead;
          }
        }
      }
    }

    return maxLead;
  }
}
