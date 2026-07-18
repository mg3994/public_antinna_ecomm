import 'package:blogger_theme/blogger_theme.dart';
import 'brand/brand.dart';
import 'header_right/header_right.dart';
import 'btn_close.dart';

/// Fixed Layout Top branding Header
final sidebar_header = Div(
  attributes: {'class': 'sidebar-header'},
  children: [brand_logo, header_right, btn_close_sidebar],
);
