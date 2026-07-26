import 'dart:html';
import 'dart:convert';

class CartManager {
  Map<String, dynamic> order = {};
  final String storageKey = 'antinna_cart_order';

  CartManager() {
    order = loadFromStorage() ?? {
      '@type': 'Order',
      'orderedItem': [],
      'totalPrice': 0.0,
      'priceCurrency': 'INR',
    };
    deduplicate();
  }

  Map<String, dynamic>? loadFromStorage() {
    final saved = window.localStorage[storageKey];
    if (saved != null && saved.isNotEmpty) {
      try {
        return json.decode(saved) as Map<String, dynamic>;
      } catch (_) {}
    }
    return null;
  }

  void saveToStorage() {
    calculateTotal();
    window.localStorage[storageKey] = json.encode(order);
  }

  void deduplicate() {
    final uniqueItems = <String, Map<String, dynamic>>{};
    final newOrderedItems = <Map<String, dynamic>>[];
    final orderedItems = _getArray(order['orderedItem']);

    for (var item in orderedItems) {
      if (item is Map<String, dynamic>) {
        final key = item['itemKey']?.toString() ?? generateItemKey(item['orderedItem'], item['_selectedVariants'] as Map<String, dynamic>?);
        if (uniqueItems.containsKey(key)) {
          final existing = uniqueItems[key]!;
          final existingQty = int.tryParse(existing['orderQuantity']?.toString() ?? '1') ?? 1;
          final itemQty = int.tryParse(item['orderQuantity']?.toString() ?? '1') ?? 1;
          existing['orderQuantity'] = existingQty + itemQty;
        } else {
          item['itemKey'] = key;
          uniqueItems[key] = item;
          newOrderedItems.add(item);
        }
      }
    }

    order['orderedItem'] = newOrderedItems;
    calculateTotal();
  }

  void calculateTotal() {
    final orderedItems = _getArray(order['orderedItem']);
    double sum = 0.0;

    for (var item in orderedItems) {
      if (item is Map<String, dynamic> && isItemOrderable(item)) {
        final orderedObj = item['orderedItem'] as Map<String, dynamic>? ?? {};
        final offers = orderedObj['offers'] as Map<String, dynamic>? ?? {};
        final price = _extractPrice(offers);
        final qty = int.tryParse(item['orderQuantity']?.toString() ?? '1') ?? 1;
        var itemTotal = price * qty;

        // Add price of addons
        final addOns = _getArray(item['addOns']);
        for (var addon in addOns) {
          if (addon is Map<String, dynamic>) {
            final addonOrdered = addon['orderedItem'] as Map<String, dynamic>? ?? {};
            final addonOffers = addonOrdered['offers'] as Map<String, dynamic>? ?? {};
            final addonPrice = _extractPrice(addonOffers);
            final addonQty = int.tryParse(addon['orderQuantity']?.toString() ?? '0') ?? 0;
            itemTotal += addonPrice * addonQty;
          }
        }

        sum += itemTotal;
      }
    }

    order['totalPrice'] = sum;
  }

  bool isItemOrderable(Map<String, dynamic> item) {
    if (item['isUnavailable'] == true) return false;
    final orderedObj = item['orderedItem'] as Map<String, dynamic>? ?? {};
    final offers = orderedObj['offers'] as Map<String, dynamic>? ?? {};
    final av = offers['availability']?.toString();
    if (av == 'https://schema.org/OutOfStock' || av == 'https://schema.org/SoldOut') return false;
    return true;
  }

  bool isItemQuantityValid(Map<String, dynamic> item) {
    final constraints = item['_constraints'] as Map<String, dynamic>?;
    final min = constraints != null ? int.tryParse(constraints['minValue']?.toString() ?? '') : null;
    final qty = int.tryParse(item['orderQuantity']?.toString() ?? '1') ?? 1;
    if (min != null && qty < min) return false;
    return true;
  }

  bool isCartValid() {
    final items = _getArray(order['orderedItem']);
    if (items.isEmpty) return false;
    return items.every((item) {
      if (item is Map<String, dynamic>) {
        return isItemOrderable(item) && isItemQuantityValid(item);
      }
      return false;
    });
  }

