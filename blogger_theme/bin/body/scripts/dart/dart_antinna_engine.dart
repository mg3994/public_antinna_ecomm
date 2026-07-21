import 'dart:html';
import 'dart:js' as js;
import 'core/state.dart';
import 'core/parser.dart';
import 'core/schema_resolver.dart';
import 'presentation/grid_renderer.dart';
import 'presentation/carousel_renderer.dart';
import 'presentation/product_renderer.dart';
import 'presentation/service_renderer.dart';

void main() {
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
