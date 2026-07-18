// <button class='btn-close-sidebar' onclick='toggleSidebarDrawer()'>&#215;</button>
import 'package:blogger_theme/blogger_theme.dart';

final btn_close_sidebar = Button(children: [
  "\u00D7".component
], attributes: {
  'class': 'btn-close-sidebar',
  'onclick': 'toggleSidebarDrawer()'
});
