import 'dart:html';
import '../core/parser.dart';

class SellerRenderer {
  static void renderSeller(Map<String, dynamic>? seller) {
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
}
