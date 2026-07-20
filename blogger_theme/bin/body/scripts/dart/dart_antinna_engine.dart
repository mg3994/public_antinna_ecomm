import 'dart:html';
import 'dart:convert';
import 'dart:js' as js;

class EngineState {
  Map<String, dynamic>? product;
  Map<String, dynamic>? service;
  Map<String, String> selected = {};
  int slide = 0;
}

final state = EngineState();

void main() {
  document.addEventListener('DOMContentLoaded', (event) {
    // Small timeout to ensure Blogger has finished its own internal rendering
    window.animationFrame.then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (document.getElementById('post-body-raw') != null) {
          initItem();
        }
        if (document.getElementById('app-grid') != null) {
          initGrid();
        }
      });
    });
  });

  // Bind carousel navigation to global window object so inline onclick triggers them perfectly
  js.context['goToSlide'] = js.allowInterop(goToSlide);
  js.context['nextSlide'] = js.allowInterop(nextSlide);
  js.context['prevSlide'] = js.allowInterop(prevSlide);
}

void initGrid() {
  final cards = document.querySelectorAll('.card');
  if (cards.isEmpty) return;

  // Lazy load observer
  final observer = IntersectionObserver((entries, self) {
    for (var entry in entries) {
      if (entry.isIntersecting == true) {
        final card = entry.target as Element;
        final img = card.querySelector('.card-img');
        if (img != null) {
          final src = img.getAttribute('data-src');
          if (src != null) {
            img.setAttribute('src', src);
            img.removeAttribute('data-src');
          }
        }
        self.unobserve(card);
      }
    }
  });

  for (var card in cards) {
    observer.observe(card);
  }

  // Primary source: Attempt to use the full feed to bypass snippet limitations
  final path = window.location.pathname ?? '';
  var feedUrl = '/feeds/posts/default?alt=json&max-results=25';
  if (path.contains('/search/label/')) {
    final label = path.split('/').last.split('?').first;
    feedUrl = '/feeds/posts/default/-/$label?alt=json&max-results=25';
  }

  HttpRequest.getString(feedUrl).then((response) {
    try {
      final feedData = json.decode(response) as Map<String, dynamic>;
      final feed = feedData['feed'] as Map<String, dynamic>?;
      final entries = (feed != null ? feed['entry'] : null) as List<dynamic>? ?? [];

      for (var card in cards) {
        final href = card.getAttribute('href') ?? '';
        final cardUrl = href.split('?').first.split('#').first;

        final entry = entries.firstWhere((e) {
          final links = (e['link'] as List<dynamic>? ?? []);
          return links.any((l) {
            final rel = l['rel'] as String?;
            final lHref = l['href'] as String?;
            return rel == 'alternate' && lHref != null && lHref.contains(cardUrl);
          });
        }, orElse: () => null);

        if (entry != null) {
          final contentMap = entry['content'] as Map<String, dynamic>?;
          final content = contentMap != null ? contentMap['\$t'] as String? : null;
          final data = parseJSON(content);
          if (data != null) {
            renderCardData(card, data);
          }
        } else {
          // Fallback to hidden grid-data if entry not found
          final raw = card.querySelector('.grid-data');
          if (raw != null) {
            final data = parseJSON(raw.text);
            if (data != null) {
              renderCardData(card, data);
            }
          }
        }
      }
    } catch (_) {
      _fallbackGrid(cards);
    }
  }).catchError((_) {
    _fallbackGrid(cards);
  });
}

void _fallbackGrid(List<Element> cards) {
  for (var card in cards) {
    final raw = card.querySelector('.grid-data');
    if (raw != null) {
      final data = parseJSON(raw.text);
      if (data != null) {
        renderCardData(card, data);
      }
    }
  }
}

