import 'dart:html';
import '../core/state.dart';

class CarouselRenderer {
  static void renderCarousel(List<dynamic> images) {
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

      final div = DivElement()..className = 'carousel-item';
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

  static void goToSlide(int idx) {
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

  static void nextSlide() {
    final count = document.querySelectorAll('.carousel-item').length;
    if (count > 1) {
      goToSlide(state.slide + 1);
    }
  }

  static void prevSlide() {
    final count = document.querySelectorAll('.carousel-item').length;
    if (count > 1) {
      goToSlide(state.slide - 1);
    }
  }
}
