//   <!-- Dynamic Scroll Container Viewport Layer -->
// <div class='sidebar-scroll-content'>

import 'package:blogger_theme/blogger_theme.dart';
import 'desktop_nav_fallback/desktop_nav_fallback.dart';
import 'modules_area/modules-area.dart';
import 'legal_area/legal_area.dart';
import 'social_wrapper/social_wrapper.dart';

final sidebar_scroll_content = Div(
  attributes: {'class': 'sidebar-scroll-content'},
  children: [
    desktop_nav_fallback,
    sidebar_modules_area,
    sidebar_legal_area,
    sidebar_social_wrapper,
  ],
);