  String? addItem(Map<String, dynamic> item, {Map<String, dynamic>? seller, Map<String, dynamic>? selectedVariants, int quantity = 1}) {
    final offers = item['offers'] as Map<String, dynamic>? ?? {};
    final availability = offers['availability']?.toString() ?? '';
    if (availability == 'https://schema.org/OutOfStock') {
      return null;
    }

    var itemUrl = item['url']?.toString() ?? '';
    if (itemUrl.isEmpty) {
      itemUrl = window.location.href.split('?').first.split('#').first;
    }

    final itemKey = generateItemKey(item, selectedVariants);
    final orderedItems = _getArray(order['orderedItem']);

    final existing = orderedItems.firstWhere((oi) {
      return oi is Map && oi['itemKey'] == itemKey;
    }, orElse: () => null) as Map<String, dynamic>?;

    final constraints = _extractConstraints(item);
    final minValue = constraints['minValue'];
    final maxValue = constraints['maxValue'];
    final inventoryLevel = constraints['inventoryLevel'];

    var effectiveMax = (maxValue != null && inventoryLevel != null) ? (maxValue < inventoryLevel ? maxValue : inventoryLevel) : (maxValue ?? inventoryLevel);

    final initialQty = quantity < (minValue ?? 1) ? (minValue ?? 1) : quantity;

    if (existing != null) {
      final currentQty = int.tryParse(existing['orderQuantity']?.toString() ?? '0') ?? 0;
      var newQty = currentQty + quantity;

      if (effectiveMax != null && newQty > effectiveMax) {
        existing['orderQuantity'] = effectiveMax;
      } else {
        existing['orderQuantity'] = newQty;
      }
      saveToStorage();
      return itemKey;
    } else {
      final itemCopy = json.decode(json.encode(item)) as Map<String, dynamic>;
      final finalInitialQty = (effectiveMax != null && initialQty > effectiveMax) ? effectiveMax : initialQty;

      orderedItems.add({
        '@type': 'OrderItem',
        'orderedItem': {
          ...itemCopy,
          'url': itemUrl,
          '_selectedVariants': selectedVariants != null ? {...selectedVariants} : null,
        },
        'orderQuantity': finalInitialQty,
        'seller': seller != null ? json.decode(json.encode(seller)) : null,
        'itemKey': itemKey,
        '_constraints': {
          'minValue': minValue,
          'maxValue': maxValue,
          'inventoryLevel': inventoryLevel,
        },
        'addOns': [],
      });

      order['orderedItem'] = orderedItems;
      saveToStorage();
      return itemKey;
    }
  }

  void addAddOn(String parentItemKey, Map<String, dynamic> addon, {int quantity = 1}) {
    final orderedItems = _getArray(order['orderedItem']);
    final parent = orderedItems.firstWhere((oi) {
      return oi is Map && oi['itemKey'] == parentItemKey;
    }, orElse: () => null) as Map<String, dynamic>?;

    if (parent == null) {
      return;
    }

    if (parent['addOns'] == null) {
      parent['addOns'] = [];
    }
    final addOns = _getArray(parent['addOns']);

    final addonKey = generateItemKey(addon);
    final existing = addOns.firstWhere((a) {
      return a is Map && a['itemKey'] == addonKey;
    }, orElse: () => null) as Map<String, dynamic>?;

    if (existing != null) {
      final limits = getAddOnLimits(parent, existing);
      final currentQty = int.tryParse(existing['orderQuantity']?.toString() ?? '0') ?? 0;
      final newQty = currentQty + quantity;
      if (limits['maxValue'] != null && newQty > limits['maxValue']!) {
        existing['orderQuantity'] = limits['maxValue'];
      } else {
        existing['orderQuantity'] = newQty;
      }
    } else {
      final constraints = _extractConstraints(addon);
      final minValue = constraints['minValue'];
      final maxValue = constraints['maxValue'];
      final inventoryLevel = constraints['inventoryLevel'];

      final tempAddon = {
        'orderedItem': json.decode(json.encode(addon)),
        '_constraints': {
          'minValue': minValue,
          'maxValue': maxValue,
          'inventoryLevel': inventoryLevel,
        }
      };
      final dynamicLimits = getAddOnLimits(parent, tempAddon);

      final finalMin = dynamicLimits['minValue'] ?? 1;

      addOns.add({
        'orderedItem': tempAddon['orderedItem'],
        'orderQuantity': quantity < finalMin ? finalMin : quantity,
        'itemKey': addonKey,
        '_constraints': {
          'minValue': minValue,
          'maxValue': maxValue,
          'inventoryLevel': inventoryLevel,
        }
      });
    }

    parent['addOns'] = addOns;
    saveToStorage();
  }

  Map<String, int?> getAddOnLimits(Map<String, dynamic> parent, Map<String, dynamic> addon) {
    final parentQty = int.tryParse(parent['orderQuantity']?.toString() ?? '1') ?? 1;
    final constraints = addon['_constraints'] as Map<String, dynamic>? ?? {};
    final min = int.tryParse(constraints['minValue']?.toString() ?? '');
    final max = int.tryParse(constraints['maxValue']?.toString() ?? '');
    final inventoryLevel = int.tryParse(constraints['inventoryLevel']?.toString() ?? '');

    final scaledMax = max != null ? max * parentQty : null;
    final effectiveMax = (scaledMax != null && inventoryLevel != null) ? (scaledMax < inventoryLevel ? scaledMax : inventoryLevel) : (scaledMax ?? inventoryLevel);

    return {
      'minValue': min != null ? min * parentQty : null,
      'maxValue': effectiveMax,
    };
  }

