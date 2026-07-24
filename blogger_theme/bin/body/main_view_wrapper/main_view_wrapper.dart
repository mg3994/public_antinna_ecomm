import 'package:blogger_theme/blogger_theme.dart';
import 'top_navbar_header/top_navbar_header.dart';
import 'scrollable_main_content/scrollable_main_content.dart';
import 'scrollable_main_content/categories_widget.dart';

final categories_section = BSection(
  className: 'category-section-wrapper',
  id: 'category-section',
  showaddelement: true,
  children: [categories_widget],
);

final main_view_wrapper = Div(
  attributes: {'class': 'main-view-wrapper'},
  children: [top_navbar_header, categories_section, scrollable_main_content],
);