void renderCardData(Element card, Map<String, dynamic> data) {
  final badge = card.querySelector('.card-badge');
  final price = card.querySelector('.card-price');
  final img = card.querySelector('.card-img') as ImageElement?;

  if (badge == null || price == null) return;

  // Reset badges
  badge.text = '';
  badge.className = 'card-badge';
  badge.style.display = 'inline-block';

  final type = data['@type'];

  if (type == 'ProductGroup' || type == 'Product') {
    badge.text = 'Product';
    final variants = data['hasVariant'] as List<dynamic>? ?? [data];
    final first = variants.isNotEmpty ? variants.first as Map<String, dynamic> : data;

    final offers = first['offers'] as Map<String, dynamic>?;
    if (offers != null) {
      final priceCurrency = offers['priceCurrency'] as String? ?? '';
      final priceVal = offers['price']?.toString() ?? '';
      price.text = '$priceCurrency $priceVal'.trim();

      final isOut = offers['availability'] == 'https://schema.org/OutOfStock';
      if (isOut) {
        price.classes.add('blurry');
        final outB = DivElement()
          ..className = 'card-badge out-stock'
          ..style.marginLeft = '5px'
          ..text = 'Out of Stock';
        badge.after(outB);
      }

      final seller = offers['seller'] as Map<String, dynamic>?;
      if (seller != null && (seller.containsKey('knowsAbout') || seller.containsKey('hasOfferCatalog'))) {
        final sBadge = DivElement()
          ..className = 'card-badge'
          ..style.background = '#3498db'
          ..style.color = '#fff'
          ..style.marginLeft = '5px'
          ..text = '(* Optional Product Related Seller Service Paid Add-Ons available kind stuff)';
        badge.after(sBadge);
      }
    }

    // Prioritize ProductGroup images for Grid/Homepage view
    final imageSource = data['image'] ?? first['image'];
    if (imageSource != null && img != null) {
      if (imageSource is List && imageSource.isNotEmpty) {
        final firstImg = imageSource.first;
        img.src = firstImg is Map ? (firstImg['url'] as String? ?? '') : firstImg.toString();
      } else if (imageSource is Map) {
        img.src = imageSource['url'] as String? ?? '';
      } else {
        img.src = imageSource.toString();
      }
    }

  } else if (type == 'LocalBusiness' || type == 'Service') {
    badge.text = 'Service';
    badge.style.background = '#3498db';
    badge.style.color = '#fff';

    final hasOfferCatalog = data['hasOfferCatalog'] as Map<String, dynamic>?;
    final knowsAbout = data['knowsAbout'];

    // Check if standalone service provider has multiple offerings
    if (knowsAbout != null || (hasOfferCatalog != null && hasOfferCatalog.containsKey('itemListElement'))) {
      final sBadge = DivElement()
        ..className = 'card-badge'
        ..style.background = '#27ae60'
        ..style.color = '#fff'
        ..style.marginLeft = '5px'
        ..text = '(Multi-Service)';
      badge.after(sBadge);
    }

    if (hasOfferCatalog != null && hasOfferCatalog['itemListElement'] is List) {
      final list = hasOfferCatalog['itemListElement'] as List;
      if (list.isNotEmpty) {
        final off = list.first as Map<String, dynamic>;
        final priceCurrency = off['priceCurrency'] as String? ?? '';
        final priceVal = off['price']?.toString() ?? '';
        price.text = 'Starts $priceCurrency $priceVal'.trim();
      }
    } else {
      final offers = data['offers'] as Map<String, dynamic>?;
      if (offers != null) {
        final priceCurrency = offers['priceCurrency'] as String? ?? '';
        final priceVal = offers['price']?.toString() ?? '';
        price.text = '$priceCurrency $priceVal'.trim();
      }
    }

    final imageSource = data['image'];
    if (imageSource != null && img != null) {
      if (imageSource is List && imageSource.isNotEmpty) {
        final firstImg = imageSource.first;
        img.src = firstImg is Map ? (firstImg['url'] as String? ?? '') : firstImg.toString();
      } else if (imageSource is Map) {
        img.src = imageSource['url'] as String? ?? '';
      } else {
        img.src = imageSource.toString();
      }
    }
  }
}

