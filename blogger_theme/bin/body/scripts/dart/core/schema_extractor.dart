import 'dart:math' as math;

class SchemaExtractor {
  static dynamic getFirst(dynamic val) {
    if (val is List) {
      return val.isNotEmpty ? val.first : null;
    }
    return val;
  }

  static List<dynamic> getArray(dynamic val) {
    if (val == null) return [];
    if (val is List) return val;
    return [val];
  }

  static String normalizeName(String name) {
    return name.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static Map<String, dynamic>? findMatchingVariant(Map<String, dynamic> parent, Map<String, String> selectedAttributes, [String? lastClickedAttr]) {
    final variants = getArray(parent['hasVariant']).isNotEmpty ? getArray(parent['hasVariant']) : [parent];

    var match = variants.firstWhere((v) {
      if (v is! Map) return false;
      return selectedAttributes.entries.every((entry) {
        final val = getFirst(v[entry.key])?.toString();
        return val == entry.value;
      });
    }, orElse: () => null);

    if (match == null && lastClickedAttr != null) {
      match = variants.firstWhere((v) {
        if (v is! Map) return false;
        final val = getFirst(v[lastClickedAttr])?.toString();
        return val == selectedAttributes[lastClickedAttr];
      }, orElse: () => null);
    }

    return match as Map<String, dynamic>? ?? (variants.isNotEmpty ? variants.first as Map<String, dynamic> : null);
  }

  static Map<String, dynamic> extractPrice(dynamic offer) {
    final off = offer is List ? (offer.isNotEmpty ? offer.first : null) : offer;
    if (off == null || off is! Map) return {'price': '0', 'currency': 'INR'};

    var priceVal = getFirst(off['price']);
    if (priceVal == null) {
      final itemOffered = getArray(off['itemOffered']);
      if (itemOffered.isNotEmpty && itemOffered.first is Map) {
        priceVal = getFirst(itemOffered.first['offers']?['price']);
      }
    }
    if (priceVal == null) {
      final offersList = getArray(off['offers']);
      if (offersList.isNotEmpty && offersList.first is Map) {
        priceVal = getFirst(offersList.first['price']);
      }
    }

    var currencyVal = getFirst(off['priceCurrency']);
    if (currencyVal == null) {
      final itemOffered = getArray(off['itemOffered']);
      if (itemOffered.isNotEmpty && itemOffered.first is Map) {
        currencyVal = getFirst(itemOffered.first['offers']?['priceCurrency']);
      }
    }
    if (currencyVal == null) {
      final offersList = getArray(off['offers']);
      if (offersList.isNotEmpty && offersList.first is Map) {
        currencyVal = getFirst(offersList.first['priceCurrency']);
      }
    }

    return {
      'price': priceVal?.toString() ?? '0',
      'currency': currencyVal?.toString() ?? 'INR',
    };
  }

  static String extractAvailability(dynamic offer) {
    final off = offer is List ? (offer.isNotEmpty ? offer.first : null) : offer;
    if (off == null || off is! Map) return 'https://schema.org/InStock';

    var av = getFirst(off['availability']);
    if (av == null) {
      final itemOffered = getArray(off['itemOffered']);
      if (itemOffered.isNotEmpty && itemOffered.first is Map) {
        av = getFirst(itemOffered.first['offers']?['availability']);
      }
    }
    if (av == null) {
      final offersList = getArray(off['offers']);
      if (offersList.isNotEmpty && offersList.first is Map) {
        av = getFirst(offersList.first['availability']);
      }
    }

    if (av is Map) {
      return av['@id']?.toString() ?? av.toString();
    }
    return av?.toString() ?? 'https://schema.org/InStock';
  }

  static Map<String, int?> extractEligibleQuantity(dynamic data) {
    final obj = data is List ? (data.isNotEmpty ? data.first : null) : data;
    if (obj == null || obj is! Map) return {'minValue': null, 'maxValue': null};

    var eq = getFirst(obj['eligibleQuantity']);
    if (eq == null) {
      final itemOffered = getArray(obj['itemOffered']);
      if (itemOffered.isNotEmpty && itemOffered.first is Map) {
        eq = getFirst(itemOffered.first['offers']?['eligibleQuantity']) ?? getFirst(itemOffered.first['eligibleQuantity']);
      }
    }
    if (eq == null) {
      final offersList = getArray(obj['offers']);
      if (offersList.isNotEmpty && offersList.first is Map) {
        eq = getFirst(offersList.first['eligibleQuantity']) ?? getFirst(offersList.first['itemOffered']?['eligibleQuantity']);
      }
    }

    if (eq == null || eq is! Map) return {'minValue': null, 'maxValue': null};

    final min = getFirst(eq['minValue']);
    final max = getFirst(eq['maxValue']);

    return {
      'minValue': min != null ? int.tryParse(min.toString()) : null,
      'maxValue': max != null ? int.tryParse(max.toString()) : null,
    };
  }

  static int? extractInventoryLevel(dynamic data) {
    final obj = data is List ? (data.isNotEmpty ? data.first : null) : data;
    if (obj == null || obj is! Map) return null;

    var il = getFirst(obj['inventoryLevel']);
    if (il == null) {
      final itemOffered = getArray(obj['itemOffered']);
      if (itemOffered.isNotEmpty && itemOffered.first is Map) {
        il = getFirst(itemOffered.first['offers']?['inventoryLevel']) ?? getFirst(itemOffered.first['inventoryLevel']);
      }
    }
    if (il == null) {
      final offersList = getArray(obj['offers']);
      if (offersList.isNotEmpty && offersList.first is Map) {
        il = getFirst(offersList.first['inventoryLevel']) ?? getFirst(offersList.first['itemOffered']?['inventoryLevel']);
      }
    }

    if (il == null) return null;

    final val = il is Map ? getFirst(il['value']) : il;
    return val != null ? int.tryParse(val.toString()) : null;
  }

  static Map<String, double?> extractDimensions(dynamic data) {
    final obj = data is List ? (data.isNotEmpty ? data.first : null) : data;
    if (obj == null || obj is! Map) return {'weight': null, 'height': null, 'width': null, 'depth': null};

    double? getNum(dynamic v) {
      if (v == null) return null;
      if (v is Map) return double.tryParse(getFirst(v['value'])?.toString() ?? '');
      return double.tryParse(v.toString());
    }

    return {
      'weight': getNum(obj['weight']),
      'height': getNum(obj['height']),
      'width': getNum(obj['width']),
      'depth': getNum(obj['depth']),
    };
  }

  static String? extractAdvanceBookingRequirement(dynamic offer) {
    final off = offer is List ? (offer.isNotEmpty ? offer.first : null) : offer;
    if (off == null || off is! Map) return null;

    final abr = getFirst(off['advanceBookingRequirement']);
    if (abr == null) return null;

    if (abr is String) return abr;
    if (abr is Map) {
      final val = getFirst(abr['value']);
      final unit = getFirst(abr['unitCode']) ?? getFirst(abr['unitText']) ?? '';
      if (val == null) return null;

      var unitLabel = unit.toString();
      if (unit == 'HUR') unitLabel = 'Hours';
      if (unit == 'DAY') unitLabel = 'Days';

      return '$val $unitLabel'.trim();
    }
    return null;
  }

  static String? extractCondition(dynamic data) {
    final obj = data is List ? (data.isNotEmpty ? data.first : null) : data;
    if (obj == null || obj is! Map) return null;

    var cond = getFirst(obj['itemCondition']);
    if (cond == null) {
      final itemOffered = getArray(obj['itemOffered']);
      if (itemOffered.isNotEmpty && itemOffered.first is Map) {
        cond = getFirst(itemOffered.first['offers']?['itemCondition']) ?? getFirst(itemOffered.first['itemCondition']);
      }
    }
    if (cond == null) {
      final offersList = getArray(obj['offers']);
      if (offersList.isNotEmpty && offersList.first is Map) {
        cond = getFirst(offersList.first['itemCondition']) ?? getFirst(offersList.first['itemOffered']?['itemCondition']);
      }
    }

    if (cond == null) return null;

    final str = cond.toString().toLowerCase();
    if (str.contains('newcondition')) return 'New';
    if (str.contains('refurbishedcondition')) return 'Refurbished';
    if (str.contains('usedcondition')) return 'Used';
    if (str.contains('damagedcondition')) return 'Damaged';

    return str.split('/').last;
  }

  static List<dynamic> extractAreaServed(dynamic data) {
    final results = [];
    final stack = [data];
    final seen = <dynamic>{};

    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      if (current == null || current is! Map || seen.contains(current)) continue;
      seen.add(current);

      final areas = getArray(current['areaServed'] ?? current['eligibleRegion']);
      if (areas.isNotEmpty) {
        results.addAll(areas);
      }

      if (current['itemOffered'] != null) stack.add(current['itemOffered']);
      if (current['offers'] != null) stack.addAll(getArray(current['offers']));
      if (current['hasVariant'] != null) stack.addAll(getArray(current['hasVariant']));
      if (current['hasOfferCatalog'] != null) stack.addAll(getArray(current['hasOfferCatalog']));
      if (current['itemListElement'] != null) stack.addAll(getArray(current['itemListElement']));
    }

    return results;
  }

