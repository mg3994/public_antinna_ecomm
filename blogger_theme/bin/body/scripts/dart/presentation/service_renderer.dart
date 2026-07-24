import 'dart:html';
import '../core/state.dart';
import 'carousel_renderer.dart';
import 'seller_renderer.dart';

class ServiceRenderer {
  static void renderService() {
    final s = state.service;
    if (s == null) return;

    document.getElementById('p-name')?.text = s['name'] as String? ?? '';
    document.getElementById('p-desc')?.text = s['description'] as String? ?? '';

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

          final btn = ButtonElement()..className = 'v-btn';
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
    CarouselRenderer.renderCarousel(images);

    final provider = s['provider'] as Map<String, dynamic>? ?? s;
    SellerRenderer.renderSeller(provider);
  }
}
