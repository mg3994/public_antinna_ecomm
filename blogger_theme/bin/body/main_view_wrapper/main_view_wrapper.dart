//  <!-- MAIN DASHBOARD CONTENT AREA VIEWPORT LAYOUT WRAPPER -->
//       <div class='main-view-wrapper'>

import 'package:blogger_theme/blogger_theme.dart';
import 'top_navbar_header/top_navbar_header.dart';
import 'scrollable_main_content/scrollable_main_content.dart';
// import 'mobile_bottom_navigation_bar/mobile_bottom_navigation_bar.dart'; // TODO: remove this file

final main_view_wrapper = Div(
  attributes: {'class': 'main-view-wrapper'},
  children: [top_navbar_header, scrollable_main_content],
);
