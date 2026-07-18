import 'package:blogger_theme/blogger_theme.dart';
import 'header/header.dart';
import 'scroll_content/scroll_content.dart';
import 'avatar_footer_row/avatar_footer_row.dart';

/// SIDEBAR DRAWER COMPONENT

final sidebar_drawer = Aside(
  attributes: {"id": 'sidebar-drawer'},
  children: [sidebar_header, sidebar_scroll_content, avatar_footer_row],
);
