import 'dart:html';
import '../core/state.dart';
import 'carousel_renderer.dart';
import 'seller_renderer.dart';

class ProductRenderer {
  static void renderProduct() {
    final p = state.product;
    if (p == null) return;

    document.getElementById('p-name')?.text = p['name'] as String? ?? '';
    document.getElementById('p-desc')?.text = p['description'] as String? ?? '';

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

  static void checkAvailability() {
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

  static String formatValue(dynamic v) {
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

  static void updateProductView(String? pivotAttr) {
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

    final skuEl = document.getElementById('p-sku');
    if (skuEl != null) {
      skuEl.text = variant['sku'] != null ? 'SKU: ${variant['sku']}' : '';
    }

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

      SellerRenderer.renderSeller(offers['seller'] as Map<String, dynamic>?);
    }

    final vImgs = variant['image'] is List ? (variant['image'] as List) : (variant['image'] != null ? [variant['image']] : []);
    final pImgs = p['image'] is List ? (p['image'] as List) : (p['image'] != null ? [p['image']] : []);
    final allImgs = vImgs.isNotEmpty ? vImgs : pImgs;

    CarouselRenderer.renderCarousel(allImgs);

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

    final allVButtons = document.querySelectorAll('.v-btn');
    for (var btn in allVButtons) {
      final val = btn.text ?? btn.title ?? '';
      final isSelected = state.selected.values.any((v) => v == val);
      btn.classes.toggle('active', isSelected);
    }
  }
}
