import 'package:blogger_theme/blogger_theme.dart';

final brand_text = Span(
  attributes: {'class': 'brand-text'},
  children: [BEval(expr: 'data:blog.title')],
);
