import 'dart:html';
import 'dart:convert';
import '../core/parser.dart';
import '../core/feed_service.dart';

class GridRenderer {
  static void init() {
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

    final feedUrl = FeedService.getFeedUrl();

    FeedService.fetchFeed(feedUrl).then((response) {
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
            final data = SchemaParser.parseJSON(content);
            if (data != null) {
              renderCardData(card, data);
            }
          } else {
            _fallbackCard(card);
          }
        }
      } catch (_) {
        _fallbackAll(cards);
      }
    }).catchError((_) {
      _fallbackAll(cards);
    });
  }

  static void _fallbackCard(Element card) {
    final raw = card.querySelector('.grid-data');
    if (raw != null) {
      final data = SchemaParser.parseJSON(raw.text);
      if (data != null) {
        renderCardData(card, data);
      }
    }
  }

  static void _fallbackAll(List<Element> cards) {
    for (var card in cards) {
      _fallbackCard(card);
    }
  }

  static void renderCardData(Element card, Map<String, dynamic> data) {
    final badge = card.querySelector('.card-badge');
    final price = card.querySelector('.card-price');
    final img = card.querySelector('.card-img') as ImageElement?;

    if (badge == null || price == null) return;

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
}