  String generateItemKey(Map<String, dynamic> item, [Map<String, dynamic>? variants]) {
    var url = item['url']?.toString() ?? '';
    if (url.contains('?')) url = url.split('?').first;
    if (url.contains('#')) url = url.split('#').first;
    url = url.toLowerCase().replaceAll(RegExp(r'/$'), '');

    final type = item['@type']?.toString() ?? 'Product';
    final name = item['name']?.toString() ?? '';
    final sku = item['sku']?.toString() ?? '';

    var variantString = '';
    if (variants != null) {
      final sortedKeys = variants.keys.toList()..sort();
      variantString = sortedKeys.map((k) => '$k:${variants[k]}').join('|');
    }

    return '$url::$type::$sku::$name::$variantString';
  }

  void removeItem(int index) {
    final orderedItems = _getArray(order['orderedItem']);
    if (index < 0 || index >= orderedItems.length) return;
    orderedItems.removeAt(index);
    order['orderedItem'] = orderedItems;
    saveToStorage();
  }

  void updateQty(int index, int delta) {
    final orderedItems = _getArray(order['orderedItem']);
    if (index < 0 || index >= orderedItems.length) return;
    final item = orderedItems[index] as Map<String, dynamic>?;
    if (item == null) return;

    final oldQty = int.tryParse(item['orderQuantity']?.toString() ?? '0') ?? 0;
    final newQty = oldQty + delta;

    final constraints = item['_constraints'] as Map<String, dynamic>? ?? {};
    final maxValue = int.tryParse(constraints['maxValue']?.toString() ?? '');
    final inventoryLevel = int.tryParse(constraints['inventoryLevel']?.toString() ?? '');
    final effectiveMax = (maxValue != null && inventoryLevel != null) ? (maxValue < inventoryLevel ? maxValue : inventoryLevel) : (maxValue ?? inventoryLevel);

    if (delta > 0 && effectiveMax != null && newQty > effectiveMax) {
      return;
    }

    item['orderQuantity'] = newQty;

    // Proportional scaling of addons
    final addOns = _getArray(item['addOns']);
    if (addOns.isNotEmpty) {
      final oldParentQty = oldQty == 0 ? 1 : oldQty;
      final newParentQty = newQty;

      for (var addon in addOns) {
        if (addon is Map<String, dynamic>) {
          final addonQty = int.tryParse(addon['orderQuantity']?.toString() ?? '0') ?? 0;
          final ratio = addonQty / oldParentQty;
          addon['orderQuantity'] = (ratio * newParentQty).round();

          final limits = getAddOnLimits(item, addon);
          if (limits['maxValue'] != null && addon['orderQuantity'] > limits['maxValue']!) {
            addon['orderQuantity'] = limits['maxValue'];
          }
          if (limits['minValue'] != null && addon['orderQuantity'] < limits['minValue']!) {
            addon['orderQuantity'] = limits['minValue'];
          }
        }
      }
    }

    if (item['orderQuantity'] <= 0) {
      removeItem(index);
    } else {
      saveToStorage();
    }
  }

  void clear() {
    order['orderedItem'] = [];
    saveToStorage();
  }

  List<dynamic> _getArray(dynamic val) {
    if (val == null) return [];
    if (val is List) return val;
    return [val];
  }

  double _extractPrice(Map<String, dynamic> offers) {
    final priceVal = offers['price'];
    if (priceVal == null) return 0.0;
    if (priceVal is num) return priceVal.toDouble();
    return double.tryParse(priceVal.toString()) ?? 0.0;
  }

  Map<String, int?> _extractConstraints(Map<String, dynamic> item) {
    final offers = item['offers'] as Map<String, dynamic>? ?? {};
    final eligibleQuantity = offers['eligibleQuantity'] as Map<String, dynamic>? ?? item['eligibleQuantity'] as Map<String, dynamic>? ?? {};

    final minValue = int.tryParse(eligibleQuantity['minValue']?.toString() ?? '');
    final maxValue = int.tryParse(eligibleQuantity['maxValue']?.toString() ?? '');

    final inventory = offers['inventoryLevel'] as Map<String, dynamic>? ?? item['inventoryLevel'] as Map<String, dynamic>? ?? {};
    final inventoryLevel = int.tryParse(inventory['value']?.toString() ?? offers['inventoryLevel']?.toString() ?? '');

    return {
      'minValue': minValue,
      'maxValue': maxValue,
      'inventoryLevel': inventoryLevel,
    };
  }
}