void initItem() {
  final rawEl = document.getElementById('post-body-raw');
  if (rawEl == null) return;

  var data = parseJSON(rawEl.text);

  // If parsing failed, try finding script tags
  if (data == null) {
    final allScripts = document.querySelectorAll('script[type="application/ld+json"]');
    for (var s in allScripts) {
      final parsed = parseJSON(s.text);
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

  final type = data['@type'];
  if (type == 'ProductGroup') {
    state.product = data;
    renderProduct();
  } else if (type == 'LocalBusiness' || type == 'Service' || type == 'Product') {
    state.service = data;
    renderService();
  }

  final init = document.getElementById('initializing-state');
  if (init != null) {
    init.classes.add('hidden');
  }

  document.getElementById('carousel-section')?.classes.remove('hidden');
  document.getElementById('details-section')?.classes.remove('hidden');
}

String decodeEntities(String text) {
  final textArea = TextAreaElement()..setInnerHtml(text);
  return textArea.value ?? '';
}

Map<String, dynamic>? parseJSON(String? text) {
  if (text == null || text.trim().isEmpty) return null;

  final regex = RegExp(r'<script[^>]*type=["' "'" r']application\/ld\+json["' "'" r'][^>]*>([\s\S]*?)<\/script>', caseSensitive: false);
  final match = regex.firstMatch(text);
  final jsonStr = match != null ? match.group(1) : text;

  if (jsonStr == null) return null;

  var decoded = decodeEntities(jsonStr);
  if (decoded.contains('&quot;')) {
    decoded = decodeEntities(decoded);
  }

  try {
    // Remove inline JS comments (both block and single line)
    final cleanJson = decoded
        .replaceAll(RegExp(r'\/\*[\s\S]*?\/'), '')
        .replaceAll(RegExp(r'([^\\:]|^)\/\/.*$'), '')
        .trim();
    return json.decode(cleanJson) as Map<String, dynamic>;
  } catch (e) {
    // Fallback: try finding largest brace block
    final braceRegex = RegExp(r'\{[\s\S]*\}');
    final braceMatch = braceRegex.firstMatch(decoded);
    if (braceMatch != null) {
      try {
        return json.decode(braceMatch.group(0)!) as Map<String, dynamic>;
      } catch (_) {}
    }
    print("Failed to parse JSON-LD: $e");
    return null;
  }
}

void renderProduct() {
  final p = state.product;
  if (p == null) return;

  document.getElementById('p-name')?.text = p['name'] as String? ?? '';
  document.getElementById('p-desc')?.text = p['description'] as String? ?? '';

  // Brand Info
  final brand = p['brand'];
  if (brand != null) {
    final brandDiv = DivElement()
      ..style.color = '#777'
      ..style.marginTop = '-10px';

    if (brand is String) {
      brandDiv.text = brand;
    } else if (brand is Map) {
      brandDiv.text = brand['name'] as String? ?? '';
    }
    document.getElementById('p-name')?.after(brandDiv);
  }

  final vars = document.getElementById('p-variants');
  if (vars != null) {
    vars.text = '';

    final variesBy = p['variesBy'] as List<dynamic>?;
    final hasVariant = p['hasVariant'] as List<dynamic>? ?? [];

    if (variesBy != null) {
      for (var vUrl in variesBy) {
        final attr = (vUrl as String).split(RegExp(r'[/#]')).last;
        final values = hasVariant
            .map((v) => (v as Map<String, dynamic>)[attr])
            .where((val) => val != null)
            .toSet()
            .toList();

        final group = DivElement()..className = 'v-group';
        group.setInnerHtml('<span class="v-label">Select $attr:</span>');

        final opts = DivElement()..className = 'v-options';

        for (var val in values) {
          final btn = ButtonElement()
            ..className = 'v-btn'
            ..setAttribute('data-attr', attr)
            ..setAttribute('data-val', val.toString());

          if (attr.toLowerCase() == 'color') {
            btn.classes.add('v-color');
            btn.style.backgroundColor = val.toString();
            btn.title = val.toString();
          } else {
            btn.text = val.toString();
          }

          btn.onClick.listen((e) {
            state.selected[attr] = val.toString();
            updateProductView(attr);
            checkAvailability();
          });

          opts.append(btn);
        }

        group.append(opts);
        vars.append(group);
        if (values.isNotEmpty) {
          state.selected[attr] = values.first.toString();
        }
      }
    }
  }

  updateProductView(null);
  checkAvailability();
}

void checkAvailability() {
  final p = state.product;
  if (p == null) return;

  final allBtns = document.querySelectorAll('.v-btn[data-attr]');
  final hasVariant = p['hasVariant'] as List<dynamic>? ?? [];

  for (var btn in allBtns) {
    final attr = btn.getAttribute('data-attr') ?? '';
    final val = btn.getAttribute('data-val') ?? '';

    final globalPossible = hasVariant.any((v) => (v as Map)[attr]?.toString() == val);

    final testSelected = Map<String, String>.from(state.selected)..[attr] = val;
    final matchingVariant = hasVariant.firstWhere((v) {
      final vMap = v as Map;
      return testSelected.entries.every((entry) {
        final vVal = vMap[entry.key];
        return vVal == null || vVal.toString() == entry.value;
      });
    }, orElse: () => null);

    final isOut = matchingVariant != null &&
        matchingVariant['offers'] != null &&
        matchingVariant['offers']['availability'] == 'https://schema.org/OutOfStock';

    if (btn is ButtonElement) {
      btn.disabled = !globalPossible;
    }

    btn.style.opacity = matchingVariant == null ? '0.4' : (isOut ? '0.6' : '1');
    btn.style.borderStyle = matchingVariant == null ? 'dashed' : 'solid';

    if (isOut) {
      btn.title = '$val (Out of Stock)';
    } else {
      btn.title = val;
    }
  }
}

String formatValue(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  if (v is Map) {
    if (v['@type'] == 'QuantitativeValue') {
      final val = v['value']?.toString() ?? '';
      final unit = v['unitCode'] ?? v['unitText'] ?? '';
      return '$val $unit'.trim();
    }
    return v['value']?.toString() ?? '';
  }
  return v.toString();
}

void updateProductView(String? pivotAttr) {
  final p = state.product;
  if (p == null) return;

  final hasVariant = p['hasVariant'] as List<dynamic>? ?? [];
  if (hasVariant.isEmpty) return;

  var variant = hasVariant.firstWhere((v) {
    final vMap = v as Map;
    return state.selected.entries.every((entry) => vMap[entry.key]?.toString() == entry.value);
  }, orElse: () => null) as Map<String, dynamic>?;

  if (variant == null) {
    if (pivotAttr != null) {
      variant = hasVariant.firstWhere((v) => (v as Map)[pivotAttr]?.toString() == state.selected[pivotAttr], orElse: () => hasVariant.first) as Map<String, dynamic>?;
    } else {
      variant = hasVariant.first as Map<String, dynamic>?;
    }

    if (variant != null) {
      final variesBy = p['variesBy'] as List<dynamic>?;
      if (variesBy != null) {
        for (var vUrl in variesBy) {
          final attr = (vUrl as String).split(RegExp(r'[/#]')).last;
          final vVal = variant[attr];
          if (vVal != null) {
            state.selected[attr] = vVal.toString();
          }
        }
      }
    }
  }

  if (variant == null) return;

  // SKU Info
  final skuEl = document.getElementById('p-sku');
  if (skuEl != null) {
    skuEl.text = variant['sku'] != null ? 'SKU: ${variant['sku']}' : '';
  }

  // Offers & Prices
  final offers = variant['offers'] as Map<String, dynamic>?;
  if (offers != null) {
    final priceEl = document.getElementById('p-price');
    if (priceEl != null) {
      final priceCurrency = offers['priceCurrency'] as String? ?? '';
      final priceVal = offers['price']?.toString() ?? '';
      priceEl.text = '$priceCurrency $priceVal'.trim();
      priceEl.classes.toggle('blurry', offers['availability'] == 'https://schema.org/OutOfStock');

      var badge = document.getElementById('stock-indicator');
      if (badge == null) {
        badge = SpanElement()
          ..id = 'stock-indicator'
          ..className = 'stock-badge';
        priceEl.after(badge);
      }

      final av = offers['availability'] as String? ?? '';
      if (av == 'https://schema.org/InStock') {
        badge.text = 'In Stock';
        badge.className = 'stock-badge in-stock';
      } else if (av == 'https://schema.org/OutOfStock') {
        badge.text = 'Out of Stock';
        badge.className = 'stock-badge out-stock';
      } else if (av == 'https://schema.org/InStoreOnly') {
        badge.text = 'In-Store Only';
        badge.className = 'stock-badge instore-only';
      } else if (av == 'https://schema.org/PreOrder') {
        badge.text = 'Pre-Order';
        final starts = offers['availabilityStarts'] as String?;
        if (starts != null) {
          badge.text = 'Pre-Order (from ${starts.split('T').first})';
        }
        badge.className = 'stock-badge pre-order';
      }
    }

    // Delivery Info
    final orderSection = document.getElementById('p-order-info');
    final orderList = document.getElementById('order-info-list');
    if (orderSection != null && orderList != null) {
      var orderHtml = '';

      final lead = offers['deliveryLeadTime'];
      if (lead != null) {
        orderHtml += '<div>&#128666; <b>Delivery:</b> ~${formatValue(lead)}</div>';
      }

      final eligible = offers['eligibleQuantity'] as Map?;
      if (eligible != null && eligible['minValue'] != null) {
        orderHtml += '<div>&#128230; <b>Min Order:</b> ${eligible['minValue']} units</div>';
      }

      final accepted = offers['acceptedPaymentMethod'];
      if (accepted != null) {
        final payments = accepted is List ? accepted : [accepted];
        final labels = payments.map((p) => p.toString().split('/').last).join(', ');
        orderHtml += '<div>&#128179; <b>Payments:</b> $labels</div>';
      }

      final deliveryMethod = offers['availableDeliveryMethod']?.toString();
      if (deliveryMethod != null) {
        orderHtml += '<div>&#128230; <b>Method:</b> ${deliveryMethod.split('/').last}</div>';
      }

      if (orderHtml.isNotEmpty) {
        orderSection.style.display = 'block';
        orderList.setInnerHtml(orderHtml, treeSanitizer: NodeTreeSanitizer.trusted);
      } else {
        orderSection.style.display = 'none';
      }
    }

    // Seller Info
    renderSeller(offers['seller'] as Map<String, dynamic>?);
  }

  // Image Carousel
  final vImgs = variant['image'] is List ? (variant['image'] as List) : (variant['image'] != null ? [variant['image']] : []);
  final pImgs = p['image'] is List ? (p['image'] as List) : (p['image'] != null ? [p['image']] : []);
  final allImgs = vImgs.isNotEmpty ? vImgs : pImgs;

  renderCarousel(allImgs);

  // Specifications
  final specs = document.getElementById('p-specs');
  final list = document.getElementById('specs-list');
  if (specs != null && list != null) {
    final fields = {
      'Model': variant['model'] ?? p['model'],
      'Material': variant['material'] ?? p['material'],
      'Condition': (variant['itemCondition'] ?? (offers != null ? offers['itemCondition'] : null))?.toString().split('/').last ?? '',
      'GTIN': variant['gtin13'] ?? variant['gtin8'] ?? '',
      'MPN': variant['mpn'] ?? '',
      'Weight': formatValue(variant['weight'] ?? p['weight']),
      'Height': formatValue(variant['height'] ?? p['height']),
      'Width': formatValue(variant['width'] ?? p['width']),
      'Depth': formatValue(variant['depth'] ?? p['depth']),
      'Color': variant['color'] ?? p['color']
    };

    var specsHtml = '';
    fields.forEach((label, val) {
      if (val != null && val.toString().isNotEmpty) {
        specsHtml += '''<div style="display:flex; justify-content:space-between; padding:4px 0; border-bottom:1px dashed #f0f0f0;">
                          <span style="color:#888;">$label</span>
                          <span style="font-weight:600;">$val</span>
                       </div>''';
      }
    });

    if (specsHtml.isNotEmpty) {
      specs.style.display = 'block';
      list.setInnerHtml(specsHtml, treeSanitizer: NodeTreeSanitizer.trusted);
    } else {
      specs.style.display = 'none';
    }
  }

  // Highlight active buttons
  final allVButtons = document.querySelectorAll('.v-btn');
  for (var btn in allVButtons) {
    final val = btn.text ?? btn.title ?? '';
    final isSelected = state.selected.values.any((v) => v == val);
    btn.classes.toggle('active', isSelected);
  }
}

void renderService() {
  final s = state.service;
  if (s == null) return;

  document.getElementById('p-name')?.text = s['name'] as String? ?? '';
  document.getElementById('p-desc')?.text = s['description'] as String? ?? '';

  // Area Served
  final areaServed = s['areaServed'];
  if (areaServed != null) {
    var area = '';
    if (areaServed is String) {
      area = areaServed;
    } else if (areaServed is Map) {
      area = areaServed['name'] as String? ?? areaServed['@type'] as String? ?? '';
    }

    if (area.isNotEmpty) {
      final badge = DivElement()
        ..className = 'geo-badge'
        ..style.background = '#e8f5e9'
        ..style.color = '#2e7d32';
      badge.setInnerHtml('&#127760; <b>Area Served:</b> $area');
      document.getElementById('p-desc')?.after(badge);
    }
  }

  final vars = document.getElementById('p-variants');
  if (vars != null) {
    final hasOfferCatalog = s['hasOfferCatalog'] as Map?;
    vars.text = '';

    if (hasOfferCatalog != null) {
      vars.append(HeadingElement.h4()..text = 'Available Options');
      final opts = DivElement()..className = 'v-options';

      final list = hasOfferCatalog['itemListElement'] as List? ?? [];
      for (var item in list) {
        final offer = item as Map;
        final itemOffered = offer['itemOffered'] as Map? ?? {};
        final name = itemOffered['name'] as String? ?? '';
        final priceCurrency = offer['priceCurrency'] as String? ?? '';
        final price = offer['price']?.toString() ?? '';

        final btn = ButtonElement()
          ..className = 'v-btn';
        btn.setInnerHtml('$name <br/> <b>$priceCurrency $price</b>');

        btn.onClick.listen((e) {
          final priceEl = document.getElementById('p-price');
          if (priceEl != null) {
            priceEl.text = '$priceCurrency $price'.trim();
          }
          final allBtns = opts.querySelectorAll('.v-btn');
          for (var b in allBtns) {
            b.classes.remove('active');
          }
          btn.classes.add('active');
        });

        opts.append(btn);
      }

      vars.append(opts);
      if (opts.children.isNotEmpty) {
        (opts.children.first as ButtonElement).click();
      }
    }
  }

  final images = s['image'] is List ? (s['image'] as List) : (s['image'] != null ? [s['image']] : []);
  renderCarousel(images);

  final provider = s['provider'] as Map<String, dynamic>? ?? s;
  renderSeller(provider);
}

void renderCarousel(List<dynamic> images) {
  final inner = document.getElementById('carousel-inner');
  final thumbRow = document.getElementById('thumbnail-row');
  if (inner == null) return;

  inner.text = '';
  if (thumbRow != null) {
    thumbRow.text = '';
  }

  state.slide = 0;
  inner.style.transform = 'translateX(0)';

  final list = images.where((src) => src != null).toList();

  for (var i = 0; i < list.length; i++) {
    final src = list[i];
    var imgUrl = '';
    if (src is Map) {
      imgUrl = src['url'] as String? ?? '';
    } else {
      imgUrl = src.toString();
    }

    final div = DivElement()
      ..className = 'carousel-item';
    div.setInnerHtml('<img src="$imgUrl"/>');
    inner.append(div);

    if (thumbRow != null && list.length > 1) {
      final thumb = ImageElement()
        ..className = 'thumb${i == 0 ? ' active' : ''}'
        ..src = imgUrl;

      thumb.onClick.listen((e) => goToSlide(i));
      thumbRow.append(thumb);
    }
  }
}

void goToSlide(int idx) {
  final inner = document.getElementById('carousel-inner');
  final thumbs = document.querySelectorAll('.thumb');
  final count = document.querySelectorAll('.carousel-item').length;

  var targetIdx = idx;
  if (targetIdx < 0) targetIdx = count - 1;
  if (targetIdx >= count) targetIdx = 0;

  state.slide = targetIdx;
  if (inner != null) {
    inner.style.transform = 'translateX(-${targetIdx * 100}%)';
  }

  for (var i = 0; i < thumbs.length; i++) {
    thumbs[i].classes.toggle('active', i == targetIdx);
  }
}

void nextSlide() {
  final count = document.querySelectorAll('.carousel-item').length;
  if (count > 1) {
    goToSlide(state.slide + 1);
  }
}

void prevSlide() {
  final count = document.querySelectorAll('.carousel-item').length;
  if (count > 1) {
    goToSlide(state.slide - 1);
  }
}

void renderSeller(Map<String, dynamic>? seller) {
  if (seller == null) return;

  final info = document.getElementById('seller-info');
  if (info == null) return;

  final name = seller['name'] as String? ?? '';
  var contactHtml = '<strong>$name</strong><br/>';

  final phone = seller['telephone'] as String?;
  if (phone != null) {
    contactHtml += '&#128222; $phone<br/>';
  }

  final email = seller['email'] as String?;
  if (email != null) {
    contactHtml += '&#128231; <a href="mailto:$email" style="color:inherit;">$email</a><br/>';
  }

  final address = seller['address'] as Map?;
  if (address != null) {
    final street = address['streetAddress'] as String? ?? '';
    final locality = address['addressLocality'] as String? ?? '';
    final country = address['addressCountry'] as String? ?? '';
    contactHtml += '&#128205; $street $locality $country';
  }

  // Social Links
  final sameAs = seller['sameAs'];
  if (sameAs != null) {
    contactHtml += '<div class="social-row">';
    final links = sameAs is List ? sameAs : [sameAs];
    for (var url in links) {
      final urlStr = url.toString();
      var label = 'Link';
      if (urlStr.contains('facebook.com')) {
        label = 'Facebook';
      } else if (urlStr.contains('instagram.com')) {
        label = 'Instagram';
      } else if (urlStr.contains('twitter.com') || urlStr.contains('x.com')) {
        label = 'Twitter';
      } else if (urlStr.contains('linkedin.com')) {
        label = 'LinkedIn';
      }
      contactHtml += '<a href="$urlStr" class="social-link" target="_blank">$label</a>';
    }
    contactHtml += '</div>';
  }

  info.setInnerHtml(contactHtml, treeSanitizer: NodeTreeSanitizer.trusted);

  final geo = seller['geo'] as Map?;
  if (geo != null && geo['latitude'] != null && geo['longitude'] != null) {
    document.getElementById('geo-info')?.style.display = 'inline-flex';
    final lat = geo['latitude'].toString();
    final lon = geo['longitude'].toString();
    final geoText = document.getElementById('geo-text');
    if (geoText != null) {
      geoText.text = '$lat, $lon';
    }

    final mapsLink = document.getElementById('maps-link') as AnchorElement?;
    if (mapsLink != null) {
      final userAgent = window.navigator.userAgent.toLowerCase();
      final isMobile = RegExp(r'iphone|ipad|ipod|android').hasMatch(userAgent);
      mapsLink.href = isMobile ? 'geo:$lat,$lon' : 'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
      mapsLink.style.display = 'inline-block';
    }
  } else {
    document.getElementById('geo-info')?.style.display = 'none';
    document.getElementById('maps-link')?.style.display = 'none';
  }

  // Optional services
  List<dynamic> services = [];
  final hasOfferCatalog = seller['hasOfferCatalog'] as Map?;
  if (hasOfferCatalog != null && hasOfferCatalog['itemListElement'] is List) {
    services = hasOfferCatalog['itemListElement'] as List;
  } else if (seller['knowsAbout'] != null) {
    final knows = seller['knowsAbout'];
    services = knows is List ? knows : [knows];
  }

  final otherSection = document.getElementById('other-services');
  final list = document.getElementById('other-services-list');

  if (services.isNotEmpty && otherSection != null && list != null) {
    otherSection.style.display = 'block';
    list.text = '';

    for (var ser in services) {
      var sName = '';
      var sPrice = '';

      if (ser is String) {
        sName = ser;
      } else if (ser is Map) {
        final itemOffered = ser['itemOffered'] as Map?;
        sName = ser['name'] as String? ?? (itemOffered != null ? itemOffered['name'] as String? ?? '' : '');
        if (ser['price'] != null) {
          final priceCurrency = ser['priceCurrency'] as String? ?? '';
          final priceVal = ser['price'].toString();
          sPrice = '$priceCurrency $priceVal'.trim();
        }
      }

      if (sName.isNotEmpty) {
        final card = DivElement()..className = 'h-card';
        var cardInner = '<strong>$sName</strong>';
        if (sPrice.isNotEmpty) {
          cardInner += '<br/><span style="color:var(--accent); font-weight:700;">$sPrice</span>';
        }
        card.setInnerHtml(cardInner, treeSanitizer: NodeTreeSanitizer.trusted);
        list.append(card);
      }
    }
  } else {
    otherSection?.style.display = 'none';
  }
}