  static Map<String, dynamic> isBusinessOpen(dynamic data) {
    final obj = data is List ? (data.isNotEmpty ? data.first : null) : data;
    if (obj == null || obj is! Map) return {'isOpen': true, 'message': null};

    final now = DateTime.now();
    final todayStr = now.toIso8601String().split('T').first;
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final todayName = dayNames[now.weekday % 7];

    // 1. Check Special Opening Hours (Overrides)
    final special = getArray(obj['specialOpeningHoursSpecification']);
    for (var s in special) {
      if (s is Map) {
        final from = getFirst(s['validFrom']);
        final through = getFirst(s['validThrough']);
        if (from != null && through != null && todayStr.compareTo(from.toString()) >= 0 && todayStr.compareTo(through.toString()) <= 0) {
          final opens = s['opens']?.toString() ?? '00:00';
          final closes = s['closes']?.toString() ?? '00:00';
          if (opens == '00:00' && closes == '00:00') return {'isOpen': false, 'message': 'Closed for Holiday/Event'};
          final isOpen = timeStr.compareTo(opens) >= 0 && timeStr.compareTo(closes) <= 0;
          return {
            'isOpen': isOpen,
            'message': isOpen ? null : 'Closed (Special Hours: $opens-$closes)',
          };
        }
      }
    }

    // 2. Check Regular Opening Hours
    final regular = getArray(obj['openingHoursSpecification']);
    if (regular.isEmpty) return {'isOpen': true, 'message': null};

    final todayRegular = regular.firstWhere((r) {
      if (r is! Map) return false;
      final days = getArray(r['dayOfWeek']).map((d) => d.toString().replaceAll('https://schema.org/', '')).toList();
      return days.contains(todayName);
    }, orElse: () => null) as Map<String, dynamic>?;

    if (todayRegular == null) return {'isOpen': false, 'message': 'Closed on $todayName'};

    final opens = todayRegular['opens']?.toString() ?? '00:00';
    final closes = todayRegular['closes']?.toString() ?? '23:59';
    final isOpen = timeStr.compareTo(opens) >= 0 && timeStr.compareTo(closes) <= 0;

    return {
      'isOpen': isOpen,
      'message': isOpen ? null : 'Closed (Opens at $opens)',
    };
  }

