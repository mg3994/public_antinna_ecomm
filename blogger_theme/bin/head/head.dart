import 'package:blogger_theme/blogger_theme.dart';
import "eu/eu.dart";
import "seo/seo.dart";

import "title/title.dart";
import "css/css.dart";
import 'script/script.dart';

class BloggerHead implements Component {
  @override
  Iterable<Component> build() {
    return [
      themeScript,
      cookieEUScript,
      ...seo_head,
      title_head,
      bskin_head,
    
    ];
  }
}
