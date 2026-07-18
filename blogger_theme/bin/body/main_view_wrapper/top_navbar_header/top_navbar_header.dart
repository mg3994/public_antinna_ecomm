//  <!-- Global Platform Search Bar Strip Header -->
//             <header class='top-navbar-header'>

import 'package:blogger_theme/blogger_theme.dart';
import 'header_left/header_left.dart';
import 'header_center_search/header_center_search.dart';


final top_navbar_header = Header(attributes: {
  'class': 'top-navbar-header',
}, children: [
  header_left,
  header_center_search,
  // header_right
]);