  static int extractLeadTime(dynamic data) {
    final obj = data is List ? (data.isNotEmpty ? data.first : null) : data;
    if (obj == null || obj is! Map) return 0;

    var lt = getFirst(obj['deliveryLeadTime']);
    if (lt == null) {
      final itemOffered = getArray(obj['itemOffered']);
      if (itemOffered.isNotEmpty && itemOffered.first is Map) {
        lt = getFirst(itemOffered.first['offers']?['deliveryLeadTime']) ?? getFirst(itemOffered.first['deliveryLeadTime']);
      }
    }
    if (lt == null) {
      final offersList = getArray(obj['offers']);
      if (offersList.isNotEmpty && offersList.first is Map) {
        lt = getFirst(offersList.first['deliveryLeadTime']) ?? getFirst(offersList.first['itemOffered']?['deliveryLeadTime']);
      }
    }

    if (lt == null) return 0;

    if (lt is Map) {
      final val = int.tryParse(getFirst(lt['value'])?.toString() ?? '0') ?? 0;
      final unit = getFirst(lt['unitCode']) ?? getFirst(lt['unitText']) ?? 'MIN';

      if (unit == 'HUR' || unit == 'hour' || unit == 'hours') return val * 60;
      if (unit == 'DAY' || unit == 'day' || unit == 'days') return val * 24 * 60;
      return val;
    }

    final str = lt.toString().toLowerCase();
    final num = int.tryParse(str.replaceAll(RegExp(r'\D'), '')) ?? 0;
    if (str.contains('hour')) return num * 60;
    if (str.contains('day')) return num * 24 * 60;
    return num;
  }

  static bool isLocationInArea(double? targetLat, double? targetLon, Map<String, dynamic>? targetAddress, Map<String, dynamic>? area) {
    if (area == null) return true;

    final type = getFirst(area['@type'])?.toString() ?? '';
    final name = normalizeName(getFirst(area['name'])?.toString() ?? '');
    final postalCode = getFirst(area['postalCode'])?.toString() ?? '';

    // 1. Check GeoCircle
    if (type == 'GeoCircle') {
      if (targetLat == null || targetLon == null) return false;
      final midpoint = area['geoMidpoint'] as Map<String, dynamic>?;
      if (midpoint == null) return false;
      final mLat = double.tryParse(getFirst(midpoint['latitude'])?.toString() ?? '');
      final mLon = double.tryParse(getFirst(midpoint['longitude'])?.toString() ?? '');
      final radius = double.tryParse(getFirst(area['geoRadius'])?.toString() ?? '') ?? 0.0;

      if (mLat != null && mLon != null) {
        final dist = _calculateDistance(targetLat, targetLon, mLat, mLon);
        return dist <= radius;
      }
      return false;
    }

    // 2. Check City / State / Country
    if (type == 'City' || type == 'AdministrativeArea' || type == 'State' || type == 'Country') {
      final tCity = normalizeName(targetAddress?['addressLocality']?.toString() ?? '');
      final tState = normalizeName(targetAddress?['addressRegion']?.toString() ?? '');
      final tCountry = normalizeName(targetAddress?['addressCountry']?.toString() ?? '');

      if (name == tCity || name == tState || name == tCountry) return true;
    }

    // 3. Check PostalAddress / PostalCode
    if (type == 'PostalAddress' || postalCode.isNotEmpty) {
      final tPin = targetAddress?['postalCode']?.toString() ?? '';
      final aPin = postalCode.isNotEmpty ? postalCode : (getFirst(area['postalCode'])?.toString() ?? '');
      if (tPin == aPin && tPin.isNotEmpty) return true;

      final tLoc = normalizeName(targetAddress?['addressLocality']?.toString() ?? '');
      final aLoc = normalizeName(getFirst(area['addressLocality'])?.toString() ?? '');
      if (tLoc == aLoc && tLoc.isNotEmpty) return true;
    }

    return false;
  }

  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371e3; // metres
    final phi1 = lat1 * math.pi / 180;
    final phi2 = lat2 * math.pi / 180;
    final deltaPhi = (lat2 - lat1) * math.pi / 180;
    final deltaLambda = (lon2 - lon1) * math.pi / 180;

    final a = math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
        math.cos(phi1) * math.cos(phi2) *
        math.sin(deltaLambda / 2) * math.sin(deltaLambda / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return R * c; // in metres
  }

  static String getCurrencySymbol(String currency) {
    final symbols = {
      'INR': '₹',
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥'
    };
    return symbols[currency.toUpperCase()] ?? currency;
  }
}
